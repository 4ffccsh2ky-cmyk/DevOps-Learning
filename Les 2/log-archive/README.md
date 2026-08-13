# Log Archive Tool

A command-line utility to compress and archive logs on a scheduled basis. This tool helps maintain clean systems by compressing old logs while preserving them for future reference.

## Features

- Compress logs into tar.gz format
- Automatic timestamped archive naming
- Centralized archive storage directory
- Operation logging with date/time
- Simple command-line interface

## Installation

### Option 1: Direct Usage (No Installation)
```bash
bash log-archive.sh /var/log
```

### Option 2: Make it Executable and Add to PATH
```bash
# Make the script executable
chmod +x log-archive.sh

# Copy to a directory in your PATH (e.g., /usr/local/bin)
sudo cp log-archive.sh /usr/local/bin/log-archive

# Or create a symlink
sudo ln -s $(pwd)/log-archive.sh /usr/local/bin/log-archive

# Now you can run it directly
log-archive /var/log
```

## Usage

### Basic Usage
```bash
log-archive <log-directory>
```

### Examples

Archive system logs:
```bash
log-archive /var/log
```

Archive application logs:
```bash
log-archive /var/log/nginx
```

Archive logs with full path:
```bash
log-archive /home/user/app-logs
```

## Output

The tool creates:
1. **Archive file**: `logs_archive_YYYYMMDD_HHMMSS.tar.gz` in the `./archive` directory
2. **Log file**: `archive.log` tracking all archive operations with timestamps

Example archive directory structure:
```
archive/
├── logs_archive_20240816_100648.tar.gz
├── logs_archive_20240817_150230.tar.gz
└── archive.log
```

## Archive Log Format

The `archive.log` file records each archive operation:
```
[2024-08-16 10:06:48] Archived /var/log → logs_archive_20240816_100648.tar.gz
[2024-08-17 15:02:30] Archived /var/log → logs_archive_20240817_150230.tar.gz
```

## Scheduling with Cron

To run the tool automatically on a schedule, use cron:

### Edit crontab
```bash
crontab -e
```

### Examples

Archive logs daily at 2 AM:
```cron
0 2 * * * /usr/local/bin/log-archive /var/log
```

Archive logs every Sunday at 3 AM:
```cron
0 3 * * 0 /usr/local/bin/log-archive /var/log
```

Archive logs every 6 hours:
```cron
0 */6 * * * /usr/local/bin/log-archive /var/log
```

## Requirements

- Bash shell
- `tar` command
- `gzip` compression (included with tar)
- Read permissions on the log directory
- Write permissions in the script's directory (for the archive folder)

## Error Handling

The tool handles various error conditions:
- **Invalid directory**: Shows error if the provided directory doesn't exist
- **Permission issues**: Reports if unable to read or write
- **Missing dependencies**: Checks for required commands

## Permissions

- To archive system logs in `/var/log`, you may need to run with `sudo`
- Ensure the script has write permission to create the archive directory

## Notes

- Archives are stored in a `./archive` directory relative to where the script is run
- Each archive is independently compressed and timestamped
- The archive.log file helps track all archive operations for auditing purposes
- Compressed logs maintain the original directory structure within the tar.gz
