#!/usr/bin/env bash

# Global configuration
DRY_RUN=${DRY_RUN:-false}
VERBOSE=${VERBOSE:-false}
ASSUME_YES=${ASSUME_YES:-false}
LOG_FILE="${HOME}/.dotfiles-setup.log"
START_TIME=$(date +%s)

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Logging function with enhanced context
log_message() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local caller_info=""

    # Capture caller information (function name and line number)
    if [[ "${BASH_SOURCE[2]:-}" != "" ]]; then
        local func="${FUNCNAME[2]:-main}"
        local line="${BASH_LINENO[1]:-0}"
        local file=$(basename "${BASH_SOURCE[2]}")
        caller_info=" [$file:$func:$line]"
    fi

    echo "[$timestamp] [$level]$caller_info $message" >> "$LOG_FILE"
}

# Print with colors and logging
print_error() {
    printf "${RED}✗ %s${NC}\n" "$1"
    log_message "ERROR" "$1"
}

print_success() {
    printf "${GREEN}✓ %s${NC}\n" "$1"
    log_message "SUCCESS" "$1"
}

print_info() {
    printf "${YELLOW}→ %s${NC}\n" "$1"
    log_message "INFO" "$1"
}

print_dry_run() {
    printf "${BLUE}[DRY-RUN] %s${NC}\n" "$1"
    log_message "DRY-RUN" "$1"
}

print_progress() {
    local current="$1"
    local total="$2"
    local task="$3"
    printf "${MAGENTA}[%d/%d] %s${NC}\n" "$current" "$total" "$task"
    log_message "PROGRESS" "[$current/$total] $task"
}

print_warning() {
    printf "${YELLOW}⚠ %s${NC}\n" "$1"
    log_message "WARNING" "$1"
}

print_step() {
    printf "\n${BLUE}▶ %s${NC}\n" "$1"
    log_message "STEP" "$1"
}

print_substep() {
    printf "  ${BLUE}↳ %s${NC}\n" "$1"
    log_message "SUBSTEP" "$1"
}

print_debug() {
    if [[ "$VERBOSE" == "true" ]]; then
        printf "${CYAN}[DEBUG] %s${NC}\n" "$1"
        log_message "DEBUG" "$1"
    else
        log_message "DEBUG" "$1"
    fi
}

print_prompt() {
    printf "${MAGENTA}? %s${NC} " "$1"
    log_message "PROMPT" "$1"
}

print_result() {
    local status="$1"
    local message="$2"

    case "$status" in
        "success")
            print_success "$message"
            ;;
        "error")
            print_error "$message"
            ;;
        "warning")
            print_warning "$message"
            ;;
        "info")
            print_info "$message"
            ;;
        *)
            print_info "$message"
            ;;
    esac
}

# Initialize log file
init_logging() {
    echo "==================== Dotfiles Setup Started: $(date) ====================" >> "$LOG_FILE"
    if [[ "$DRY_RUN" == "true" ]]; then
        echo "DRY-RUN MODE ENABLED" >> "$LOG_FILE"
    fi
}

# Error handling and rollback
ROLLBACK_STACK=()
ERROR_COUNT=0
AUTO_BACKUP_DIR=""

# Add action to rollback stack
add_to_rollback() {
    local action_type="$1"
    local description="$2"
    local rollback_command="$3"

    ROLLBACK_STACK+=("$action_type|$description|$rollback_command")
    log_message "ROLLBACK" "Added to rollback stack: $description"
}

# Execute rollback
execute_rollback() {
    if [[ ${#ROLLBACK_STACK[@]} -eq 0 ]]; then
        print_info "No actions to rollback"
        return 0
    fi

    print_error "Executing rollback of ${#ROLLBACK_STACK[@]} actions..."

    # Rollback in reverse order
    for ((i=${#ROLLBACK_STACK[@]}-1; i>=0; i--)); do
        local entry="${ROLLBACK_STACK[i]}"
        local action_type="${entry%%|*}"
        local temp="${entry#*|}"
        local description="${temp%%|*}"
        local rollback_command="${temp#*|}"

        print_info "Rolling back: $description"

        case "$action_type" in
            "defaults")
                eval "$rollback_command" 2>/dev/null || print_error "Failed to rollback: $description"
                ;;
            "file")
                eval "$rollback_command" 2>/dev/null || print_error "Failed to rollback: $description"
                ;;
            "system")
                eval "$rollback_command" 2>/dev/null || print_error "Failed to rollback: $description"
                ;;
        esac
    done

    print_success "Rollback completed"
}

# Enhanced error handling with stack trace and recovery suggestions
handle_error() {
    local exit_code="$1"
    local error_message="$2"
    local allow_continue="${3:-false}"
    local recovery_hint="${4:-}"

    ((ERROR_COUNT++))
    print_error "$error_message (Exit code: $exit_code)"
    log_message "ERROR" "$error_message (Exit code: $exit_code)"

    # Capture and log stack trace
    local frame=0
    log_message "ERROR" "Stack trace:"
    while caller $frame >> "$LOG_FILE" 2>&1; do
        ((frame++))
    done

    # Show recovery suggestion if provided
    if [[ -n "$recovery_hint" ]]; then
        print_info "💡 Suggestion: $recovery_hint"
    fi

    if [[ "$allow_continue" != "true" ]]; then
        print_error "Critical error encountered. Initiating rollback..."
        execute_rollback

        if [[ -n "$AUTO_BACKUP_DIR" ]]; then
            print_info "Automatic backup available at: $AUTO_BACKUP_DIR"
            print_info "To restore: ./scripts/backup.sh restore $(basename "$AUTO_BACKUP_DIR")"
        fi

        exit "$exit_code"
    fi
}

# Handle warnings (non-critical issues)
handle_warning() {
    local warning_message="$1"
    local suggestion="${2:-}"

    print_warning "$warning_message"

    if [[ -n "$suggestion" ]]; then
        print_info "💡 Suggestion: $suggestion"
    fi
}

# Trap handler for unexpected exits
trap_handler() {
    local exit_code=$?
    # Only handle errors, not normal exits
    if [[ $exit_code -ne 0 ]] && [[ "${SCRIPT_EXITING:-}" != "true" ]]; then
        print_error "Unexpected script termination (exit code: $exit_code)"
        execute_rollback
    fi
}

# Set up error trapping
setup_error_handling() {
    # Only set up trap, don't enforce -e flag (let individual scripts decide)
    trap 'trap_handler' ERR
}

# Mark script as intentionally exiting
mark_clean_exit() {
    SCRIPT_EXITING="true"
    export SCRIPT_EXITING
}

# Show execution summary
show_summary() {
    local end_time=$(date +%s)
    local duration=$((end_time - START_TIME))
    local minutes=$((duration / 60))
    local seconds=$((duration % 60))

    if [[ $ERROR_COUNT -gt 0 ]]; then
        printf "\n${YELLOW}Setup completed with ${ERROR_COUNT} error(s) in ${minutes}m ${seconds}s${NC}\n"
    else
        printf "\n${GREEN}Setup completed successfully in ${minutes}m ${seconds}s${NC}\n"
    fi

    printf "${YELLOW}Log file: %s${NC}\n" "$LOG_FILE"

    if [[ ${#ROLLBACK_STACK[@]} -gt 0 ]]; then
        printf "${BLUE}Rollback stack: ${#ROLLBACK_STACK[@]} actions available${NC}\n"
    fi

    log_message "SUMMARY" "Setup completed with $ERROR_COUNT errors in ${minutes}m ${seconds}s"

    # Mark as clean exit
    mark_clean_exit
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Ask for confirmation
ask_confirmation() {
    read -r -p "$1 [y/N] " response
    case "$response" in
        [yY][eE][sS]|[yY])
            true
            ;;
        *)
            false
            ;;
    esac
}

# Prompt with default value (smart defaults)
prompt_with_default() {
    local prompt="$1"
    local default="$2"  # 'y' or 'n'
    local response

    # Skip prompt if --yes flag is set
    if [[ "$ASSUME_YES" == "true" ]]; then
        print_debug "Auto-answering prompt with default: $default"
        [[ "$default" == "y" ]] && return 0 || return 1
    fi

    if [[ "$DRY_RUN" == "true" ]]; then
        print_dry_run "Would prompt: $prompt [default: $default]"
        return 0
    fi

    print_prompt "$prompt [$([ "$default" = "y" ] && echo "Y/n" || echo "y/N")]"
    read -r response
    response=${response:-$default}

    case "$response" in
        [yY][eE][sS]|[yY]) return 0 ;;
        *) return 1 ;;
    esac
}

# Print operation summary
print_summary() {
    local operation="$1"
    shift
    local -a stats=("$@")

    echo ""
    print_step "Summary: $operation"
    for stat in "${stats[@]}"; do
        print_info "  $stat"
    done
    echo ""
}