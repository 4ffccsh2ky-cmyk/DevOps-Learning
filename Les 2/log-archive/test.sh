#!/bin/bash

###############################################################################
# Log Archive Tool - Test Script
#
# Description:
#   Creates test log files and directories, then runs the log-archive tool
#   to demonstrate its functionality.
#
# Usage:
#   bash test.sh
#
###############################################################################

set -euo pipefail

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEST_LOG_DIR="${SCRIPT_DIR}/test-logs"
ARCHIVE_DIR="${SCRIPT_DIR}/archive"

# Helper functions
error() {
    echo -e "${RED}✗ Error: $1${NC}" >&2
    exit 1
}

success() {
    echo -e "${GREEN}✓ $1${NC}"
}

info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

# Cleanup function
cleanup() {
    if [[ -d "$TEST_LOG_DIR" ]]; then
        rm -rf "$TEST_LOG_DIR"
        info "Cleaned up test log directory"
    fi
}

# Create test logs
create_test_logs() {
    info "Creating test log files..."
    
    mkdir -p "$TEST_LOG_DIR"
    
    # Create various test log files
    cat > "$TEST_LOG_DIR/syslog.log" << 'EOF'
[2024-08-16 10:05:00] System started
[2024-08-16 10:05:15] Network interface initialized
[2024-08-16 10:05:30] SSH daemon started
[2024-08-16 10:06:00] User login successful
[2024-08-16 10:07:00] Cron job executed
[2024-08-16 10:08:00] Disk space check: 75% used
[2024-08-16 10:09:00] Memory check: 4.2GB/8GB
EOF
    
    cat > "$TEST_LOG_DIR/error.log" << 'EOF'
[2024-08-16 09:45:00] WARNING: High memory usage detected
[2024-08-16 10:00:00] ERROR: Database connection timeout
[2024-08-16 10:02:00] WARNING: Slow query detected
[2024-08-16 10:04:00] INFO: Database recovery initiated
[2024-08-16 10:05:00] INFO: Database recovered successfully
EOF
    
    cat > "$TEST_LOG_DIR/application.log" << 'EOF'
[2024-08-16 10:00:00] Application started
[2024-08-16 10:00:15] Loading configuration...
[2024-08-16 10:00:20] Configuration loaded successfully
[2024-08-16 10:00:25] Connecting to database...
[2024-08-16 10:00:30] Database connected
[2024-08-16 10:00:35] Starting API server on port 8080
[2024-08-16 10:00:40] Server ready to accept requests
EOF
    
    # Create a subdirectory with more logs
    mkdir -p "$TEST_LOG_DIR/subsystem"
    
    cat > "$TEST_LOG_DIR/subsystem/audit.log" << 'EOF'
[2024-08-16 09:50:00] User 'admin' accessed file: /etc/passwd
[2024-08-16 09:51:00] User 'app' modified file: config.yml
[2024-08-16 09:52:00] Failed login attempt from 192.168.1.100
[2024-08-16 09:53:00] User 'root' executed command: systemctl restart nginx
[2024-08-16 09:54:00] Policy violation: Unauthorized access attempt
EOF
    
    # Create additional logs to increase file count
    for i in {1..5}; do
        cat > "$TEST_LOG_DIR/archive_${i}.log" << EOF
[2024-08-16 10:$(printf "%02d" $i):00] Archive log entry $i
[2024-08-16 10:$(printf "%02d" $i):15] Processing batch $i
[2024-08-16 10:$(printf "%02d" $i):30] Batch $i completed
EOF
    done
    
    success "Test log files created in: $TEST_LOG_DIR"
    info "Files created:"
    find "$TEST_LOG_DIR" -type f -exec echo "  {}" \;
}

# Display test results
display_results() {
    echo ""
    echo -e "${BLUE}════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  Test Results${NC}"
    echo -e "${BLUE}════════════════════════════════════════════${NC}"
    echo ""
    
    if [[ -d "$ARCHIVE_DIR" && -f "${ARCHIVE_DIR}/archive.log" ]]; then
        success "Archive directory created"
        echo ""
        
        info "Archive contents:"
        ls -lh "$ARCHIVE_DIR"/ | tail -n +2 || true
        echo ""
        
        info "Archive log entries:"
        cat "${ARCHIVE_DIR}/archive.log"
        echo ""
        
        # Show archive statistics
        if [[ -f "${ARCHIVE_DIR}"/*.tar.gz ]]; then
            local archive_file=$(ls -1 "${ARCHIVE_DIR}"/*.tar.gz | head -1)
            local archive_size=$(ls -lh "$archive_file" | awk '{print $5}')
            
            info "Archive file details:"
            echo "  File: $(basename "$archive_file")"
            echo "  Size: $archive_size"
            echo ""
            
            info "To extract the archive:"
            echo "  tar -xzf \"$archive_file\" -C /tmp"
            echo ""
        fi
    else
        echo -e "${RED}✗ Archive operation did not complete successfully${NC}"
    fi
}

# Main test execution
main() {
    echo ""
    echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║   Log Archive Tool - Test Script           ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}"
    echo ""
    
    # Check if log-archive script exists
    if [[ ! -f "${SCRIPT_DIR}/log-archive.sh" ]]; then
        error "log-archive.sh not found in $SCRIPT_DIR"
    fi
    
    # Cleanup previous test data
    if [[ -d "$TEST_LOG_DIR" ]]; then
        info "Removing previous test logs..."
        rm -rf "$TEST_LOG_DIR"
    fi
    
    # Create test logs
    create_test_logs
    echo ""
    
    # Run the archive tool
    info "Running log-archive tool..."
    echo ""
    
    if bash "${SCRIPT_DIR}/log-archive.sh" "$TEST_LOG_DIR"; then
        success "Archive tool executed successfully"
    else
        error "Archive tool execution failed"
    fi
    
    # Display results
    display_results
    
    # Optional: cleanup
    echo -e "${YELLOW}Clean up test data? (y/n)${NC}"
    read -r -t 10 response || response="n"
    
    if [[ "$response" == "y" ]]; then
        cleanup
        success "Test data cleaned up"
    else
        info "Test data preserved in: $TEST_LOG_DIR"
        info "Archive created in: $ARCHIVE_DIR"
        info "To clean up manually, run: rm -rf $TEST_LOG_DIR $ARCHIVE_DIR"
    fi
    
    echo ""
}

# Run main function
main
