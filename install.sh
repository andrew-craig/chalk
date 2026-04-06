#!/usr/bin/env bash
set -euo pipefail

CHALK_SCRIPT_URL="https://raw.githubusercontent.com/andrew-craig/chalk/main/scripts/chalk"
INSTALL_DIR="${CHALK_INSTALL_DIR:-$HOME/.local/bin}"

# ── Helpers ──────────────────────────────────────────────────────────────────

info()  { printf '  %s\n' "$*"; }
error() { printf '  ERROR: %s\n' "$*" >&2; }

# ── Step 1: Download the chalk script ────────────────────────────────────────

download_chalk() {
    mkdir -p "$INSTALL_DIR"
    local dest="$INSTALL_DIR/chalk"

    if command -v curl >/dev/null 2>&1; then
        curl -fsSL "$CHALK_SCRIPT_URL" -o "$dest"
    elif command -v wget >/dev/null 2>&1; then
        wget -q "$CHALK_SCRIPT_URL" -O "$dest"
    else
        error "Neither curl nor wget found. Please install one and try again."
        exit 1
    fi

    chmod +x "$dest"
    info "Installed chalk to $dest"
}

# ── Step 2: Add install directory to PATH ────────────────────────────────────

add_to_path() {
    local export_line="export PATH=\"$INSTALL_DIR:\$PATH\""

    # Detect shell config file
    local shell_rc=""
    case "${SHELL:-}" in
        */zsh)  shell_rc="$HOME/.zshrc" ;;
        */bash) shell_rc="$HOME/.bashrc" ;;
        *)      shell_rc="$HOME/.profile" ;;
    esac

    # Check if already in PATH
    if echo "$PATH" | tr ':' '\n' | grep -qx "$INSTALL_DIR"; then
        info "$INSTALL_DIR is already in PATH"
        return
    fi

    # Check if the export line is already in the config file
    if [ -f "$shell_rc" ] && grep -qF "$INSTALL_DIR" "$shell_rc"; then
        info "PATH entry already exists in $shell_rc"
    else
        echo "" >> "$shell_rc"
        echo "# chalk task manager" >> "$shell_rc"
        echo "$export_line" >> "$shell_rc"
        info "Added $INSTALL_DIR to PATH in $shell_rc"
        info "Run 'source $shell_rc' or open a new terminal to use 'chalk'"
    fi
}

# ── Main ─────────────────────────────────────────────────────────────────────

echo "chalk installer"
echo "==============="
echo ""

download_chalk
add_to_path

echo ""
echo "Installation complete!"
echo ""
echo "To set up chalk in a project, navigate to your repo root and run:"
echo "  chalk init"
