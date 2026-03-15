# Syncthing Troubleshooting

Solutions to common issues when running Syncthing on macOS.

## Connection Issues

### Devices Won't Connect

**Problem:** Devices don't see each other or won't connect

**Solutions:**

1. **Verify both are running**
   ```bash
   # On both devices
   brew services list | grep syncthing
   # Should show: started
   ```

2. **Check firewall**
   ```bash
   # System Settings > Network > Firewall
   # Allow Syncthing
   
   # Or temporarily disable to test
   sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate off
   ```

3. **Manually add device**
   - Get Device ID from Actions > Show ID
   - On other device: Add Remote Device
   - Paste Device ID
   - Save and accept on both sides

4. **Check same network**
   ```bash
   # On MacBook Air
   ping macmini.local
   
   # Should get replies
   ```

5. **Try direct IP connection**
   - Actions > Settings > Connections
   - Add: `tcp://192.168.1.100:22000` (Mac Mini IP)

6. **Enable relay**
   - Actions > Settings > Connections
   - Enable "Enable Relaying"
   - Enable "Global Discovery"

### Connection Keeps Dropping

**Problem:** Devices connect then disconnect repeatedly

**Solutions:**

1. **Increase timeout**
   - Actions > Settings > Advanced
   - Increase "Connection Timeout"

2. **Check network stability**
   ```bash
   ping -c 100 macmini.local
   # Look for packet loss
   ```

3. **Disable power saving**
   - System Settings > Battery
   - Prevent sleeping on AC power
   - Disable "Put hard disks to sleep"

4. **Check for VPN interference**
   - Temporarily disable VPN to test
   - Configure VPN to allow local network

## Sync Issues

### Files Not Syncing

**Problem:** Files not syncing between devices

**Solutions:**

1. **Check folder status**
   - Should show "Up to Date"
   - If "Scanning" or "Syncing" wait for completion

2. **Force rescan**
   - Click folder > **Rescan**
   - Or: Actions > Rescan All

3. **Check ignore patterns**
   - Edit folder > Ignore Patterns
   - Ensure file isn't ignored
   - Test: Remove all patterns temporarily

4. **Check permissions**
   ```bash
   # On both devices
   ls -la ~/projects
   # Should be readable/writable by your user
   ```

5. **Check disk space**
   ```bash
   df -h
   # Ensure sufficient space
   ```

6. **Check for errors**
   - Actions > Logs
   - Look for error messages

### Sync is Very Slow

**Problem:** Files sync but very slowly

**Solutions:**

1. **Check network speed**
   ```bash
   # Test bandwidth between devices
   iperf3 -s    # On Mac Mini
   iperf3 -c macmini-ip    # On MacBook
   ```

2. **Reduce rescan interval**
   - Edit folder > Advanced
   - Increase "Rescan Interval" to 300 (5 min)

3. **Enable FS Watcher**
   - Edit folder > Advanced
   - Enable "Watch for Changes"
   - More efficient than scanning

4. **Check CPU usage**
   ```bash
   top | grep syncthing
   # If high CPU, may be scanning large folder
   ```

5. **Limit scan depth**
   - Edit folder > Advanced
   - Add subdirectories to ignore patterns if very deep

6. **Use wired connection**
   - Connect both Macs via Ethernet
   - Much faster than WiFi

### Folder Shows "Out of Sync"

**Problem:** Folder status shows items out of sync

**Solutions:**

1. **Wait for sync to complete**
   - Initial sync takes time
   - Check progress in web UI

2. **Check for conflicts**
   ```bash
   find ~/projects -name "*sync-conflict*"
   # Resolve conflicts manually
   ```

3. **Override changes**
   - If one device should win:
   - Edit folder > Advanced > **Override Changes**
   - Select which device to keep

4. **Check for errors**
   - Click "Out of Sync Items" to see specific files
   - May show permission errors or path issues

## File Conflicts

### Sync Conflict Files Appearing

**Problem:** Files named `.sync-conflict-*` appearing

**Cause:** Same file edited on both devices before sync

**Solutions:**

1. **Find conflicts**
   ```bash
   find ~/projects -name "*sync-conflict*"
   ```

2. **Review both versions**
   ```bash
   # Original
   cat file.txt
   
   # Conflict
   cat file.sync-conflict-20260314-123456.txt
   ```

3. **Merge manually**
   - Open both files
   - Merge changes
   - Delete conflict file

4. **Prevention**
   - Work on one device at a time
   - Check "Up to Date" before editing
   - Enable file versioning

### How to Prevent Conflicts

1. **Use Git for code**
   - Commit before syncing
   - Syncthing syncs the Git repo
   - Git handles merges

2. **Work sequentially**
   - Finish on one device
   - Wait for sync
   - Then work on other device

3. **File locking (advanced)**
   - Not natively supported
   - Use external tools if needed

## Performance Issues

### High CPU Usage

**Problem:** Syncthing using too much CPU

**Solutions:**

1. **Check what it's doing**
   ```bash
   # In web UI: Actions > Logs
   # Look for "Scanning" or "Hashing"
   ```

2. **Increase rescan interval**
   - Edit folder > Advanced
   - Set "Rescan Interval" to 300 or 600

3. **Reduce folder size**
   - Split large folders into smaller ones
   - Add more ignore patterns

4. **Disable FS Watcher if causing issues**
   - Edit folder > Advanced
   - Disable "Watch for Changes"

5. **Limit concurrent scans**
   - Actions > Settings > Advanced
   - Reduce "Max Concurrent Scans"

### High Battery Drain (MacBook)

**Problem:** Syncthing draining battery quickly

**Solutions:**

1. **Increase rescan interval**
   - 300 seconds (5 min) or more
   - Per folder: Edit > Advanced > Rescan Interval

2. **Pause when on battery**
   ```bash
   # Create script to pause/resume based on power
   if pmset -g batt | grep -q "Battery Power"; then
       brew services stop syncthing
   else
       brew services start syncthing
   fi
   ```

3. **Reduce global discovery**
   - Actions > Settings > Connections
   - Set "Global Discovery Servers" to just 1 or 2

4. **Use local discovery only**
   - Disable "Global Discovery"
   - Keep "Local Discovery"
   - Only syncs on same network

### High Disk Usage

**Problem:** `.stversions` folder using too much space

**Solutions:**

1. **Check versions size**
   ```bash
   du -sh ~/projects/.stversions
   ```

2. **Clean old versions**
   ```bash
   # Remove all versions older than 30 days
   find ~/projects/.stversions -mtime +30 -delete
   ```

3. **Reduce version count**
   - Edit folder > File Versioning
   - Reduce "Keep Versions" from 5 to 2

4. **Switch versioning type**
   - Use "Trashcan" with shorter retention
   - Or disable versioning (not recommended)

## Installation Issues

### Homebrew Installation Fails

**Problem:** `brew install syncthing` fails

**Solutions:**

1. **Update Homebrew**
   ```bash
   brew update
   brew upgrade
   brew doctor
   ```

2. **Clear cache**
   ```bash
   brew cleanup
   rm -rf $(brew --cache)
   ```

3. **Manual install**
   - Download from https://syncthing.net/downloads/
   - Extract to ~/Applications
   - Run from Terminal

### Service Won't Start

**Problem:** `brew services start syncthing` fails

**Solutions:**

1. **Check logs**
   ```bash
   cat ~/Library/Logs/Homebrew/syncthing.log
   ```

2. **Kill existing process**
   ```bash
   pkill syncthing
   brew services start syncthing
   ```

3. **Check permissions**
   ```bash
   chmod +x $(which syncthing)
   ```

4. **Reinstall**
   ```bash
   brew services stop syncthing
   brew uninstall syncthing
   brew install syncthing
   brew services start syncthing
   ```

## Web UI Issues

### Can't Access Web UI

**Problem:** http://localhost:8384 doesn't load

**Solutions:**

1. **Check if running**
   ```bash
   curl http://localhost:8384/rest/system/status
   # Should return JSON
   ```

2. **Check port not in use**
   ```bash
   lsof -i :8384
   # Should show syncthing process
   ```

3. **Try different port**
   ```bash
   # Edit config
   nano ~/.config/syncthing/config.xml
   # Change <address>127.0.0.1:8384</address> to :8385
   # Restart
   brew services restart syncthing
   ```

4. **Clear browser cache**
   - Hard refresh: Cmd+Shift+R
   - Or try different browser

### Web UI Shows Error

**Problem:** Web UI loads but shows errors

**Solutions:**

1. **Restart Syncthing**
   ```bash
   brew services restart syncthing
   ```

2. **Check config file**
   ```bash
   # Backup first
   cp ~/.config/syncthing/config.xml ~/.config/syncthing/config.xml.backup
   
   # Check for errors
   cat ~/.config/syncthing/config.xml
   ```

3. **Reset to defaults**
   ```bash
   # CAUTION: This removes all configuration
   brew services stop syncthing
   mv ~/.config/syncthing ~/.config/syncthing.backup
   brew services start syncthing
   ```

## Firewall Issues

### Firewall Blocking Syncthing

**Problem:** macOS firewall blocking connections

**Solutions:**

1. **Allow Syncthing**
   - System Settings > Network > Firewall
   - Click Options
   - Click + to add Syncthing
   - Allow incoming connections

2. **Check firewall logs**
   ```bash
   log show --predicate 'process == "socketfilterfw"' --last 1h
   ```

3. **Temporarily disable to test**
   ```bash
   sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate off
   # Test
   # Re-enable
   sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on
   ```

## Network Issues

### Port Already in Use

**Problem:** Error: "Port 22000 already in use"

**Solutions:**

1. **Find process using port**
   ```bash
   lsof -i :22000
   ```

2. **Kill the process**
   ```bash
   kill [PID]
   ```

3. **Use different port**
   - Actions > Settings > Connections
   - Change "Sync Protocol Listen Addresses"
   - From `:22000` to `:22001`

### NAT Traversal Issues

**Problem:** Devices can't connect over internet

**Solutions:**

1. **Enable UPnP on router**
   - Login to router
   - Enable UPnP/NAT-PMP

2. **Manual port forwarding**
   - Forward port 22000 TCP/UDP to Mac Mini
   - Forward port 22000 TCP/UDP to MacBook (if needed)

3. **Use relay servers**
   - Actions > Settings > Connections
   - Enable "Enable Relaying"
   - Slower but works everywhere

## Data Issues

### Lost Data / Accidentally Deleted

**Problem:** Files deleted and need recovery

**Solutions:**

1. **Check file versioning**
   ```bash
   ls -la ~/projects/.stversions
   ```

2. **Restore from version**
   - Find file in `.stversions`
   - Copy back to original location

3. **Check other devices**
   - If file deleted recently, may still exist on another device
   - Pause sync on that device
   - Copy file before it syncs deletion

4. **Use Time Machine**
   - If enabled, restore from backup

### Folder Reset Itself

**Problem:** Folder suddenly empty or reset

**Cause:** Usually accidental "Override Changes"

**Solutions:**

1. **Don't panic - check other devices**
   - Files likely still on another device
   - Pause sync there immediately

2. **Check `.stversions`**
   ```bash
   ls -la ~/projects/.stversions
   ```

3. **Restore from backup**
   - Time Machine
   - Or manual backups

4. **Prevention**
   - Enable file versioning
   - Use Time Machine
   - Be careful with "Override Changes"

## Diagnostic Commands

```bash
# Check Syncthing version
syncthing --version

# Check service status
brew services list | grep syncthing

# View live logs
tail -f ~/Library/Logs/Homebrew/syncthing.log

# API status
curl http://localhost:8384/rest/system/status | jq

# Check connections
curl http://localhost:8384/rest/system/connections | jq

# List folders
curl http://localhost:8384/rest/system/config | jq .folders

# Check CPU/memory
ps aux | grep syncthing

# Network connections
lsof -i -P | grep syncthing

# Find all sync conflicts
find ~ -name "*sync-conflict*"
```

## Getting More Help

1. **Check official docs**: https://docs.syncthing.net/
2. **Syncthing forum**: https://forum.syncthing.net/
3. **GitHub issues**: https://github.com/syncthing/syncthing/issues
4. **Logs**: Actions > Logs in web UI
5. **Debug mode**: 
   ```bash
   syncthing --debug
   ```

## Common Error Messages

| Error | Solution |
|-------|----------|
| "Permission denied" | Check folder permissions: `chmod 755 ~/projects` |
| "No space left on device" | Free up disk space |
| "Connection refused" | Check firewall, verify Syncthing running |
| "Database error" | Restart Syncthing, may need to reset folder |
| "Ignoring path" | Check ignore patterns |

Remember: When in doubt, restart Syncthing:
```bash
brew services restart syncthing
```
