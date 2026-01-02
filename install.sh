#!/bin/bash
# Install BreakingLab globally

set -euo pipefail

# Ensure we are root
if [ "$EUID" -ne 0 ]; then 
  echo "Please run as root (sudo ./install.sh)"
  exit 1
fi

INSTALL_DIR="/usr/local/bin"
SCRIPT_NAME="breakinglab"
SOURCE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
SOURCE_SCRIPT="$SOURCE_DIR/breakinglab.sh"

echo "Installing BreakingLab from $SOURCE_DIR..."

if [ ! -f "$SOURCE_SCRIPT" ]; then
    echo "Error: breakinglab.sh not found in $SOURCE_DIR"
    exit 1
fi

# Make executable
chmod +x "$SOURCE_SCRIPT"

# Create symlink
echo "Creating symlink in $INSTALL_DIR/$SCRIPT_NAME..."
ln -sf "$SOURCE_SCRIPT" "$INSTALL_DIR/$SCRIPT_NAME"

echo "Success! You can now run 'breakinglab' from anywhere."
