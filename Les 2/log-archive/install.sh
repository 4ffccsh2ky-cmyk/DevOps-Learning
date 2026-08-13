#!/bin/bash

###############################################################################
# Log Archive Tool - Installation Script
#
# Description:
#   Installs the log-archive tool to a system-wide location and sets up
#   optional cron scheduling for automated archive operations.
#
# Usage:
#   bash install.sh [OPTIONS]
#
# Options:
#   --help              Show this help message
#   --location PATH     Install to custom location (default: /usr/local/bin)
#   --cron SCHEDULE     Add to crontab with schedule (e.g., "0 2 * * *")
#   --dry-run          Show what would be done without making changes
#
###############################################################################

set -euo pipefail

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Default configuration
INSTALL_LOCATION="/usr/local/bin"
DRY_RUN=false
CRON_SCHEDULE=""

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

warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

show_help() {
    grep "^#" "$0" | grep -E "^#\s+" | sed 's/^#\s*//'
}

# Parse arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --help)
                show_help
                exit 0
                ;;
            --location)
                INSTALL_LOCATION="$2"
                shift 2
                ;;
            --cron)
                CRON_SCHEDULE="$2"
                shift 2
                ;;
            --dry-run)
                DRY_RUN=true
                shift
                ;;
            *)
                error "Unknown option: $1"
                ;;
        esac
    done
}

# Main installation function
main() {
    echo ""
    echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║   Log Archive Tool - Installation Script   ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}"
    echo ""
    
    # Get the log-archive script location
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local log_archive_script="${script_dir}/log-archive.sh"
    
    if [[ ! -f "$log_archive_script" ]]; then
        error "log-archive.sh not found in $script_dir"
    fi
    
    info "Installation Configuration:"
    echo "  Script location: $log_archive_script"
    echo "  Install to: $INSTALL_LOCATION/log-archive"
    
    if [[ "$DRY_RUN" == true ]]; then
        echo "  Mode: DRY-RUN (no changes will be made)"
    fi
    
    if [[ -n "$CRON_SCHEDULE" ]]; then
        echo "  Cron schedule: $CRON_SCHEDULE"
    fi
    echo ""
    
    # Check if running as root (required for system-wide installation)
    if [[ "$INSTALL_LOCATION" == "/usr/local/bin" || "$INSTALL_LOCATION" == "/usr/bin" ]]; then
        if [[ $EUID -ne 0 && "$DRY_RUN" == false ]]; then
            warning "Installing to $INSTALL_LOCATION requires root privileges"
            error "Please run with sudo: sudo bash install.sh"
        fi
    fi
    
    # Create target directory if it doesn't exist
    if [[ ! -d "$INSTALL_LOCATION" && "$DRY_RUN" == false ]]; then
        info "Creating directory: $INSTALL_LOCATION"
        mkdir -p "$INSTALL_LOCATION" || error "Failed to create $INSTALL_LOCATION"
    fi
    
    # Copy the script
    local install_path="${INSTALL_LOCATION}/log-archive"
    
    if [[ "$DRY_RUN" == true ]]; then
        info "Would copy: $log_archive_script → $install_path"
    else
        info "Installing log-archive tool..."
        cp "$log_archive_script" "$install_path" || error "Failed to copy script"
        chmod +x "$install_path" || error "Failed to make script executable"
        success "Log Archive tool installed to $install_path"
    fi
    
    # Add cron job if requested
    if [[ -n "$CRON_SCHEDULE" ]]; then
        info "Configuring cron schedule..."
        
        if [[ "$DRY_RUN" == true ]]; then
            echo "  Would add cron job: $CRON_SCHEDULE $install_path /var/log"
        else
            # Create cron job entry
            local cron_entry="$CRON_SCHEDULE $install_path /var/log"
            
            # Check if cron job already exists
            if crontab -l 2>/dev/null | grep -q "log-archive"; then
                warning "Cron job for log-archive already exists"
            else
                # Add to crontab
                (crontab -l 2>/dev/null; echo "$cron_entry") | crontab - || error "Failed to add cron job"
                success "Cron job added: $CRON_SCHEDULE"
            fi
        fi
    fi
    
    echo ""
    
    if [[ "$DRY_RUN" == false ]]; then
        success "Installation completed!"
        echo ""
        echo "Usage:"
        echo "  log-archive /var/log"
        echo "  log-archive /path/to/logs"
        echo ""
        
        if [[ -n "$CRON_SCHEDULE" ]]; then
            echo "Cron job configured to run with schedule: $CRON_SCHEDULE"
        else
            echo "To schedule automatic backups, add a cron job:"
            echo "  crontab -e"
            echo "  Then add: 0 2 * * * $install_path /var/log"
        fi
    else
        info "Dry-run completed. No changes were made."
    fi
    
    echo ""
}

# Execute installation
parse_args "$@"
main
