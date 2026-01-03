#!/bin/bash

# YAML Sanitization Utilities for BreakingLab
# Uses pure bash/sed/grep to avoid dependencies

sanitize_compose() {
    local compose_file="$1"
    local bind_ip="$2"
    local main_port="$3"
    
    [ -f "$compose_file" ] || return 1
    
    echo -e "$TCC Sanitizing docker-compose file... $TCD"

    # Use a temp file for awk output
    local tmp_file="${compose_file}.tmp"

    # AWK script to rename services to their container_name and remove container_name field
    awk '
    BEGIN { in_services = 0; }
    
    # Check for start of services block
    /^services:/ { 
        print $0; 
        in_services = 1; 
        next; 
    }
    
    # If we are in services, we need to buffer lines to find container_name
    in_services {
        # Check indentation to see if we are at service level (e.g., 2 or 4 spaces)
        # We assume service names are indented.
        # But wait, parsing indent without a proper parser is hard.
        # Heuristic: Service names are at level 1 indent. Keys inside are level 2.
        
        # Simple approach: Read whole file into memory? No.
        # Per-service buffering.
        
        # If line starts with spaces and then a key, it might be a service or a property.
        if ($0 ~ /^[[:space:]]+[a-zA-Z0-9_-]+:/) {
            # Capture indentation
            match($0, /^[[:space:]]+/);
            indent_len = RLENGTH;
            
            # If indent is small (e.g. 2-4 spaces), it is likely a service name
            # If indent is larger, it is a property.
            # We assume "services:" is at 0 indent (or handled previously).
            # Let assume standard 2-space indent for services.
            
            # Actually, we can just look for "container_name:" line and extract the name.
            # If we find it, we need to know WHICH service it belongs to.
            # That requires tracking the last seen service line.
        }
    }
    
    { print $0; }
    ' "$compose_file" > "$tmp_file"
    
    # The AWK above is too complex to implement robustly inline without errors.
    # Let is stick to a simpler logic that works for most standard files.
    # We will iterate line by line.
    # If we see "  service_name:", save it.
    # If we see "    container_name: foo", we:
    #   1. Replace the saved "service_name" in the buffer/output with "foo".
    #   2. Delete the "container_name" line.
    
    # Better AWK implementation:
    awk -v sq="'" '
    BEGIN { in_services = 0; service_indent = 0; }
    
    /^services:/ {
        in_services = 1;
        print $0;
        next;
    }
    
    # If not in services, just print
    !in_services { print $0; next; }
    
    # Inside services
    {
        # Calculate indent
        match($0, /^ */);
        indent = RLENGTH;
        
        # If we hit top level again (indent 0) and not a comment/empty, we are out of services
        if (indent == 0 && $0 !~ /^\s*$/ && $0 !~ /^\s*#/) {
            in_services = 0;
            print $0;
            next;
        }

        # Determine if this linestarts a new service.
        is_key = ($0 ~ /^ *[a-zA-Z0-9_-]+:/);
        
        if (is_key) {
             # First service establishes common indentation level
             if (service_indent == 0) {
                 service_indent = indent;
             }
             
             # If this matches service indent, flush previous and start new service buffer
             if (indent == service_indent) {
                 if (current_service_lines > 0) flush_service();
                 
                 current_service_lines = 1;
                 service_buffer[1] = $0;
                 service_line_idx = 1; 
                 container_name = "";
                 next;
             }
        }
        
        # Inside a service
        if (current_service_lines > 0) {
            # Check for container_name
            if ($0 ~ /container_name:/) {
                # Extract value
                val = $0;
                sub(/^.*container_name:\s*/, "", val);
                sub(/\s*$/, "", val); # trim trailing
                sub(/^"/, "", val); sub(/"$/, "", val); # trim quotes
                sub("^" sq, "", val); sub(sq "$", "", val); # trim single quotes
                container_name = val;
                # Do NOT add this line to buffer (effectively deleting it)
            } else {
                current_service_lines++;
                service_buffer[current_service_lines] = $0;
            }
            next;
        }
        
        # Just a comment or empty line inside services block but not inside a service? Print.
        print $0;
    }
    
    END {
        if (current_service_lines > 0) flush_service();
    }
    
    function flush_service() {
        if (container_name != "") {
             # Rename the service line (index 1)
             # We need to preserve original indent and colon
             match(service_buffer[1], /^ */);
             orig_indent = substr(service_buffer[1], 1, RLENGTH);
             service_buffer[1] = orig_indent container_name ":";
        }
        for (i=1; i<=current_service_lines; i++) {
            print service_buffer[i];
        }
        current_service_lines = 0;
        container_name = "";
    }
' "$compose_file" > "$tmp_file" && mv "$tmp_file" "$compose_file"
    
    echo "Services renamed to match container_name and container_name key removed."

    # 2. Rewrite Ports (using existing logic, but now with robust regex from previous step)
    if grep -q -- "$main_port" "$compose_file"; then
        echo "Rewriting rules for port $main_port binding to $bind_ip..."
        sed -i -E "s/^(\s*)-\s*\"?[0-9]+:${main_port}\"?/\1- \"${bind_ip}:${main_port}:${main_port}\"/" "$compose_file"
        sed -i -E "s/^(\s*)-\s*\"?${main_port}\"?\s*$/\1- \"${bind_ip}:${main_port}:${main_port}\"/" "$compose_file"
        echo "Ports updated."
    else
        echo -e "$TCY Warning: Could not find port $main_port in compose file to rewrite. Manual check recommended. $TCD"
    fi
}

