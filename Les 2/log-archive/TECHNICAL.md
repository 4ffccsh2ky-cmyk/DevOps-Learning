# Log Archive Tool - Technical Documentation

## Overview

The Log Archive Tool is a bash-based CLI utility designed to compress and archive log files from specified directories. It focuses on:

- **Simplicity**: Single-purpose tool with clear, understandable code
- **Reliability**: Error handling and validation at each step
- **Traceability**: Comprehensive logging of all operations
- **Automation**: Integration with cron for scheduled runs
- **Performance**: Efficient compression using tar and gzip

---

## Architecture

### Component Structure

```
log-archive/
├── log-archive.sh          # Main archive tool
├── install.sh              # Installation helper
├── test.sh                 # Test suite
├── archive/                # Archive output directory
│   ├── *.tar.gz           # Compressed archives
│   └── archive.log        # Operation log
└── test-logs/             # Test data directory
```

### Data Flow

```
Input Directory
    ↓
Validation (exists, readable)
    ↓
Create Archive Directory
    ↓
Compress Files (tar -czf)
    ↓
Generate Timestamped Archive
    ↓
Log Operation
    ↓
Output Archive + Log Entry
```

---

## Core Functionality

### Main Script: `log-archive.sh`

#### Key Features

1. **Argument Validation**
   - Checks for exactly one argument
   - Verifies directory exists
   - Verifies read permissions

2. **Archive Creation**
   - Uses `tar -czf` for compression
   - Preserves directory structure
   - Timestamp-based naming: `logs_archive_YYYYMMDD_HHMMSS.tar.gz`

3. **Statistics Reporting**
   - File count in source directory
   - Source directory size
   - Archive file size
   - Estimated compression ratio

4. **Operation Logging**
   - Timestamped entries in `archive.log`
   - Human-readable format with operation details
   - Searchable and auditable

5. **Error Handling**
   - Uses `set -euo pipefail` for strict error mode
   - Validates inputs before operations
   - Clear error messages with exit codes
   - Safe exit on any error

#### Function Reference

| Function | Purpose |
|----------|---------|
| `error()` | Print error message and exit |
| `success()` | Print success message |
| `info()` | Print informational message |
| `warning()` | Print warning message |
| `validate_input()` | Check arguments and directory |
| `create_archive_dir()` | Ensure archive directory exists |
| `log_operation()` | Write entry to archive.log |
| `count_files()` | Count files in directory |
| `get_dir_size()` | Get directory size in human-readable format |
| `archive_logs()` | Main archive operation |

---

## Technical Details

### Bash Script Features Used

1. **Parameter Expansion**
   ```bash
   log_dir="$1"              # Positional parameter
   archive_path="${ARCHIVE_DIR}/${archive_filename}"  # Variable expansion
   ```

2. **Command Substitution**
   ```bash
   TIMESTAMP=$(date +'%Y%m%d_%H%M%S')  # Capture command output
   script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
   ```

3. **Process Substitution and Piping**
   ```bash
   tar -czf ... | gzip    # Standard tar compression
   find ... | wc -l       # Count files via pipeline
   ```

4. **String Manipulation**
   ```bash
   $(basename "$log_dir")  # Extract directory name
   $(dirname "$log_dir")   # Extract parent directory
   ```

5. **Conditional Logic**
   ```bash
   if [[ ! -d "$log_dir" ]]; then
       error "Directory does not exist: $log_dir"
   fi
   ```

6. **Error Handling**
   ```bash
   set -euo pipefail      # Exit on error, undefined vars, pipe failures
   ```

### Archive File Format

**Filename Pattern**: `logs_archive_YYYYMMDD_HHMMSS.tar.gz`

Example:
```
logs_archive_20240816_100648.tar.gz
  ├── Year: 2024
  ├── Month: 08
  ├── Day: 16
  ├── Hour: 10
  ├── Minute: 06
  └── Second: 48
```

**Compression Method**: tar + gzip (tar -czf)

**File Structure Preservation**: Archives maintain original directory hierarchy

Example archive contents:
```
tar -tzf logs_archive_20240816_100648.tar.gz
log/syslog
log/error.log
log/application.log
log/subsystem/audit.log
log/archive_1.log
log/archive_2.log
...
```

### Log Entry Format

Each entry in `archive.log` follows this format:

```
[YYYY-MM-DD HH:MM:SS] STATUS - Source: /path/to/source → archive_filename.tar.gz
```

Example:
```
[2024-08-16 10:06:48] ARCHIVED - Source: /var/log → logs_archive_20240816_100648.tar.gz
[2024-08-17 02:15:30] ARCHIVED - Source: /var/log → logs_archive_20240817_021530.tar.gz
```

---

## Installation Script: `install.sh`

### Features

1. **Flexible Installation**
   - Default: `/usr/local/bin`
   - Custom location support
   - Dry-run mode for testing

2. **Permission Management**
   - Detects need for sudo
   - Sets executable permissions
   - Validates write permissions

3. **Cron Integration**
   - Optional automatic cron setup
   - Checks for existing entries
   - Multiple schedule formats supported

### Installation Locations

| Location | Use Case | Requires Sudo |
|----------|----------|---------------|
| `/usr/local/bin` | System-wide, preferred | Yes |
| `/usr/bin` | System-wide, alternative | Yes |
| `~/.local/bin` | User-specific | No |
| Custom path | Special requirements | Depends |

---

## Test Script: `test.sh`

### Test Coverage

1. **Log File Creation**
   - Multiple log files of different types
   - Subdirectory structure
   - Various log formats

2. **Archive Operation**
   - Tests compression
   - Verifies timestamped naming
   - Validates log entries

3. **Verification**
   - Archive directory creation
   - Log file contents
   - File statistics

### Sample Data

The test script creates:
- `syslog.log` - System logs
- `error.log` - Application errors
- `application.log` - Application lifecycle
- `subsystem/audit.log` - Audit logs
- `archive_1.log` through `archive_5.log` - Multiple numbered logs

---

## Code Standards and Best Practices

### Implemented Best Practices

1. **Script Header Documentation**
   ```bash
   #!/bin/bash
   # Script description
   # Usage examples
   # Requirements
   ```

2. **Defensive Programming**
   - Input validation before processing
   - File existence checks
   - Permission validation
   - Error exit codes

3. **Code Organization**
   - Clear function separation
   - Logical grouping with comments
   - Helper functions before main logic

4. **Error Messages**
   - Clear and actionable
   - Include context (file paths, reasons)
   - Use color coding for visual distinction

5. **Logging and Traceability**
   - Timestamped entries
   - Human-readable format
   - Complete operation details

6. **Performance Considerations**
   - No unnecessary loops
   - Efficient pipe usage
   - Direct tar compression without intermediate files

---

## System Requirements

### Required Tools
```bash
bash        # Script interpreter (usually /bin/bash)
tar         # Archive creation and extraction
gzip        # Compression support (bundled with tar)
date        # Timestamp generation
find        # File finding and counting
du          # Directory size calculation
mkdir       # Directory creation
chmod       # Permission modification
```

### Minimum Environment
- Bash 3.0+ (most systems have 4.0+)
- Standard Unix utilities
- Read permissions on target log directory
- Write permissions for archive directory
- Sufficient disk space for compressed output

### Tested On
- Ubuntu 20.04 LTS
- Ubuntu 22.04 LTS
- CentOS 7 and 8
- Debian 10+
- Alpine Linux
- macOS 10.15+

---

## Error Handling and Exit Codes

### Exit Code Reference

| Code | Meaning |
|------|---------|
| 0 | Successful execution |
| 1 | General error (validation failed, operation failed) |

### Common Error Scenarios

1. **Missing Argument**
   ```
   ✗ Error: Usage: log-archive <log-directory>
   ```
   Occurs when: No directory provided as argument

2. **Directory Not Found**
   ```
   ✗ Error: Directory does not exist: /path/to/logs
   ```
   Occurs when: Specified directory doesn't exist

3. **Permission Denied**
   ```
   ✗ Error: No read permission for directory: /var/log
   ```
   Occurs when: User lacks read permissions

4. **Archive Creation Failed**
   ```
   ✗ Error: Failed to create archive
   ```
   Occurs when: Disk full, permission issues, or tar failure

---

## Security Considerations

### File Permissions

Archives should be protected based on sensitivity:
```bash
# Restrictive (for sensitive logs)
chmod 600 archive/logs_archive_*.tar.gz

# Standard (readable by user only)
chmod 644 archive/logs_archive_*.tar.gz

# Shared (readable by group)
chmod 640 archive/logs_archive_*.tar.gz
```

### Directory Permissions
```bash
# Archive directory should be restricted
chmod 700 archive/

# Or shared with specific group
chmod 750 archive/
chgrp logarchive archive/
```

### Sensitive Information

- Archives contain full log files (may include sensitive data)
- Store archives securely
- Encrypt archives if on untrusted storage
- Set restrictive file permissions
- Consider removing archives after retention period

---

## Performance Characteristics

### Compression Efficiency

Typical compression ratios for text logs:
- System logs: 90-95% compression
- Application logs: 85-95% compression
- Complex/binary logs: 50-80% compression

### Time Complexity

- Reading files: O(n) where n = file count
- Compression: O(n × m) where m = average file size
- Logging: O(1) constant time

### Space Complexity

Archives consume approximately 5-15% of original log size.

Example:
```
Original logs: 156 MB
Compressed: 34 MB (22% of original)
Compression ratio: 78%
```

---

## Integration Examples

### Shell Alias
```bash
alias log-archive="/path/to/log-archive.sh"
```

### Function in `.bashrc`
```bash
archive-logs() {
    /path/to/log-archive.sh "$1"
}
```

### Systemd Timer (Alternative to Cron)
```ini
[Unit]
Description=Log Archive Service
After=network.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/log-archive /var/log
StandardOutput=journal

[Install]
WantedBy=multi-user.target
```

### Wrapper Script
```bash
#!/bin/bash
# Archive multiple log directories
log-archive /var/log
log-archive /var/log/nginx
log-archive /opt/app/logs
```

---

## Maintenance and Monitoring

### Archive Cleanup
```bash
# Remove archives older than 30 days
find archive/ -name "*.tar.gz" -mtime +30 -delete

# Keep only last 10 archives
ls -1t archive/*.tar.gz | tail -n +11 | xargs rm
```

### Monitor Disk Usage
```bash
# Check archive directory size
du -sh archive/

# Monitor growth over time
watch -n 300 'du -sh archive/'
```

### Verify Archive Integrity
```bash
# List contents without extraction
tar -tzf archive/logs_archive_*.tar.gz | head -20

# Test archive
tar -tzf archive/logs_archive_*.tar.gz > /dev/null && echo "Archive OK"
```

---

## Troubleshooting Guide

### Script Not Executing

**Problem**: `Permission denied`

**Solution**:
```bash
chmod +x log-archive.sh
```

### Archive Fails with Permission Error

**Problem**: Cannot create archive directory or read logs

**Solution**:
```bash
# Run with sudo
sudo bash log-archive.sh /var/log

# Or set proper directory permissions
chmod g+rx archive/
```

### Cron Job Not Running

**Problem**: Archive not created at scheduled time

**Solution**:
1. Verify cron entry:
   ```bash
   crontab -l | grep log-archive
   ```

2. Check cron logs:
   ```bash
   grep CRON /var/log/syslog
   ```

3. Test command manually:
   ```bash
   /path/to/log-archive.sh /var/log
   ```

### Disk Space Issues

**Problem**: Cannot create archive due to disk space

**Solution**:
1. Check available space:
   ```bash
   df -h /path/to/archive
   ```

2. Clean old archives:
   ```bash
   find archive/ -name "*.tar.gz" -mtime +30 -delete
   ```

3. Archive to external storage

---

## Future Enhancements

Potential improvements:
1. Compression level control (gzip -1 through -9)
2. Retention policy automation
3. Remote backup support
4. Email notifications
5. Parallel archive creation for multiple directories
6. Archive encryption
7. Incremental backup support
8. Web dashboard for monitoring
9. Metrics collection and reporting
10. Integration with cloud storage (S3, Azure Blob, etc.)

---

## References

- [Bash Manual](https://www.gnu.org/software/bash/manual/)
- [tar Manual](https://linux.die.net/man/1/tar)
- [gzip Manual](https://linux.die.net/man/1/gzip)
- [crontab Manual](https://linux.die.net/man/5/crontab)
- [Linux File System Hierarchy](https://www.pathname.com/fhs/)

---

## License and Contribution

This tool is provided as-is for educational and practical purposes. Feel free to modify and extend it for your specific needs.
