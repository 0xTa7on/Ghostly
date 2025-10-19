#!/bin/bash

# --- Ghostly Installation Script ---

# Color definitions for better output
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Define the source script name and the desired destination name
SOURCE_SCRIPT="ghostly.sh"
DEST_NAME="ghostly"
INSTALL_DIR="/usr/local/bin"

# 1. Check if the script is being run as root
if [ "$(id -u)" -ne 0 ]; then
  echo -e "${YELLOW}This script needs to be run with root privileges to install the tool system-wide.${NC}"
  echo "Please run it again with 'sudo ./install.sh'"
  exit 1
fi

# 2. Check if the source file exists
if [ ! -f "$SOURCE_SCRIPT" ]; then
    echo -e "${RED}Error: The source script '$SOURCE_SCRIPT' was not found.${NC}"
    echo "Please make sure you are in the correct directory before running this script."
    exit 1
fi

# 3. Make the source script executable
echo "Making the script executable..."
chmod +x "$SOURCE_SCRIPT"

# 4. Copy the script to the installation directory and rename it
echo "Copying '$SOURCE_SCRIPT' to '$INSTALL_DIR/$DEST_NAME'..."
cp "$SOURCE_SCRIPT" "$INSTALL_DIR/$DEST_NAME"

# 5. Verify the installation
if [ -f "$INSTALL_DIR/$DEST_NAME" ]; then
    echo -e "${GREEN}Installation complete!${NC}"
    echo "You can now run the tool from anywhere by typing: ${YELLOW}$DEST_NAME${NC}"
else
    echo -e "${RED}Installation failed. Could not find the script in the destination directory.${NC}"
    exit 1
fi

exit 0
