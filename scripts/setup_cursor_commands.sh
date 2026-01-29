#!/bin/bash
# Setup Cursor Commands Only
# Creates symlinks from foundation cursor_commands to .cursor/commands/.
# Does not touch rules. Use setup_cursor_rules.sh for rules + commands.

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

print_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
print_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }

FOUNDATION_DIR=""
if [ -d "foundation" ]; then
    FOUNDATION_DIR="foundation"
elif [ -d "../foundation" ]; then
    FOUNDATION_DIR="../foundation"
else
    print_error "Foundation directory not found. Run from repository root or ensure foundation is installed."
    exit 1
fi

COMMANDS_DIR="$FOUNDATION_DIR/agent_instructions/cursor_commands"
if [ ! -d "$COMMANDS_DIR" ]; then
    print_error "Cursor commands directory not found: $COMMANDS_DIR"
    exit 1
fi

mkdir -p .cursor/commands
COMMANDS_RELATIVE_PATH="../../$FOUNDATION_DIR/agent_instructions/cursor_commands"

print_info "Setting up cursor commands only (no rules)..."
print_info "Foundation directory: $FOUNDATION_DIR"

COMMANDS_REMOVED=0
if [ -d ".cursor/commands" ]; then
    for existing_link in .cursor/commands/foundation_*.md .cursor/commands/foundation-*.md; do
        if [ -L "$existing_link" ]; then
            rm "$existing_link"
            print_info "  ✓ Removed $(basename "$existing_link")"
            COMMANDS_REMOVED=$((COMMANDS_REMOVED + 1))
        fi
    done
    for cmd_file in "$COMMANDS_DIR"/*.md; do
        [ -f "$cmd_file" ] || continue
        cmd_name=$(basename "$cmd_file")
        target_file=".cursor/commands/$cmd_name"
        if [ -L "$target_file" ]; then
            rm "$target_file"
            print_info "  ✓ Removed $cmd_name"
            COMMANDS_REMOVED=$((COMMANDS_REMOVED + 1))
        fi
    done
fi

print_info "Creating symlinks for foundation commands..."
COMMANDS_LINKED=0
for cmd_file in "$COMMANDS_DIR"/*.md; do
    if [ -f "$cmd_file" ]; then
        cmd_name=$(basename "$cmd_file")
        target_file=".cursor/commands/$cmd_name"
        if [ -e "$target_file" ]; then
            print_warn "File already exists (not a symlink): $cmd_name (skipping)"
        else
            ln -s "$COMMANDS_RELATIVE_PATH/$cmd_name" "$target_file"
            print_info "  ✓ Linked $cmd_name"
            COMMANDS_LINKED=$((COMMANDS_LINKED + 1))
        fi
    fi
done

print_info ""
print_info "✅ Cursor commands setup complete!"
print_info "  Foundation commands linked: $COMMANDS_LINKED"
if [ $COMMANDS_REMOVED -gt 0 ]; then
    print_info "  Previous command symlinks removed: $COMMANDS_REMOVED"
fi
print_info ""
print_info "Rules were not changed. Use /setup_symlinks to link rules and commands."
