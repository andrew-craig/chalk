#!/usr/bin/env bash
set -euo pipefail

CHALK_DIR=".chalk"
SCRIPTS_DIR="$CHALK_DIR/scripts"
TASKS_DIR="$CHALK_DIR/tasks"
TASK_SCRIPT_URL="https://raw.githubusercontent.com/andrew-craig/chalk/main/scripts/task"

# ── Helpers ──────────────────────────────────────────────────────────────────

info()  { printf '  %s\n' "$*"; }
error() { printf '  ERROR: %s\n' "$*" >&2; }

# ── Step 1: Confirm we are in a git repo root ────────────────────────────────

check_git_repo() {
    if git rev-parse --show-toplevel >/dev/null 2>&1; then
        local toplevel
        toplevel="$(git rev-parse --show-toplevel)"
        if [ "$toplevel" != "$(pwd)" ]; then
            error "You are inside a git repo but not at its root."
            info  "Repo root: $toplevel"
            info  "Current dir: $(pwd)"
            info  "Please run this script from the repo root."
            exit 1
        fi
    else
        echo "WARNING: This directory does not appear to be a git repository."
        read -rp "  Do you want to continue anyway? [y/N] " confirm
        case "$confirm" in
            [yY]|[yY][eE][sS]) ;;
            *) echo "  Installation cancelled."; exit 1 ;;
        esac
    fi
}

# ── Step 2: Create .chalk directory ──────────────────────────────────────────

create_chalk_dir() {
    mkdir -p "$SCRIPTS_DIR"
    mkdir -p "$TASKS_DIR"
    info "Created $SCRIPTS_DIR"
    info "Created $TASKS_DIR"
}

# ── Step 3: Download the task script ─────────────────────────────────────────

download_task_script() {
    local dest="$SCRIPTS_DIR/task"

    if command -v curl >/dev/null 2>&1; then
        curl -fsSL "$TASK_SCRIPT_URL" -o "$dest"
    elif command -v wget >/dev/null 2>&1; then
        wget -q "$TASK_SCRIPT_URL" -O "$dest"
    else
        error "Neither curl nor wget found. Please install one and try again."
        exit 1
    fi

    chmod +x "$dest"
    info "Downloaded task script to $dest"
}

# ── Step 4: Add scripts directory to PATH ────────────────────────────────────

add_to_path() {
    local scripts_path
    scripts_path="$(cd "$SCRIPTS_DIR" && pwd)"
    local export_line="export PATH=\"$scripts_path:\$PATH\""

    # Detect shell config file
    local shell_rc=""
    case "${SHELL:-}" in
        */zsh)  shell_rc="$HOME/.zshrc" ;;
        */bash) shell_rc="$HOME/.bashrc" ;;
        *)      shell_rc="$HOME/.profile" ;;
    esac

    # Check if already in PATH
    if echo "$PATH" | tr ':' '\n' | grep -qx "$scripts_path"; then
        info "Scripts directory is already in PATH"
        return
    fi

    # Check if the export line is already in the config file
    if [ -f "$shell_rc" ] && grep -qF "$scripts_path" "$shell_rc"; then
        info "PATH entry already exists in $shell_rc"
    else
        echo "" >> "$shell_rc"
        echo "# chalk task manager" >> "$shell_rc"
        echo "$export_line" >> "$shell_rc"
        info "Added $scripts_path to PATH in $shell_rc"
    fi

    info "Run 'source $shell_rc' or open a new terminal to use the 'task' command"
}

# ── Main ─────────────────────────────────────────────────────────────────────

echo "chalk installer"
echo "==============="
echo ""

check_git_repo
create_chalk_dir
download_task_script
add_to_path

echo ""
echo "Installation complete!"
