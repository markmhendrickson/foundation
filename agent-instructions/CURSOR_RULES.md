# Cursor Rules Documentation

This document describes the generic Cursor rules provided by foundation and how to use them in your repository.

## Overview

Foundation provides five generic Cursor rules that can be used across repositories:

1. **Security** - Pre-commit security audit
2. **Worktree Environment** - Environment file handling in worktrees
3. **README Maintenance** - Automatic README synchronization
4. **Downstream Doc Updates** - Documentation dependency management
5. **Instruction Documentation** - Rules for documenting agent instructions

All rules are located in `foundation/agent-instructions/cursor-rules/` and can be copied to your `.cursor/rules/` directory.

## Rule Details

### 1. Security Rule

**File:** `cursor-rules/security.md`

**Purpose:** Prevents accidental commits of private, sensitive, or confidential documentation and data.

**Key Features:**
- Configurable protected paths (via `foundation-config.yaml`)
- Environment file detection (`.env*`)
- Data directory checks (optional)
- Hardcoded credentials scanning

**Configuration:**

```yaml
security:
  pre_commit_audit:
    enabled: true
    protected_paths:
      - "docs/private/"  # Repository-specific
      - "data/"          # Repository-specific
    check_env_files: true
    check_data_directory: false  # Configure per repository
```

**When to Use:**
- Always enable for repositories with sensitive data
- Customize `protected_paths` per repository
- Use `check_data_directory` if your repo has a `data/` directory that should never be committed

**When to Customize:**
- Add repository-specific protected paths
- Adjust credential scanning patterns
- Add custom security checks

**Related:**
- `foundation/security/security-rules.md` - Security best practices
- `foundation/security/pre-commit-audit.sh` - Pre-commit audit script

### 2. Worktree Environment Rule

**File:** `cursor-rules/worktree_env.md`

**Purpose:** Handles environment file management in git worktrees.

**Key Features:**
- Environment files live in main repo root, not worktrees
- Automatic env file copying to worktrees
- Configurable env file priority

**Configuration:**

```yaml
tooling:
  env_management:
    enabled: true
    env_file_priority:
      - ".env.dev"
      - ".env"
      - ".env.development"
    worktree_detection:
      cursor_worktrees: true
```

**When to Use:**
- Always enable if using git worktrees
- Customize `env_file_priority` based on your env file naming

**When to Customize:**
- Adjust env file priority order
- Add custom worktree detection patterns

**Related:**
- `foundation/development/workflow.md` - Development workflow including worktrees
- `foundation/security/credential-management.md` - Credential management

### 3. README Maintenance Rule

**File:** `cursor-rules/readme_maintenance.md`

**Purpose:** Ensures README.md remains synchronized with documentation changes.

**Key Features:**
- Automatic README regeneration on material documentation changes
- Configurable regeneration triggers
- Link validation

**Configuration:**

```yaml
tooling:
  readme_generation:
    enabled: true
    source_documents: []  # List of source documents
    structure_template: null  # Path to README structure template
    regenerate_triggers: []  # File patterns that trigger regeneration
```

**When to Use:**
- Enable if you want automatic README updates
- Configure `regenerate_triggers` to match your documentation structure

**When to Customize:**
- Add repository-specific README sections
- Customize regeneration triggers
- Add custom README structure template

**Related:**
- `foundation/conventions/documentation-standards.md` - Documentation standards

### 4. Downstream Doc Updates Rule

**File:** `cursor-rules/downstream_doc_updates.md`

**Purpose:** Ensures downstream documentation is updated when upstream docs change.

**Key Features:**
- Automatic dependency tracking
- Configurable dependency map location
- Validation script support

**Configuration:**

```yaml
tooling:
  doc_dependencies:
    enabled: true
    dependency_map_path: "docs/doc_dependencies.yaml"  # Optional
    validation_script_path: "scripts/validate-doc-dependencies.js"  # Optional
```

**When to Use:**
- Enable if you have complex documentation hierarchies
- Use dependency map for explicit dependency tracking
- Use validation script for automated checking

**When to Customize:**
- Adjust documentation hierarchy to match your structure
- Add custom dependency types
- Customize validation rules

**Related:**
- `foundation/conventions/documentation-standards.md` - Documentation standards
- `foundation/agent-instructions/cursor-rules/readme_maintenance.md` - README maintenance

### 5. Instruction Documentation Rule

**File:** `cursor-rules/instruction_documentation.md`

**Purpose:** Ensures important instructions are documented and available to all agents.

**Key Features:**
- Automatic instruction documentation
- Configurable documentation locations
- Central reference support

**Configuration:**

```yaml
agent_instructions:
  enabled: true
  location: "docs/foundation/agent_instructions.md"
  cursor_rules:
    enabled: true
    location: ".cursor/rules/"
```

**When to Use:**
- Always enable to ensure instructions are documented
- Customize `location` based on your documentation structure

**When to Customize:**
- Adjust instruction classification logic
- Add custom instruction types
- Customize documentation format

**Related:**
- `foundation/conventions/documentation-standards.md` - Documentation standards
- `foundation/agent-instructions/README.md` - Agent instructions overview

## Generic Cursor Commands

### Commit Command

**File:** `cursor-commands/commit.md`

**Purpose:** Comprehensive commit workflow with security audit and testing.

**Key Features:**
- Pre-commit security audit
- Optional nested repository handling
- Configurable commit message generation
- Optional UI testing
- Optional branch renaming

**Configuration:**

```yaml
development:
  commit:
    handle_nested_repos: false  # Enable if you have nested repos
    ui_testing:
      enabled: false
      frontend_paths: []
    branch_renaming:
      enabled: false
      patterns: []
  commit_format:
    require_id: false
    pattern: "{description}"  # or "{id}: {description}"
```

**When to Use:**
- Always use for consistent commit workflow
- Enable `handle_nested_repos` if you have nested git repositories
- Enable `ui_testing` if you want automatic frontend testing before commits
- Enable `branch_renaming` if you want automatic branch name cleanup

**When to Customize:**
- Customize commit message format
- Add repository-specific commit message sections
- Adjust change categorization logic

**Related:**
- `foundation/agent-instructions/cursor-rules/security.md` - Security audit
- `foundation/agent-instructions/cursor-rules/worktree_env.md` - Worktree handling

## Installation

### Using Installation Script (Recommended)

```bash
# Install foundation (includes cursor rules/commands setup)
./foundation/scripts/install-foundation.sh

# Or setup cursor rules separately
./foundation/scripts/setup-cursor-rules.sh
```

The setup script creates **symlinks** from `.cursor/rules/` and `.cursor/commands/` to foundation versions, ensuring:
- Single source of truth (foundation)
- Automatic updates when foundation is updated
- Cursor agents can still auto-load them

### Manual Installation

If you prefer to create symlinks manually:

```bash
# Create symlinks for generic rules
cd .cursor/rules
ln -s ../../foundation/agent-instructions/cursor-rules/security.md security.md
ln -s ../../foundation/agent-instructions/cursor-rules/worktree_env.md worktree_env.md
ln -s ../../foundation/agent-instructions/cursor-rules/readme_maintenance.md readme_maintenance.md
ln -s ../../foundation/agent-instructions/cursor-rules/downstream_doc_updates.md downstream_doc_updates.md
ln -s ../../foundation/agent-instructions/cursor-rules/instruction_documentation.md instruction_documentation.md

# Create symlink for generic commit command
cd ../commands
ln -s ../../foundation/agent-instructions/cursor-commands/commit.md commit.md
```

**Note:** The installation script preserves existing repo-specific rules and commands, only creating symlinks for generic ones that don't already exist. If you want to customize a generic rule, remove the symlink and create your own file.

## Customization

### Repository-Specific Rules

Create repository-specific rules in `.cursor/rules/` that extend or override generic rules:

```markdown
# .cursor/rules/my_custom_rule.md

# My Custom Rule

**Extends:** `foundation/agent-instructions/cursor-rules/security.md`

## Purpose

Add repository-specific security checks.

## Additional Checks

1. Check for API keys in code
2. Validate environment variable names
```

### Overriding Generic Rules

If you need to override a generic rule completely, create a repository-specific version with the same name:

```bash
# Copy and customize
cp foundation/agent-instructions/cursor-rules/security.md .cursor/rules/security.md
# Edit .cursor/rules/security.md to customize
```

**Note:** Repository-specific rules in `.cursor/rules/` take precedence over foundation rules.

## Best Practices

1. **Start with generic rules** - Use foundation rules as a base
2. **Customize via configuration** - Use `foundation-config.yaml` for customization when possible
3. **Extend, don't duplicate** - Reference foundation rules in custom rules
4. **Document customizations** - Document why you customized a rule
5. **Keep generic rules updated** - Sync foundation updates to your repository

## Configuration Reference

All cursor rules and commands are configured in `foundation-config.yaml`:

```yaml
agent_instructions:
  cursor_rules:
    enabled: true
    location: ".cursor/rules/"
    generic_rules:
      - security
      - worktree_env
      - readme_maintenance
      - downstream_doc_updates
      - instruction_documentation
    custom_rules: []  # Your repo-specific rules

  cursor_commands:
    enabled: true
    location: ".cursor/commands/"
    generic_commands:
      - commit
    custom_commands: []  # Your repo-specific commands
```

## Related Documents

- `foundation/agent-instructions/README.md` - Agent instructions overview
- `foundation/config/foundation-config.yaml` - Configuration reference
- `foundation/scripts/setup-cursor-rules.sh` - Installation script

