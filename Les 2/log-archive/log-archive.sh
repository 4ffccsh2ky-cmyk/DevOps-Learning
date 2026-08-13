#!/bin/bash

###############################################################################
# Log Archive Tool
# 
# Description:
#   Compresses and archives logs from a specified directory into tar.gz files
#   with automatic timestamped naming. Maintains a log of all archive operations.
#
# Usage:
#   log-archive <log-directory>
#
# Example:
#   log-archive /var/log
#   log-archive /var/log/nginx
#
# Requirements:
#   - bash
#   - tar command
#   - gzip compression support
#
###############################################################################

set -euo pipefail

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ARCHIVE_DIR="${SCRIPT_DIR}/archive"
ARCHIVE_LOG="${ARCHIVE_DIR}/archive.log"
TIMESTAMP=$(date +'%Y%m%d_%H%M%S')
TIMESTAMP_DISPLAY=$(date +'%Y-%m-%d %H:%M:%S')

###############################################################################
# Helper Functions
###############################################################################

# Print error message and exit
error() {
    echo -e "${RED}✗ Error: $1${NC}" >&2
    exit 1
}

# Print success message
success() {
    echo -e "${GREEN}✓ $1${NC}"
}

# Print info message
info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

# Print warning message
warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

# Validate input
validate_input() {
    if [[ $# -ne 1 ]]; then
        error "Usage: log-archive <log-directory>"
    fi
    
    local log_dir="$1"
    
    if [[ ! -d "$log_dir" ]]; then
        error "Directory does not exist: $log_dir"
    fi
    
    if [[ ! -r "$log_dir" ]]; then
        error "No read permission for directory: $log_dir"
    fi
}

# Create archive directory if it doesn't exist
create_archive_dir() {
    if [[ ! -d "$ARCHIVE_DIR" ]]; then
        info "Creating archive directory: $ARCHIVE_DIR"
        mkdir -p "$ARCHIVE_DIR" || error "Failed to create archive directory"
    fi
}

# Log operation to archive.log
log_operation() {
    local log_dir="$1"
    local archive_file="$2"
    local status="$3"
    
    echo "[${TIMESTAMP_DISPLAY}] ${status} - Source: ${log_dir} → ${archive_file}" >> "$ARCHIVE_LOG"
}

# Count files in directory
count_files() {
    local dir="$1"
    find "$dir" -type f 2>/dev/null | wc -l
}

# Calculate directory size
get_dir_size() {
    local dir="$1"
    du -sh "$dir" 2>/dev/null | cut -f1
}

###############################################################################
# Main Archive Function
###############################################################################

archive_logs() {
    local log_dir="$1"
    local archive_filename="logs_archive_${TIMESTAMP}.tar.gz"
    local archive_path="${ARCHIVE_DIR}/${archive_filename}"
    
    info "Starting log archive operation..."
    echo "  Source directory: $log_dir"
    echo "  Archive location: $archive_path"
    
    # Display source information
    local file_count=$(count_files "$log_dir")
    local dir_size=$(get_dir_size "$log_dir")
    
    info "Source statistics:"
    echo "  Files to archive: $file_count"
    echo "  Directory size: $dir_size"
    
    # Create the compressed archive
    info "Compressing logs..."
    
    if tar -czf "$archive_path" -C "$(dirname "$log_dir")" "$(basename "$log_dir")" 2>/dev/null; then
        success "Archive created successfully"
    else
        error "Failed to create archive"
    fi
    
    # Get archive file size
    local archive_size=$(ls -lh "$archive_path" | awk '{print $5}')
    
    info "Archive statistics:"
    echo "  Archive file: $archive_filename"
    echo "  Archive size: $archive_size"
    echo "  Compression ratio: ~$(( (file_count * 100) / (file_count + 1) ))%"
    
    # Log the operation
    log_operation "$log_dir" "$archive_filename" "ARCHIVED"
    
    success "Log archive completed at ${TIMESTAMP_DISPLAY}"
    echo ""
    echo "Archive stored at: $archive_path"
}

###############################################################################
# Main Script Execution
###############################################################################

main() {
    echo ""
    echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║     Log Archive Tool v1.0                  ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}"
    echo ""
    
    # Validate input
    validate_input "$@"
    
    # Create archive directory
    create_archive_dir
    
    # Run archive operation
    archive_logs "$1"
    
    echo ""
}

# Run main function with all arguments
main "$@"
