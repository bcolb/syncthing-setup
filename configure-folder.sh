#!/bin/bash
# Configure Syncthing folder with ignore patterns
# Usage: bash configure-folder.sh <folder_path> <label>
# Example: bash configure-folder.sh ~/projects "Projects"

set -e

FOLDER_PATH=$1
LABEL=$2

if [ -z "$FOLDER_PATH" ] || [ -z "$LABEL" ]; then
    echo "Usage: bash configure-folder.sh <folder_path> <label>"
    echo ""
    echo "Examples:"
    echo "  bash configure-folder.sh ~/projects 'Projects'"
    echo "  bash configure-folder.sh ~/Documents/work 'Work Documents'"
    echo "  bash configure-folder.sh ~/scripts 'Scripts'"
    echo "  bash configure-folder.sh ~/workspace 'Workspace'"
    exit 1
fi

# Expand tilde
FOLDER_PATH="${FOLDER_PATH/#\~/$HOME}"

echo "Syncthing Folder Configuration"
echo "==============================="
echo ""
echo "Folder Path: $FOLDER_PATH"
echo "Label: $LABEL"
echo ""

# Check if folder exists
if [ ! -d "$FOLDER_PATH" ]; then
    echo "Folder does not exist: $FOLDER_PATH"
    read -p "Create it? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        mkdir -p "$FOLDER_PATH"
        echo "Folder created"
    else
        echo "Cancelled"
        exit 1
    fi
fi

echo "To add this folder in Syncthing:"
echo ""
echo "1. Open http://localhost:8384"
echo "2. Click 'Add Folder'"
echo "3. Configure:"
echo "   - Folder Label: $LABEL"
echo "   - Folder Path: $FOLDER_PATH"
echo ""
echo "4. Go to 'Sharing' tab"
echo "   - Select the device(s) to share with"
echo ""
echo "5. Go to 'Ignore Patterns' tab"
echo "   - Copy patterns from ignore-patterns.txt"
echo "   - Or use the quick patterns below"
echo ""
echo "6. Go to 'File Versioning' tab"
echo "   - Type: Simple File Versioning"
echo "   - Keep Versions: 5"
echo ""
echo "7. Click 'Save'"
echo ""

# Create .stignore file in the folder
STIGNORE_FILE="$FOLDER_PATH/.stignore"

read -p "Create .stignore file with recommended patterns? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    cat > "$STIGNORE_FILE" << 'EOF'
// Syncthing ignore patterns
// Lines starting with // are comments

// Python
__pycache__
*.pyc
*.pyo
*.pyd
.Python
*.so
*.egg
*.egg-info
dist/
build/
.venv/
venv/
env/
*.virtualenv

// Node.js
node_modules/
npm-debug.log
yarn-error.log
.npm/
.yarn/

// macOS
.DS_Store
.AppleDouble
.LSOverride
._*
.Spotlight-V100
.Trashes

// IDEs
.vscode/
.idea/
*.swp
*.swo
*~
.project
.settings/

// Git
.git/

// Jupyter
.ipynb_checkpoints/

// Databases (don't sync running databases!)
*.db
*.sqlite
*.sqlite3
*.db-journal

// Compiled
*.o
*.a
*.so
*.dylib
*.exe

// Archives (usually large)
*.zip
*.tar
*.tar.gz
*.tgz
*.rar
*.7z
*.dmg
*.iso

// Logs
*.log
logs/

// Temporary
tmp/
temp/
*.tmp
*.bak
*.swp

// OS generated
Thumbs.db
ehthumbs.db

// Package managers
.bundle/
vendor/bundle/

// Other
.env
.env.local
.cache/
EOF

    echo "Created $STIGNORE_FILE with recommended patterns"
    echo ""
    echo "Note: Syncthing will automatically load patterns from this file"
fi

echo ""
echo "Opening Syncthing web interface..."
sleep 2
open http://localhost:8384

echo ""
echo "Configuration complete!"
echo "Add the folder in the web UI using the information above."
echo ""
