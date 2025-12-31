#!/bin/bash
# Setup Cursor Rules Script
# Creates symlinks to generic cursor rules and commands from foundation to .cursor/ directory
# Prefixes all symlink names with "foundation-" to avoid conflicts with other repos

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

# Prefix for symlink names to avoid conflicts with other repos
SYMLINK_PREFIX="foundation-"

# Remove all existing symlinks with the prefix
print_info "Removing existing symlinks with prefix '$SYMLINK_PREFIX'..."
RULES_REMOVED=0
COMMANDS_REMOVED=0

if [ -d ".cursor/rules" ]; then
    for existing_link in .cursor/rules/${SYMLINK_PREFIX}*.md; do
        if [ -L "$existing_link" ]; then
            rm "$existing_link"
            print_info "  ✓ Removed $(basename "$existing_link")"
            RULES_REMOVED=$((RULES_REMOVED + 1))
        fi
    done
fi

if [ -d ".cursor/commands" ]; then
    for existing_link in .cursor/commands/${SYMLINK_PREFIX}*.md; do
        if [ -L "$existing_link" ]; then
            rm "$existing_link"
            print_info "  ✓ Removed $(basename "$existing_link")"
            COMMANDS_REMOVED=$((COMMANDS_REMOVED + 1))
        fi
    done
fi

if [ $RULES_REMOVED -gt 0 ] || [ $COMMANDS_REMOVED -gt 0 ]; then
    if [ $RULES_REMOVED -gt 0 ]; then
        print_info "Removed $RULES_REMOVED existing rule symlink(s)"
    fi
    if [ $COMMANDS_REMOVED -gt 0 ]; then
        print_info "Removed $COMMANDS_REMOVED existing command symlink(s)"
    fi
    print_info ""
fi

# Create symlinks for generic rules
print_info "Creating symlinks for generic cursor rules..."
RULES_LINKED=0
for rule_file in "$RULES_DIR"/*.md; do
    if [ -f "$rule_file" ]; then
        rule_name=$(basename "$rule_file")
        symlink_name="${SYMLINK_PREFIX}${rule_name}"
        target_file=".cursor/rules/$symlink_name"
        
        if [ -e "$target_file" ]; then
            # File exists but is not a symlink (preserve customizations)
            print_warn "File already exists (not a symlink): $symlink_name (skipping to preserve existing file)"
        else
            ln -s "$RULES_RELATIVE_PATH/$rule_name" "$target_file"
            print_info "  ✓ Linked $rule_name -> $symlink_name"
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
        symlink_name="${SYMLINK_PREFIX}${cmd_name}"
        target_file=".cursor/commands/$symlink_name"
        
        if [ -e "$target_file" ]; then
            # File exists but is not a symlink (preserve customizations)
            print_warn "File already exists (not a symlink): $symlink_name (skipping to preserve existing file)"
        else
            ln -s "$COMMANDS_RELATIVE_PATH/$cmd_name" "$target_file"
            print_info "  ✓ Linked $cmd_name -> $symlink_name"
            COMMANDS_LINKED=$((COMMANDS_LINKED + 1))
        fi
    fi
done

print_info ""
if [ $RULES_LINKED -gt 0 ] || [ $COMMANDS_LINKED -gt 0 ] || [ $RULES_REMOVED -gt 0 ] || [ $COMMANDS_REMOVED -gt 0 ]; then
    print_info "✅ Cursor rules setup complete!"
    if [ $RULES_REMOVED -gt 0 ]; then
        print_info "  Rules removed: $RULES_REMOVED"
    fi
    if [ $COMMANDS_REMOVED -gt 0 ]; then
        print_info "  Commands removed: $COMMANDS_REMOVED"
    fi
    print_info "  Rules linked: $RULES_LINKED"
    print_info "  Commands linked: $COMMANDS_LINKED"
    print_info ""
    print_info "Symlinks created to foundation (single source of truth)"
    print_info "Updates to foundation will automatically apply to these rules/commands"
    print_info "Symlink names are prefixed with 'foundation-' to avoid conflicts"
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

