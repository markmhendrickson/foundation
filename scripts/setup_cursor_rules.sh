#!/bin/bash
# Setup Cursor Rules Script
# Creates symlinks to generic cursor rules and commands from foundation to .cursor/ directory
# Prefixes all symlink names with "foundation_" to avoid conflicts with other repos

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
RULES_DIR="$FOUNDATION_DIR/agent_instructions/cursor_rules"
COMMANDS_DIR="$FOUNDATION_DIR/agent_instructions/cursor_commands"

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
# .cursor/rules -> .. -> .. -> foundation/agent_instructions/cursor_rules
RULES_RELATIVE_PATH="../../$FOUNDATION_DIR/agent_instructions/cursor_rules"
COMMANDS_RELATIVE_PATH="../../$FOUNDATION_DIR/agent_instructions/cursor_commands"

# Prefix for symlink names to avoid conflicts with other repos
SYMLINK_PREFIX="foundation_"

# Remove all existing symlinks with the prefix (both - and _ variants)
print_info "Removing existing symlinks with prefix '$SYMLINK_PREFIX' (including underscore variant)..."
RULES_REMOVED=0
COMMANDS_REMOVED=0

if [ -d ".cursor/rules" ]; then
    # Remove foundation- prefixed symlinks
    for existing_link in .cursor/rules/${SYMLINK_PREFIX}*.md; do
        if [ -L "$existing_link" ]; then
            rm "$existing_link"
            print_info "  ✓ Removed $(basename "$existing_link")"
            RULES_REMOVED=$((RULES_REMOVED + 1))
        fi
    done
    # Remove foundation_ prefixed symlinks
    for existing_link in .cursor/rules/foundation_*.md; do
        if [ -L "$existing_link" ]; then
            rm "$existing_link"
            print_info "  ✓ Removed $(basename "$existing_link")"
            RULES_REMOVED=$((RULES_REMOVED + 1))
        fi
    done
fi

if [ -d ".cursor/commands" ]; then
    # Remove foundation- prefixed symlinks
    for existing_link in .cursor/commands/${SYMLINK_PREFIX}*.md; do
        if [ -L "$existing_link" ]; then
            rm "$existing_link"
            print_info "  ✓ Removed $(basename "$existing_link")"
            COMMANDS_REMOVED=$((COMMANDS_REMOVED + 1))
        fi
    done
    # Remove foundation_ prefixed symlinks
    for existing_link in .cursor/commands/foundation_*.md; do
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
# Process both .md and .mdc files (prefer .mdc if both exist)
# First, collect all .mdc files
for rule_file in "$RULES_DIR"/*.mdc; do
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
# Then, process .md files that don't have corresponding .mdc files
for rule_file in "$RULES_DIR"/*.md; do
    if [ -f "$rule_file" ]; then
        rule_name=$(basename "$rule_file")
        base_name="${rule_name%.md}"
        # Skip if .mdc version exists
        if [ -f "$RULES_DIR/${base_name}.mdc" ]; then
            continue
        fi
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

# Process repo rules from docs/ directory
print_info ""
print_info "Processing repository rules from docs/ directory..."
REPO_RULES_REMOVED=0
REPO_RULES_LINKED=0

# Check if docs/ directory exists
if [ -d "docs" ]; then
    # Remove existing repo rule symlinks (ending in _rules.md, excluding foundation-* and foundation_*)
    if [ -d ".cursor/rules" ]; then
        for existing_link in .cursor/rules/*_rules.md; do
            if [ -L "$existing_link" ] && [ -e "$existing_link" ]; then
                basename_file=$(basename "$existing_link")
                # Skip if it starts with foundation- or foundation_
                if [[ ! "$basename_file" =~ ^foundation[-_] ]]; then
                    rm "$existing_link"
                    print_info "  ✓ Removed repo rule: $basename_file"
                    REPO_RULES_REMOVED=$((REPO_RULES_REMOVED + 1))
                fi
            fi
        done
    fi
    
    # Find all *_rules.md files in docs/ directory (recursively)
    while IFS= read -r -d '' rule_file; do
        # Get relative path from docs/ directory
        rel_path="${rule_file#docs/}"
        # Get directory path and filename
        dir_path=$(dirname "$rel_path")
        file_name=$(basename "$rel_path" .md)
        
        # Create symlink name by replacing / with _
        if [ "$dir_path" = "." ]; then
            symlink_name="${file_name}.md"
        else
            # Replace / with _ in path
            path_prefix=$(echo "$dir_path" | tr '/' '_')
            symlink_name="${path_prefix}_${file_name}.md"
        fi
        
        target_file=".cursor/rules/$symlink_name"
        
        # Calculate relative path from .cursor/rules/ to the file
        rel_to_cursor="../../$rule_file"
        
        if [ -e "$target_file" ] && [ ! -L "$target_file" ]; then
            # File exists but is not a symlink (preserve customizations)
            print_warn "File already exists (not a symlink): $symlink_name (skipping to preserve existing file)"
        else
            ln -s "$rel_to_cursor" "$target_file"
            print_info "  ✓ Linked $rule_file -> $symlink_name"
            REPO_RULES_LINKED=$((REPO_RULES_LINKED + 1))
        fi
    done < <(find docs -name "*_rules.md" -type f -print0)
    
    if [ $REPO_RULES_LINKED -eq 0 ] && [ $REPO_RULES_REMOVED -eq 0 ]; then
        print_info "  No repo rules found in docs/ directory"
    fi
else
    print_info "  No docs/ directory found, skipping repo rules"
fi

print_info ""
if [ $RULES_LINKED -gt 0 ] || [ $COMMANDS_LINKED -gt 0 ] || [ $RULES_REMOVED -gt 0 ] || [ $COMMANDS_REMOVED -gt 0 ] || [ $REPO_RULES_LINKED -gt 0 ] || [ $REPO_RULES_REMOVED -gt 0 ]; then
    print_info "✅ Cursor rules setup complete!"
    if [ $RULES_REMOVED -gt 0 ]; then
        print_info "  Foundation rules removed: $RULES_REMOVED"
    fi
    if [ $COMMANDS_REMOVED -gt 0 ]; then
        print_info "  Foundation commands removed: $COMMANDS_REMOVED"
    fi
    if [ $REPO_RULES_REMOVED -gt 0 ]; then
        print_info "  Repo rules removed: $REPO_RULES_REMOVED"
    fi
    print_info "  Foundation rules linked: $RULES_LINKED"
    print_info "  Foundation commands linked: $COMMANDS_LINKED"
    if [ $REPO_RULES_LINKED -gt 0 ]; then
        print_info "  Repo rules linked: $REPO_RULES_LINKED"
    fi
    print_info ""
    print_info "Symlinks created to foundation (single source of truth)"
    print_info "Updates to foundation will automatically apply to these rules/commands"
    print_info "Foundation symlinks are prefixed with 'foundation_' to avoid conflicts"
    if [ $REPO_RULES_LINKED -gt 0 ]; then
        print_info "Repo rules use path-based naming (e.g., foundation_agent_instructions_rules.md)"
    fi
    print_info ""
    print_info "Next steps:"
    print_info "  1. Review rules in .cursor/rules/ (they link to foundation and docs/)"
    print_info "  2. Configure foundation_config.yaml to enable cursor rules"
    print_info "  3. See foundation/agent_instructions/README.md for documentation"
    print_info ""
    print_info "Note: To customize a rule, remove the symlink and create your own file"
else
    print_warn "No new rules or commands linked (all already exist)"
    print_info "  Existing files/symlinks preserved"
    print_info "  To replace with foundation versions, remove existing files first"
fi

