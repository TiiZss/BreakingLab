#!/bin/bash

# YAML Sanitization Utilities for BreakingLab
# Uses pure bash/sed/grep to avoid dependencies

sanitize_compose() {
    local compose_file="$1"
    local bind_ip="$2"
    local main_port="$3" # The internal port the user wants to access
    
    [ -f "$compose_file" ] || return 1
    
    echo -e "$TCC Sanitizing docker-compose file... $TCD"
    
    # 1. Remove container_name to avoid conflicts
    # Matches "container_name: value" with flexible whitespace
    sed -i -E '/^\s*container_name:/d' "$compose_file"
    echo "Removed hardcoded container names."
    
    # 2. Rewrite Ports
    # This is tricky with regex. We look for the main_port.
    # We want to replace mappings like:
    #   - "80:80"  ->  - "IP:PORT:80"
    #   - 80:80    ->  - "IP:PORT:80"
    #   - "80"     ->  - "IP:PORT:80"
    
    # Check if main_port is actually in the file
    if grep -q -- "$main_port" "$compose_file"; then
        echo "Rewriting rules for port $main_port binding to $bind_ip..."
        
        # Pattern 1: HOST:CONTAINER (e.g. 5000:5000 or "5000:5000")
        # We replace the HOST port with our specific IP:PORT
        # But we only want to touch the line mapping to our internal MAIN_PORT
        
        # Regex explanation:
        # ^\s*-\s*               Start of list item
        # ("?)                   Optional quote capture group 1
        # [0-9]+                 Host port (we don't care what it was)
        # :                      Separator
        # ${main_port}           The internal port we target
        # \1                     Matching closing quote
        
        # Replacement:
        # - "${bind_ip}:${main_port}:${main_port}"
        
        # We assume the user wants the same external port number, but bound to the specific IP.
        # If the user input a PROPOSED host port in the wizard, we should use that. 
        # But import_github_project currently asks for "Main Service Port" which implies the INTERNAL port (for checking).
        # Let's assume External Port = Internal Port for simplicity, but strictly bound to IP.
        
        # Replace: - "5000:5000" -> - "127.100.0.X:5000:5000"
        sed -i -E "s/^\s*-\s*\"?[0-9]+:${main_port}\"?/      - \"${bind_ip}:${main_port}:${main_port}\"/" "$compose_file"
        
        # Pattern 2: Short syntax (e.g. - "5000") which implies random host port
        # Replace: - "5000" -> - "127.100.0.X:5000:5000"
        sed -i -E "s/^\s*-\s*\"?${main_port}\"?\s*$/      - \"${bind_ip}:${main_port}:${main_port}\"/" "$compose_file"
        
        echo "Ports updated."
    else
        echo -e "$TCY Warning: Could not find port $main_port in compose file to rewrite. Manual check recommended. $TCD"
    fi
}
