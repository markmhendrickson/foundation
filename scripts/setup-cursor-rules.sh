#!/bin/bash
# Setup Cursor Rules Script
# Creates symlinks to generic cursor rules and commands from foundation to .cursor/ directory

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Find foundation directory
FOUNDATION_DIR=""
if [ -d "foundation" ]; then
    FOUNDATION_DIR="foundation"
elif [ -d "../foundation" ]; then
    FOUNDATION_DIR="../foundation"
else
    print_error "Foundation directory not found. Please run from repository root or ensure foundation is installed."
    exit 1
fi

# Check if foundation has cursor rules
RULES_DIR="$FOUNDATION_DIR/agent-instructions/cursor-rules"
COMMANDS_DIR="$FOUNDATION_DIR/agent-instructions/cursor-commands"

if [ ! -d "$RULES_DIR" ]; then
    print_error "Cursor rules directory not found: $RULES_DIR"
    exit 1
fi

if [ ! -d "$COMMANDS_DIR" ]; then
    print_error "Cursor commands directory not found: $COMMANDS_DIR"
    exit 1
fi

# Create .cursor directories if they don't exist
mkdir -p .cursor/rules
mkdir -p .cursor/commands

print_info "Setting up cursor rules and commands..."
print_info "Foundation directory: $FOUNDATION_DIR"

# Calculate relative path from .cursor/rules to foundation
# .cursor/rules -> .. -> .. -> foundation/agent-instructions/cursor-rules
RULES_RELATIVE_PATH="../../$FOUNDATION_DIR/agent-instructions/cursor-rules"
COMMANDS_RELATIVE_PATH="../../$FOUNDATION_DIR/agent-instructions/cursor-commands"

# Create symlinks for generic rules
print_info "Creating symlinks for generic cursor rules..."
RULES_LINKED=0
for rule_file in "$RULES_DIR"/*.md; do
    if [ -f "$rule_file" ]; then
        rule_name=$(basename "$rule_file")
        target_file=".cursor/rules/$rule_name"
        
        if [ -e "$target_file" ]; then
            if [ -L "$target_file" ]; then
                print_warn "Symlink already exists: $rule_name (skipping)"
            else
                print_warn "File already exists: $rule_name (skipping to preserve customizations)"
            fi
        else
            ln -s "$RULES_RELATIVE_PATH/$rule_name" "$target_file"
            print_info "  ✓ Linked $rule_name"
            RULES_LINKED=$((RULES_LINKED + 1))
        fi
    fi
done

# Create symlinks for generic commands
print_info "Creating symlinks for generic cursor commands..."
COMMANDS_LINKED=0
for cmd_file in "$COMMANDS_DIR"/*.md; do
    if [ -f "$cmd_file" ]; then
        cmd_name=$(basename "$cmd_file")
        target_file=".cursor/commands/$cmd_name"
        
        if [ -e "$target_file" ]; then
            if [ -L "$target_file" ]; then
                print_warn "Symlink already exists: $cmd_name (skipping)"
            else
                print_warn "File already exists: $cmd_name (skipping to preserve customizations)"
            fi
        else
            ln -s "$COMMANDS_RELATIVE_PATH/$cmd_name" "$target_file"
            print_info "  ✓ Linked $cmd_name"
            COMMANDS_LINKED=$((COMMANDS_LINKED + 1))
        fi
    fi
done

print_info ""
if [ $RULES_LINKED -gt 0 ] || [ $COMMANDS_LINKED -gt 0 ]; then
    print_info "✅ Cursor rules setup complete!"
    print_info "  Rules linked: $RULES_LINKED"
    print_info "  Commands linked: $COMMANDS_LINKED"
    print_info ""
    print_info "Symlinks created to foundation (single source of truth)"
    print_info "Updates to foundation will automatically apply to these rules/commands"
    print_info ""
    print_info "Next steps:"
    print_info "  1. Review rules in .cursor/rules/ (they link to foundation)"
    print_info "  2. Configure foundation-config.yaml to enable cursor rules"
    print_info "  3. See foundation/agent-instructions/CURSOR_RULES.md for documentation"
    print_info ""
    print_info "Note: To customize a rule, remove the symlink and create your own file"
else
    print_warn "No new rules or commands linked (all already exist)"
    print_info "  Existing files/symlinks preserved"
    print_info "  To replace with foundation versions, remove existing files first"
fi

