# Log Archive Tool - Quick Start Guide

## 5-Minute Quick Start

### 1. Make Scripts Executable
```bash
cd log-archive
chmod +x log-archive.sh test.sh install.sh
```

### 2. Test the Tool (No Installation Required)
```bash
# Run the test script to see it in action
bash test.sh
```

This will:
- Create sample log files in `test-logs/`
- Archive them into `archive/logs_archive_YYYYMMDD_HHMMSS.tar.gz`
- Create an `archive.log` file with operation logs

### 3. Use the Tool
```bash
# Archive your own logs
bash log-archive.sh /var/log

# Or archive application-specific logs
bash log-archive.sh /var/log/nginx
bash log-archive.sh /var/log/apache2
```

---

## Running Examples

### Example 1: Basic Usage
```bash
$ bash log-archive.sh /var/log

╔════════════════════════════════════════════╗
║     Log Archive Tool v1.0                  ║
╚════════════════════════════════════════════╝

ℹ Starting log archive operation...
  Source directory: /var/log
  Archive location: /home/user/log-archive/archive/logs_archive_20240816_100648.tar.gz
ℹ Source statistics:
  Files to archive: 245
  Directory size: 156M
ℹ Compressing logs...
✓ Archive created successfully
ℹ Archive statistics:
  Archive file: logs_archive_20240816_100648.tar.gz
  Archive size: 34M
  Compression ratio: ~99%

✓ Log archive completed at 2024-08-16 10:06:48

Archive stored at: /home/user/log-archive/archive/logs_archive_20240816_100648.tar.gz
```

### Example 2: Archive Directory Structure
```bash
$ cd archive
$ ls -lh

total 102M
-rw-r--r-- 1 user group 34M Aug 16 10:06 logs_archive_20240816_100648.tar.gz
-rw-r--r-- 1 user group 28M Aug 15 02:15 logs_archive_20240815_021530.tar.gz
-rw-r--r-- 1 user group 40M Aug 14 02:05 logs_archive_20240814_020530.tar.gz
-rw-r--r-- 1 user group 1.2K Aug 16 10:06 archive.log

$ cat archive.log
[2024-08-14 02:05:30] ARCHIVED - Source: /var/log → logs_archive_20240814_020530.tar.gz
[2024-08-15 02:15:15] ARCHIVED - Source: /var/log → logs_archive_20240815_021530.tar.gz
[2024-08-16 10:06:48] ARCHIVED - Source: /var/log → logs_archive_20240816_100648.tar.gz
```

### Example 3: Extract and View Archived Logs
```bash
# Extract archive to temporary location
tar -xzf archive/logs_archive_20240816_100648.tar.gz -C /tmp

# View specific archived log
cat /tmp/log/syslog

# Search in archived logs
grep "error" /tmp/log/*.log

# Clean up
rm -rf /tmp/log
```

---

## Installation Methods

### Method 1: System-Wide Installation (Recommended for Regular Use)
```bash
# Copy the script to a system location
sudo bash install.sh

# Now use it from anywhere
log-archive /var/log
```

### Method 2: Add Custom Location to PATH
```bash
# Add to your shell profile (~/.bashrc or ~/.zshrc)
export PATH="/home/user/log-archive:$PATH"

# Then reload
source ~/.bashrc

# Use from anywhere
log-archive /var/log
```

### Method 3: Create Alias
```bash
# Add to ~/.bashrc
alias log-archive="/path/to/log-archive/log-archive.sh"

# Reload
source ~/.bashrc

# Use
log-archive /var/log
```

---

## Automation with Cron

### Setup Automated Daily Backups
```bash
# Edit crontab
crontab -e

# Add one of these lines:

# Run daily at 2 AM
0 2 * * * /usr/local/bin/log-archive /var/log

# Run daily at 2 AM and log output
0 2 * * * /usr/local/bin/log-archive /var/log >> /var/log/archive-cron.log 2>&1

# Run every 6 hours
0 */6 * * * /usr/local/bin/log-archive /var/log

# Run weekly (every Sunday at 3 AM)
0 3 * * 0 /usr/local/bin/log-archive /var/log
```

### Monitor Cron Execution
```bash
# View cron logs (on Linux)
grep CRON /var/log/syslog

# View execution history
cat /var/log/archive-cron.log
```

---

## Common Use Cases

### 1. Archive Nginx Logs
```bash
log-archive /var/log/nginx
```

### 2. Archive Apache Logs
```bash
log-archive /var/log/apache2
```

### 3. Archive Application Logs
```bash
log-archive /opt/myapp/logs
```

### 4. Archive Multiple Log Directories (Script)
```bash
#!/bin/bash
log-archive /var/log
log-archive /var/log/nginx
log-archive /var/log/apache2
```

---

## Troubleshooting

### Permission Denied Error
```
✗ Error: No read permission for directory: /var/log
```

**Solution:** Run with `sudo`
```bash
sudo log-archive /var/log
```

### Directory Not Found
```
✗ Error: Directory does not exist: /path/to/logs
```

**Solution:** Verify the path exists
```bash
ls -la /path/to/logs
log-archive /var/log  # Use correct path
```

### Disk Space Issues
If the archive is too large for available disk space:

1. Check available space:
   ```bash
   df -h
   ```

2. Options:
   - Delete old archives
   - Archive to external drive
   - Rotate archives more frequently

---

## File Descriptions

| File | Purpose |
|------|---------|
| `log-archive.sh` | Main archive tool script |
| `install.sh` | Installation and cron setup script |
| `test.sh` | Test script to verify functionality |
| `README.md` | Complete documentation |
| `EXAMPLES.md` | Usage examples and tutorials |
| `archive/` | Output directory for compressed archives |
| `archive/archive.log` | Log of all archive operations |

---

## Best Practices

1. **Regular Backups**: Schedule archives during low-activity periods (e.g., 2 AM)

2. **Monitor Disk Space**: Keep an eye on archive directory size
   ```bash
   du -sh archive/
   ```

3. **Verify Archives**: Periodically test extraction
   ```bash
   tar -tzf archive/logs_archive_*.tar.gz | head
   ```

4. **Retention Policy**: Delete old archives periodically
   ```bash
   # Remove archives older than 30 days
   find archive/ -name "*.tar.gz" -mtime +30 -delete
   ```

5. **Secure Archives**: Set appropriate permissions
   ```bash
   chmod 600 archive/*.tar.gz
   ```

6. **Backup Archives**: Copy compressed files to external storage
   ```bash
   cp -r archive/ /backup/location/
   ```

---

## Performance Tips

- **Archive during off-peak hours** to minimize system impact
- **Use fast storage** for archive directory if possible
- **Monitor compression ratio** - if too low, investigate log sizes
- **Clean old archives regularly** to manage disk space

---

## Next Steps

1. Run the test script: `bash test.sh`
2. Try archiving your own logs: `bash log-archive.sh /var/log`
3. Install system-wide: `sudo bash install.sh`
4. Setup cron scheduling for automation
5. Review logs in `archive/archive.log`

Questions? Check [README.md](README.md) for detailed documentation.
