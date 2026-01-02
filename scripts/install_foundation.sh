#!/bin/bash
# Foundation Installation Script
# Sets up foundation in a consuming repository

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

# Parse arguments
FOUNDATION_REPO=""
INSTALL_METHOD="submodule"  # or "symlink", "copy"
FOUNDATION_PATH="foundation"

show_help() {
    cat << EOF
Usage: ./install-foundation.sh [OPTIONS] <foundation-repo>

Installs the foundation into a consuming repository.

OPTIONS:
    -h, --help              Show this help message
    -m, --method <method>   Installation method: submodule (default), symlink, copy
    -p, --path <path>       Foundation path (default: foundation)

EXAMPLES:
    # Install as git submodule (recommended)
    ./install-foundation.sh ../foundation

    # Install as git submodule from remote
    ./install-foundation.sh https://github.com/user/foundation.git

    # Install as symlink (for local development)
    ./install-foundation.sh -m symlink ../foundation

    # Install as copy (for modification)
    ./install-foundation.sh -m copy ../foundation
EOF
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -m|--method)
            INSTALL_METHOD="$2"
            shift 2
            ;;
        -p|--path)
            FOUNDATION_PATH="$2"
            shift 2
            ;;
        *)
            if [ -z "$FOUNDATION_REPO" ]; then
                FOUNDATION_REPO="$1"
            else
                print_error "Unknown argument: $1"
                show_help
                exit 1
            fi
            shift
            ;;
    esac
done

# Validate arguments
if [ -z "$FOUNDATION_REPO" ]; then
    print_error "Foundation repository path/URL is required"
    show_help
    exit 1
fi

# Check if we're in a git repository
if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    print_error "Not in a git repository"
    exit 1
fi

print_info "Installing foundation..."
print_info "Source: $FOUNDATION_REPO"
print_info "Method: $INSTALL_METHOD"
print_info "Path: $FOUNDATION_PATH"

# Install based on method
case $INSTALL_METHOD in
    submodule)
        print_info "Adding as git submodule..."
        git submodule add "$FOUNDATION_REPO" "$FOUNDATION_PATH"
        git submodule update --init --recursive
        print_info "✅ Foundation added as submodule"
        ;;
    
    symlink)
        print_info "Creating symlink..."
        if [ -e "$FOUNDATION_PATH" ]; then
            print_error "Path already exists: $FOUNDATION_PATH"
            exit 1
        fi
        ln -s "$FOUNDATION_REPO" "$FOUNDATION_PATH"
        print_info "✅ Foundation symlinked"
        ;;
    
    copy)
        print_info "Copying foundation..."
        if [ -e "$FOUNDATION_PATH" ]; then
            print_error "Path already exists: $FOUNDATION_PATH"
            exit 1
        fi
        cp -r "$FOUNDATION_REPO" "$FOUNDATION_PATH"
        print_info "✅ Foundation copied"
        ;;
    
    *)
        print_error "Unknown installation method: $INSTALL_METHOD"
        exit 1
        ;;
esac

# Generate default config if it doesn't exist
if [ ! -f "foundation_config.yaml" ]; then
    print_info "Generating foundation_config.yaml..."
    if [ -f "$FOUNDATION_PATH/config/foundation_config.yaml" ]; then
        cp "$FOUNDATION_PATH/config/foundation_config.yaml" ./foundation_config.yaml
        print_info "✅ Config file created: foundation_config.yaml"
        print_warn "Please customize foundation_config.yaml for your repository"
    else
        print_warn "Foundation config template not found"
    fi
fi

# Create .gitignore entries if needed
if [ -f ".gitignore" ]; then
    if ! grep -q "^foundation_config.local.yaml$" .gitignore 2>/dev/null; then
        echo "" >> .gitignore
        echo "# Foundation local overrides" >> .gitignore
        echo "foundation_config.local.yaml" >> .gitignore
        print_info "✅ Added foundation config to .gitignore"
    fi
fi

# Setup private docs submodule (optional)
PRIVATE_DOCS_URL=""

# Check environment variable first
if [ -n "$PRIVATE_DOCS_REPO_URL" ]; then
    PRIVATE_DOCS_URL="$PRIVATE_DOCS_REPO_URL"
    print_info "Found PRIVATE_DOCS_REPO_URL environment variable"
# Check foundation_config.yaml if it exists
elif [ -f "foundation_config.yaml" ]; then
    # Try to extract private_docs.repo_url from config (requires yq or manual parsing)
    if command -v yq &> /dev/null; then
        CONFIG_URL=$(yq eval '.private_docs.repo_url' foundation_config.yaml 2>/dev/null)
        if [ "$CONFIG_URL" != "null" ] && [ -n "$CONFIG_URL" ]; then
            PRIVATE_DOCS_URL="$CONFIG_URL"
            print_info "Found private docs URL in foundation_config.yaml"
        fi
    fi
fi

# If URL is set and docs/private doesn't exist, add submodule
if [ -n "$PRIVATE_DOCS_URL" ] && [ ! -e "docs/private" ]; then
    print_info ""
    print_info "Setting up private docs submodule..."
    
    # Remove docs/private from .gitignore if present
    if [ -f ".gitignore" ] && grep -q "^docs/private" .gitignore 2>/dev/null; then
        print_warn "Removing docs/private from .gitignore to allow submodule..."
        sed -i.bak '/^docs\/private/d' .gitignore && rm .gitignore.bak
    fi
    
    # Add submodule
    if git submodule add "$PRIVATE_DOCS_URL" docs/private; then
        git submodule update --init --recursive
        print_info "✅ Private docs submodule added"
        
        # Create required directories
        mkdir -p docs/private/competitive
        mkdir -p docs/private/partnerships
        print_info "✅ Created competitive/ and partnerships/ directories"
    else
        print_warn "Failed to add private docs submodule. You can add it manually later:"
        print_warn "  git submodule add \$PRIVATE_DOCS_REPO_URL docs/private"
    fi
elif [ -n "$PRIVATE_DOCS_URL" ] && [ -e "docs/private" ]; then
    print_info "Private docs already exists at docs/private"
else
    print_info ""
    print_info "ℹ️  Private docs submodule not configured"
    print_info "To set up later, either:"
    print_info "  1. Set PRIVATE_DOCS_REPO_URL environment variable, or"
    print_info "  2. Add to foundation_config.yaml:"
    print_info "     private_docs:"
    print_info "       enabled: true"
    print_info "       repo_url: \"https://github.com/user/private-docs.git\""
    print_info "  3. Then run: git submodule add \$PRIVATE_DOCS_REPO_URL docs/private"
fi

# Setup cursor rules (optional)
if [ -f "$FOUNDATION_PATH/scripts/setup_cursor_rules.sh" ]; then
    print_info ""
    print_info "Setting up cursor rules..."
    "$FOUNDATION_PATH/scripts/setup_cursor_rules.sh"
fi

print_info ""
print_info "✅ Foundation installation complete!"
print_info ""
print_info "Next steps:"
print_info "  1. Customize foundation_config.yaml for your repository"
print_info "  2. Run ./foundation/scripts/validate-setup.sh to verify installation"
print_info "  3. See foundation/README.md for usage documentation"
print_info "  4. See foundation/agent_instructions/README.md for cursor rules documentation"


