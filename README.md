# Syncthing Setup for Mac-to-Mac Sync

Automated setup scripts and configuration for Syncthing to sync files between Macs (MacBook Air, Mac Mini, MacBook Pro, etc.). Tested primarily between a Macbook Air and Mac Mini. Note that much of this could be adapted to Linux environments.

## Overview

This repository contains scripts and guides to:

- Install and configure Syncthing on macOS
- Connect multiple Mac devices for peer-to-peer sync
- Set up folder sharing with proper ignore patterns
- Configure file versioning and backup
- Optimize for battery life on portable devices

## What is Syncthing?

Syncthing is a continuous file synchronization program that:
- Syncs files directly between devices (peer-to-peer)
- Requires no cloud storage or central server
- Uses TLS encryption for security
- Works across platforms (macOS, Linux, Windows)
- Is free and open source

Perfect for keeping your `~/projects` or `~/workspace` folders synchronized across multiple Macs.

## Quick Start

See GUIDE.md for full setup instructions.

### On Each Mac

```bash
# Clone this repository
git clone https://github.com/bcolb/syncthing-setup.git
cd syncthing-setup

# Run setup script
bash setup-syncthing.sh

# Open web interface
open http://localhost:8384
```

Follow the on-screen instructions to connect your devices and share folders.

## What Gets Synced?

### Recommended Folders

| Folder | Purpose | Sync Type |
|--------|---------|-----------|
| `~/projects` | Code projects | Send & Receive |
| `~/Documents/work` | Work documents | Send & Receive |
| `~/scripts` | Utility scripts | Send & Receive |
| `~/workspace` | Workspace | Send & Receive |
### Don't Sync These

- `~/Downloads` - Too much temporary junk
- `~/Desktop` - Personal clutter
- `~/Pictures` - Use iCloud Photos instead
- `~/Movies` - Too large
- System folders - Never sync system files

## Files in This Repository

| File | Purpose |
|------|---------|
| `setup-syncthing.sh` | Install and start Syncthing |
| `connect-devices.sh` | Helper to connect two devices |
| `configure-folder.sh` | Set up folder sync with ignore patterns |
| `ignore-patterns.txt` | Recommended ignore patterns |
| `README.md` | This file |
| `GUIDE.md` | Detailed setup guide |
| `TROUBLESHOOTING.md` | Common issues and solutions |

## Installation

### Automated Setup

```bash
# On MacBook Air
bash setup-syncthing.sh

# On Mac Mini
bash setup-syncthing.sh
```

The script will:
1. Install Syncthing via Homebrew
2. Start the service
3. Open web interface
4. Display your device ID

### Manual Installation

```bash
# Install Syncthing
brew install syncthing

# Start service
brew services start syncthing

# Open web UI
open http://localhost:8384
```

## Connecting Devices

### Method 1: Auto-Discovery (Same Network)

If both devices are on the same WiFi/network:

1. Open Syncthing UI on both devices
2. Devices should auto-discover each other
3. Click "Add Device" on the notification
4. Confirm on both sides

### Method 2: Manual Connection

**On Device 1 (MacBook Air):**
```bash
# Open Syncthing UI
open http://localhost:8384

# Click Actions > Show ID
# Copy the device ID
```

**On Device 2 (Mac Mini):**
```bash
# Open Syncthing UI
open http://localhost:8384

# Click Add Remote Device
# Paste Device 1's ID
# Save
```

**On Device 1:**
- Accept the connection request

### Using the Helper Script

```bash
# Run on either device
bash connect-devices.sh
```

## Sharing Folders

### Quick Setup

```bash
# Configure projects folder
bash configure-folder.sh ~/projects "Projects"
```

### Manual Setup

1. Open Syncthing UI: http://localhost:8384
2. Click **Add Folder**
3. Configure:
   - **Folder Label**: `Projects`
   - **Folder Path**: `/Users/yourusername/projects`
   - **Sharing** tab: Select the remote device
   - **Ignore Patterns** tab: Copy from `ignore-patterns.txt`
   - **File Versioning** tab: Enable "Simple File Versioning", keep 5 versions
4. Click **Save**
5. Accept the folder share on the remote device

## Ignore Patterns

The `ignore-patterns.txt` file contains patterns for files to exclude:

- Python virtual environments (venv, __pycache__)
- Node.js modules (node_modules)
- IDE files (.vscode, .idea)
- Build artifacts (dist, build)
- macOS system files (.DS_Store)
- Git repositories (.git)
- Large files (*.zip, *.dmg)
- Databases (*.db, *.sqlite)

These patterns save space and prevent syncing unnecessary files.

## Configuration

### Reduce Battery Impact (MacBook Air)

On portable devices, optimize for battery life:

1. Open Syncthing UI
2. **Actions** > **Settings**
3. **Options** tab:
   - Start on Login: Enabled (optional)
   - Crash Reporting: Disabled
4. **Connections** tab:
   - Rate Limits: Set if needed
5. Per-folder settings:
   - **Advanced** > **Rescan Interval**: 300 seconds (5 min) instead of 60

### File Versioning

Enable versioning to protect against accidental deletions:

1. Click folder > **Edit**
2. **File Versioning** tab
3. Type: **Simple File Versioning**
4. Keep Versions: `5`

Deleted/changed files are kept in `.stversions/` folder.

### Folder Types

- **Send & Receive**: Two-way sync (default, use for most folders)
- **Send Only**: This device only sends updates
- **Receive Only**: This device only receives updates

Use **Send & Receive** for `~/projects` on both devices.

## Verification

### Check Sync Status

In Syncthing UI:
- Devices should show "Connected"
- Folders should show "Up to Date"
- Global state should match Local state

### Test Sync

**On MacBook Air:**
```bash
cd ~/projects
echo "Test from MacBook" > sync-test.txt
```

**On Mac Mini (wait a few seconds):**
```bash
cat ~/projects/sync-test.txt
# Should show: "Test from MacBook"
```

**Clean up:**
```bash
rm ~/projects/sync-test.txt
```

## Usage

### Start/Stop Syncthing

```bash
# Start
brew services start syncthing

# Stop
brew services stop syncthing

# Restart
brew services restart syncthing

# Check status
brew services list | grep syncthing
```

### Access Web UI

```bash
# Local
open http://localhost:8384

# Remote (via SSH tunnel to Mac Mini)
ssh -L 8385:localhost:8384 macmini
open http://localhost:8385
```

### View Logs

```bash
# Live logs
tail -f ~/Library/Logs/Homebrew/syncthing.log

# Or in Syncthing UI
# Actions > Logs
```

### Force Rescan

```bash
# In Syncthing UI
# Click folder > Rescan
```

## Multi-Device Setup

Syncthing works with any number of devices:

```
MacBook Air ←→ Mac Mini ←→ MacBook Pro
      ↑                          ↓
      └──────────────────────────┘
```

All devices can sync with each other. Changes propagate automatically.

## Security

- **Encryption**: All data transfer uses TLS encryption
- **No cloud**: Direct peer-to-peer, no central server
- **Device IDs**: Unique cryptographic identifiers
- **Local network**: Works great on same WiFi
- **Internet**: Also works over internet with port forwarding

## Best Practices

1. **Start small**: Sync one folder first, verify it works (i.e. dedicated `~/workspace` directory)
2. **Use ignore patterns**: Exclude build artifacts and large files
3. **Enable versioning**: Protect against accidental deletions
4. **Regular cleanup**: Remove old versions periodically
5. **Monitor conflicts**: Check for sync conflicts occasionally
6. **Backup important data**: Syncthing is not a backup solution

## Common Workflows

### New Project on MacBook Air

```bash
# Create project on MacBook Air
cd ~/workspace
mkdir my-new-project
cd my-new-project
git init

# Files automatically sync to Mac Mini
# Continue working on either device
```

### Work on Mac Mini, Continue on MacBook

```bash
# On Mac Mini
cd ~/workspace/myapp
git commit -am "Work in progress"

# Syncthing syncs to MacBook Air
# On MacBook Air (after sync completes)
cd ~/workspace/myapp
git pull  # Pull any remote changes if needed
# Continue working
```

### Resolve Conflicts

If both devices edit the same file simultaneously:

1. Syncthing creates `.sync-conflict` files
2. Review both versions
3. Merge manually
4. Delete conflict files

## Troubleshooting

See [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for solutions to:

- Devices won't connect
- Sync is slow
- Folders out of sync
- High CPU/battery usage
- Firewall issues
- Port conflicts

## Alternatives Considered

| Solution | Pros | Cons |
|----------|------|------|
| **Syncthing** | Free, peer-to-peer, encrypted | Setup required |
| iCloud Drive | Native macOS, easy | 5GB free limit, costs money |
| Dropbox | Easy to use | Costs money, 2GB free limit |
| Git | Version control | Manual commits/pushes |
| rsync | Fast, simple | Manual, no auto-sync |

Syncthing is best for automatic, continuous sync without cloud costs.

## Uninstall

```bash
# Stop service
brew services stop syncthing

# Uninstall
brew uninstall syncthing

# Remove data (optional)
rm -rf ~/Library/Application\ Support/Syncthing
rm -rf ~/.config/syncthing
```

## Related Projects

- [macbook-setup](https://github.com/bcolb/macbook-setup) - MacBook development environment
- [mac-mini-setup](https://github.com/bcolb/mac-mini-setup) - Mac Mini AI server setup
- [ssh-setup](https://github.com/bcolb/ssh-setup) - SSH configuration for Mac-to-Mac

## Contributing

Suggestions and improvements welcome! Please open an issue or pull request.

## Resources

- [Syncthing Documentation](https://docs.syncthing.net/)
- [Syncthing Forum](https://forum.syncthing.net/)
- [Syncthing GitHub](https://github.com/syncthing/syncthing)

## License

MIT

## Author

Brice Colbert

---

**Quick Start**: Run `bash setup-syncthing.sh` on each Mac, then connect them via the web UI at http://localhost:8384
