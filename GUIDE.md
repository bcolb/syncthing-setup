# Syncthing Setup Guide

Detailed step-by-step instructions for setting up Syncthing between multiple Macs.

## Table of Contents

1. [Installation](#installation)
2. [First-Time Configuration](#first-time-configuration)
3. [Connecting Devices](#connecting-devices)
4. [Sharing Folders](#sharing-folders)
5. [Ignore Patterns](#ignore-patterns)
6. [File Versioning](#file-versioning)
7. [Advanced Configuration](#advanced-configuration)
8. [Best Practices](#best-practices)

## Installation

### Automated

```bash
bash setup-syncthing.sh
```

### Manual

```bash
# Install Syncthing
brew install syncthing

# Start as background service
brew services start syncthing

# Verify it's running
brew services list | grep syncthing
```

### Verify Installation

```bash
# Check version
syncthing --version

# Check service status
brew services list | grep syncthing
# Should show: syncthing started

# Test API
curl http://localhost:8384/rest/system/status
# Should return JSON
```

## First-Time Configuration

### Access Web Interface

```bash
open http://localhost:8384
```

The web interface opens automatically when you run `setup-syncthing.sh`.

### Initial Setup Wizard

On first launch, you may see a setup wizard:

1. **Welcome Screen**: Click "Next"
2. **Usage Reporting**: Choose yes/no (optional)
3. **GUI Authentication**: 
   - Username: (optional, leave blank for local access)
   - Password: (optional, leave blank for local access)
4. Click "Finish"

### Get Your Device ID

Your Device ID is a unique identifier for this Mac:

1. Click **Actions** (top right) > **Show ID**
2. Copy the device ID
3. Or find it in the output of `setup-syncthing.sh`

Example Device ID:
```
ABCDEFG-HIJKLMN-OPQRSTU-VWXYZ12-3456789-ABCDEFG-HIJKLMN-OPQRSTU
```

### Set Device Name

1. Click **Actions** > **Settings**
2. **General** tab
3. **Device Name**: Enter a friendly name (e.g., "MacBook Air", "Mac Mini")
4. Click **Save**

## Connecting Devices

You need to connect devices before you can share folders between them.

### Method 1: Auto-Discovery (Easiest)

If both devices are on the same local network:

**On Both Devices:**
1. Make sure Syncthing is running
2. Wait 30-60 seconds
3. Look for "New Device" notification
4. Click the notification
5. Click **Add Device**
6. Give it a friendly name
7. Click **Save**

**Both devices should now show as "Connected"**

### Method 2: Manual Connection

If auto-discovery doesn't work:

**On MacBook Air (Device 1):**
1. Open http://localhost:8384
2. Click **Actions** > **Show ID**
3. Copy the Device ID

**On Mac Mini (Device 2):**
1. Open http://localhost:8384
2. Click **Add Remote Device** (bottom right)
3. Paste Device 1's ID into **Device ID** field
4. **Device Name**: "MacBook Air"
5. Leave other settings as default
6. Click **Save**

**On MacBook Air:**
1. You'll see notification: "Device 'Mac Mini' wants to connect"
2. Click **Add Device**
3. **Device Name**: "Mac Mini"
4. Click **Save**

**Verify Connection:**
- Both devices should show in the device list
- Status should be "Connected"
- Last Seen should be "now"

### Method 3: Using Device Introducer

If you have 3+ devices and one is already connected:

1. Edit an already-connected device
2. Enable **Introducer**
3. Save
4. This device will automatically introduce you to other devices it knows

## Sharing Folders

### Create a New Shared Folder

**On the device that has the folder (e.g., MacBook Air):**

1. Click **Add Folder** button
2. **General** tab:
   - **Folder Label**: "Projects" (display name)
   - **Folder ID**: auto-generated (leave as-is)
   - **Folder Path**: `/Users/yourusername/projects`
3. **Sharing** tab:
   - Check the box next to "Mac Mini" (or device name)
4. **File Versioning** tab:
   - Type: **Simple File Versioning**
   - Keep Versions: `5`
5. **Ignore Patterns** tab:
   - Copy patterns from `ignore-patterns.txt`
6. **Advanced** tab (optional):
   - Rescan Interval: `60` seconds (default) or higher to save battery
   - Folder Type: **Send & Receive** (default)
7. Click **Save**

**On the receiving device (e.g., Mac Mini):**

1. Wait for notification: "MacBook Air wants to share folder 'Projects'"
2. Click the notification
3. **Folder Path**: `/Users/yourusername/projects`
   - Choose same path or different path
   - If different, files will still sync to chosen location
4. Optionally review other settings
5. Click **Save**

**Wait for Initial Sync:**
- May take a few seconds to minutes depending on folder size
- Watch the progress in the web UI
- Folder should show "Up to Date" when complete

### Recommended Folders to Sync

| Folder | Path | Description |
|--------|------|-------------|
| Projects | `~/projects` | Code and development projects |
| Work Docs | `~/Documents/work` | Work-related documents |
| Scripts | `~/scripts` | Utility scripts |

### Folders NOT to Sync

- `~/Downloads` - Temporary files
- `~/Desktop` - Personal clutter
- `~/Pictures` - Use iCloud Photos
- `~/Music` - Too large
- `~/Library` - System files
- `/Applications` - Applications

## Ignore Patterns

Ignore patterns tell Syncthing which files to skip.

### Why Use Ignore Patterns?

- Save disk space (skip node_modules, build artifacts)
- Improve performance (fewer files to scan)
- Avoid conflicts (skip temporary files)
- Security (skip .env files with secrets)

### Add Ignore Patterns

**For a specific folder:**

1. Click folder name > **Edit**
2. Go to **Ignore Patterns** tab
3. Copy patterns from `ignore-patterns.txt`
4. Or add custom patterns
5. Click **Save**

**Using .stignore file:**

Create `.stignore` in the folder:

```bash
cd ~/projects
nano .stignore
```

Add patterns (one per line):
```
node_modules
__pycache__
.DS_Store
*.log
```

Syncthing automatically loads this file.

### Pattern Syntax

```
// Comment (ignored)
pattern           # Exact match
*.txt             # Wildcard
folder/           # Directory and contents
!important.txt    # Exclude from ignore (keep this file)
(?i)case          # Case-insensitive
```

### Common Patterns

See `ignore-patterns.txt` for comprehensive list.

Quick copy:
```
__pycache__
node_modules
.DS_Store
.git
.venv
*.log
.env
```

## File Versioning

File versioning keeps old versions of changed/deleted files.

### Enable Versioning

1. Click folder > **Edit**
2. **File Versioning** tab
3. **Type**: Choose versioning type

### Versioning Types

**Simple File Versioning** (Recommended):
- Keeps N most recent versions
- Oldest versions deleted automatically
- Set "Keep Versions": `5`

**Trashcan File Versioning**:
- Keeps files for N days
- Then deletes them
- Set "Clean out after": `30` days

**Staggered File Versioning**:
- Keeps versions at different intervals
- More recent = more versions
- Complex but space-efficient

**External File Versioning**:
- Custom script for versioning
- Advanced users only

### Where Are Versions Stored?

In `.stversions/` folder inside the synced folder:

```bash
~/projects/.stversions/
```

### Restore a Version

1. Open `.stversions/` folder
2. Find the file
3. Copy it back to the main folder
4. Or use Syncthing web UI: folder > **Versions** button

## Advanced Configuration

### Reduce Battery Impact (MacBook)

**Global Settings:**
1. **Actions** > **Settings**
2. **GUI** tab:
   - Enable "Start Browser": No (for battery)
3. **Connections** tab:
   - Rate Limits: Set if needed
   - NAT: Enable (helps with connections)

**Per-Folder Settings:**
1. Edit folder > **Advanced** tab
2. **Rescan Interval**: `300` (5 minutes) instead of 60 seconds
3. **FS Watcher**: Enabled (more efficient than scanning)

### Selective Sync

Only sync specific subdirectories:

1. Edit folder > **Ignore Patterns**
2. Ignore everything, then include specific folders:
```
*               # Ignore everything
!project-a/     # Include project-a
!project-b/     # Include project-b
```

### Network Configuration

**For LAN only (no internet sync):**
1. **Actions** > **Settings** > **Connections**
2. Disable **Enable Relaying**
3. Disable **Global Discovery**
4. Enable **Local Discovery**

**For Internet sync:**
- Keep all enabled
- May need port forwarding on router (port 22000)

### Custom Sync Schedule

Syncthing runs continuously by default. To pause:

1. Click folder > **Pause**
2. Or globally: **Actions** > **Pause All**
3. Resume when needed

Or use command line:
```bash
# Pause
brew services stop syncthing

# Resume
brew services start syncthing
```

### Multiple Profiles

To run multiple Syncthing instances (advanced):

```bash
syncthing --home=/path/to/config
```

## Best Practices

### Do's

✅ Start with one folder, verify it works
✅ Use ignore patterns liberally  
✅ Enable file versioning
✅ Set meaningful device and folder names
✅ Monitor sync conflicts regularly
✅ Keep Syncthing updated: `brew upgrade syncthing`

### Don'ts

❌ Don't sync system folders
❌ Don't sync running databases
❌ Don't sync very large files (use different tool)
❌ Don't sync Downloads folder
❌ Don't disable versioning on important folders
❌ Don't sync .git folders if using Git already

### Workflow Tips

1. **Make changes on one device at a time** when possible
2. **Commit to Git before major changes** for extra backup
3. **Check "Up to Date" before starting work** on a project
4. **Resolve conflicts promptly** when they occur
5. **Clean .stversions periodically** to save space

### Security Tips

1. **Use firewall** - Allow only Syncthing port (22000)
2. **Don't share device IDs publicly**
3. **Use GUI password** if device is shared
4. **Review connected devices** periodically
5. **Check folder permissions** - don't over-share

## Monitoring

### Check Sync Status

In web UI:
- Green = Up to date
- Yellow = Syncing
- Red = Error

### View Logs

```bash
# Live logs
tail -f ~/Library/Logs/Homebrew/syncthing.log

# Or in web UI
# Actions > Logs
```

### Check Conflicts

Conflicts appear as `.sync-conflict-*` files:

```bash
# Find conflicts
find ~/projects -name "*sync-conflict*"

# Review and resolve manually
```

### Statistics

Web UI shows:
- Global State: Total files/size
- Local State: Local files/size
- Out of Sync: Files not yet synced
- Download/Upload rates

## Next Steps

1. ✅ Install Syncthing on all devices
2. ✅ Connect devices
3. ✅ Share folders
4. ✅ Apply ignore patterns
5. ✅ Enable versioning
6. Test the sync
7. Monitor for conflicts
8. Enjoy automatic file sync!

For issues, see [TROUBLESHOOTING.md](TROUBLESHOOTING.md).
