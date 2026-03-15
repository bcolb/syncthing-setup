#!/bin/bash
# Syncthing Setup Script for macOS
# Installs and configures Syncthing
# Run: bash setup-syncthing.sh

set -e

echo "Syncthing Setup for macOS"
echo "=========================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Check if running on macOS
if [[ "$(uname)" != "Darwin" ]]; then
    echo -e "${RED}Error: This script is for macOS only${NC}"
    exit 1
fi

echo "This script will:"
echo "  1. Install Syncthing via Homebrew"
echo "  2. Start Syncthing service"
echo "  3. Display your device ID"
echo "  4. Open web interface"
echo ""

read -p "Continue? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Cancelled"
    exit 0
fi

echo ""
echo -e "${GREEN}Step 1: Installing Syncthing${NC}"
echo ""

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    echo -e "${RED}Error: Homebrew not installed${NC}"
    echo "Install Homebrew first:"
    echo '  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
    exit 1
fi

# Install Syncthing if not already installed
if ! command -v syncthing &> /dev/null; then
    echo "Installing Syncthing..."
    brew install syncthing
    echo -e "${GREEN}Syncthing installed${NC}"
else
    echo "Syncthing already installed"
fi

echo ""
echo -e "${GREEN}Step 2: Starting Syncthing Service${NC}"
echo ""

# Start Syncthing service
if brew services list | grep syncthing | grep started > /dev/null; then
    echo "Syncthing service already running"
else
    echo "Starting Syncthing service..."
    brew services start syncthing
    echo "Waiting for Syncthing to start..."
    sleep 5
fi

# Verify it's running
if brew services list | grep syncthing | grep started > /dev/null; then
    echo -e "${GREEN}Syncthing is running${NC}"
else
    echo -e "${RED}Failed to start Syncthing${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}Step 3: Getting Device Information${NC}"
echo ""

# Wait for API to be available
echo "Waiting for Syncthing API..."
for i in {1..30}; do
    if curl -s http://localhost:8384/rest/system/status > /dev/null 2>&1; then
        break
    fi
    sleep 1
done

# Get device ID
DEVICE_ID=$(curl -s http://localhost:8384/rest/system/status | grep -o '"myID":"[^"]*"' | cut -d'"' -f4)

if [ -n "$DEVICE_ID" ]; then
    echo -e "${GREEN}Your Device ID:${NC}"
    echo ""
    echo "  $DEVICE_ID"
    echo ""
    echo "Save this ID - you'll need it to connect other devices"
else
    echo -e "${YELLOW}Could not retrieve device ID automatically${NC}"
    echo "You can find it in the web UI: Actions > Show ID"
fi

# Get device name
HOSTNAME=$(hostname -s)
echo -e "${GREEN}Device Name:${NC} $HOSTNAME"

echo ""
echo -e "${GREEN}Step 4: Configuration${NC}"
echo ""

# Ask about folders to sync
echo "Which folders would you like to sync?"
echo ""
read -p "Sync ~/projects folder? (y/n) " -n 1 -r
echo
SYNC_PROJECTS=$REPLY

read -p "Sync ~/Documents/work folder? (y/n) " -n 1 -r
echo
SYNC_WORK=$REPLY

read -p "Sync ~/scripts folder? (y/n) " -n 1 -r
echo
SYNC_SCRIPTS=$REPLY

echo ""
echo -e "${GREEN}Setup Complete!${NC}"
echo ""
echo "========================================="
echo "SYNCTHING INFORMATION"
echo "========================================="
echo ""
echo -e "Device ID:   ${GREEN}$DEVICE_ID${NC}"
echo -e "Device Name: ${GREEN}$HOSTNAME${NC}"
echo -e "Web UI:      ${GREEN}http://localhost:8384${NC}"
echo ""
echo "Status:"
echo "  Service: Running"
echo "  Config:  ~/.config/syncthing"
echo "  Data:    ~/Library/Application Support/Syncthing"
echo ""

# Save info to file
cat > ~/syncthing-info.txt << EOF
Syncthing Configuration
=======================

Date: $(date)
Device ID: $DEVICE_ID
Device Name: $HOSTNAME
Web UI: http://localhost:8384

Folders to Sync:
EOF

if [[ $SYNC_PROJECTS =~ ^[Yy]$ ]]; then
    echo "  - ~/projects" >> ~/syncthing-info.txt
fi
if [[ $SYNC_WORK =~ ^[Yy]$ ]]; then
    echo "  - ~/Documents/work" >> ~/syncthing-info.txt
fi
if [[ $SYNC_SCRIPTS =~ ^[Yy]$ ]]; then
    echo "  - ~/scripts" >> ~/syncthing-info.txt
fi

echo ""
echo "Configuration saved to: ~/syncthing-info.txt"

echo ""
echo "Next Steps:"
echo ""
echo "1. Opening Syncthing web interface..."
sleep 2
open http://localhost:8384

echo ""
echo "2. On your other Mac, run this script"
echo ""
echo "3. Connect devices:"
echo "   - Actions > Show ID (copy this device's ID)"
echo "   - On other device: Add Remote Device"
echo "   - Paste this device's ID"
echo "   - Accept connection on both sides"
echo ""
echo "4. Share folders:"
echo "   - Add Folder"
echo "   - Choose folder path"
echo "   - Select device to share with"
echo "   - Apply ignore patterns from ignore-patterns.txt"
echo ""
echo "5. Optional: Run helper scripts"
echo "   - bash configure-folder.sh ~/projects 'Projects'"
echo ""

# Offer to copy device ID to clipboard
if command -v pbcopy &> /dev/null; then
    read -p "Copy device ID to clipboard? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "$DEVICE_ID" | pbcopy
        echo "Device ID copied to clipboard!"
    fi
fi

echo ""
echo "For help, see:"
echo "  README.md - Setup guide"
echo "  GUIDE.md - Detailed instructions"
echo "  TROUBLESHOOTING.md - Common issues"
echo ""
