# Agent Instructions

Optional agent instruction templates for AI coding assistants. Configurable via `foundation-config.yaml`.

## Configuration

```yaml
agent_instructions:
  enabled: true
  location: "docs/foundation/agent_instructions.md"
  cursor_rules:
    enabled: true
    location: ".cursor/rules/"
  cursor_commands:
    enabled: true
    location: ".cursor/commands/"
  constraints: []
    # Project-specific constraints
    # - "Never commit secrets"
    # - "Always update documentation when code changes"
  validation_checklist:
    enabled: true
    custom_checks: []
```

## Agent Instructions Template

### Format

```markdown
## Agent Instructions

### When to Load This Document
[Specific triggers for loading this doc]

### Required Co-Loaded Documents
- [Project manifest]
- [Related docs]

### Constraints Agents Must Enforce
1. [Constraint 1]
2. [Constraint 2]

### Forbidden Patterns
- [Anti-pattern 1]
- [Anti-pattern 2]

### Validation Checklist
- [ ] Requirement 1
- [ ] Requirement 2
```

### Usage

```markdown
# Feature Implementation Guide

[... main content ...]

---

## Agent Instructions

### When to Load This Document
Load when implementing or modifying feature X.

### Required Co-Loaded Documents
- `docs/architecture/overview.md`
- `docs/testing/standards.md`

### Constraints Agents Must Enforce
1. All functions must include error handling
2. Database changes require migration file
3. New endpoints require tests

### Forbidden Patterns
- No direct database queries in controllers
- No hardcoded configuration values

### Validation Checklist
- [ ] Tests cover all code paths
- [ ] Documentation updated
- [ ] Migration file created (if schema changes)
```

## Generic Cursor Rules

Seven generic Cursor rules for use across repositories:

1. **Security** - Pre-commit security audit
2. **Worktree Environment** - Environment file handling in worktrees
3. **README Maintenance** - Automatic README synchronization
4. **Downstream Doc Updates** - Documentation dependency management
5. **Instruction Documentation** - Rules for documenting agent instructions
6. **Configuration Management** - Configuration file placement and scope
7. **Dependency Installation** - Automatic installation of required dependencies

All rules located in `foundation/agent-instructions/cursor-rules/`. Installed to `.cursor/rules/` directory via symlinks.

### Rule Details

#### 1. Security Rule

3. Pull (`cursor-commands/pull.md`) - Pull latest from origin, commit local changes first, merge conflicts, run setup scripts
**File:** `cursor-rules/security.md`

Prevents accidental commits of private, sensitive, or confidential documentation and data.

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

**When to Use:** Always enable for repositories with sensitive data. Customize `protected_paths` per repository. Use `check_data_directory` if your repo has a `data/` directory that should never be committed.

**When to Customize:** Add repository-specific protected paths, adjust credential scanning patterns, add custom security checks.

#### 2. Worktree Environment Rule

**File:** `cursor-rules/worktree_env.md`

Handles environment file management in git worktrees.

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

**When to Use:** Always enable if using git worktrees. Customize `env_file_priority` based on your env file naming.

**When to Customize:** Adjust env file priority order, add custom worktree detection patterns.

#### 3. README Maintenance Rule

**File:** `cursor-rules/readme_maintenance.md`

Ensures README.md remains synchronized with documentation changes.

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

**When to Use:** Enable if you want automatic README updates. Configure `regenerate_triggers` to match your documentation structure.

**When to Customize:** Add repository-specific README sections, customize regeneration triggers, add custom README structure template.

#### 4. Downstream Doc Updates Rule

**File:** `cursor-rules/downstream_doc_updates.md`

Ensures downstream documentation is updated when upstream docs change.

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

**When to Use:** Enable if you have complex documentation hierarchies. Use dependency map for explicit dependency tracking. Use validation script for automated checking.

**When to Customize:** Adjust documentation hierarchy to match your structure, add custom dependency types, customize validation rules.

#### 5. Instruction Documentation Rule

**File:** `cursor-rules/instruction_documentation.md`

Ensures important instructions are documented and available to all agents.

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

**When to Use:** Always enable to ensure instructions are documented. Customize `location` based on your documentation structure.

**When to Customize:** Adjust instruction classification logic, add custom instruction types, customize documentation format.

#### 6. Configuration Management Rule

**File:** `cursor-rules/configuration_management.md`

Ensures configuration files are placed in the correct location based on their scope and purpose.

**Key Features:**
- Clear distinction between repository-specific and shared configuration
- Prevents single-repo configs from being added to foundation submodule
- Decision tree for configuration placement

**Configuration:** No configuration needed - this is a rule about configuration placement itself.

**When to Use:** Always enabled when working with foundation configuration. Prevents common mistake of adding repo-specific configs to foundation submodule.

**When to Customize:** Add repository-specific configuration placement rules if needed.

#### 7. Dependency Installation Rule

**File:** `cursor-rules/dependency_installation.md`

Ensures agents automatically install required dependencies when needed to fulfill prompts.

**Key Features:**
- Automatic detection of missing dependencies
- Installation without asking for permission
- Support for multiple package managers (npm, yarn, pip, etc.)
- Automatic updates to dependency manifest files

**Configuration:** No configuration needed - applies universally to all projects.

**When to Use:** Always enabled. Ensures agents install dependencies automatically when implementing features or making changes that require new packages or tools.

**When to Customize:** No customization needed - rule applies to all package managers and dependency systems.

## Generic Cursor Commands

1. **Commit** (`cursor-commands/commit.md`) - Commit workflow with security audit, nested repo handling, configurable commit message generation
2. **Create Release** (`cursor-commands/create_release.md`) - Release orchestration workflow for coordinating multiple Feature Units
3. **Create Feature Unit** (`cursor-commands/create_feature_unit.md`) - Scaffold new Feature Unit with interactive spec creation and dependency validation
4. **Run Feature Workflow** (`cursor-commands/run_feature_workflow.md`) - Implement Feature Unit following spec-first development flow
5. **Create Prototype** (`cursor-commands/create_prototype.md`) - Create interactive prototype for UI features (Checkpoint 1)
6. **Final Review** (`cursor-commands/final_review.md`) - Present completed implementation for approval (Checkpoint 2)
7. **Analyze** (`cursor-commands/analyze.md`) - Competitive and partnership analysis for any project/URL relative to current repo
8. **Setup Symlinks** (`cursor-commands/setup_symlinks.md`) - Set up symlinks from foundation cursor rules and commands to `.cursor/` directory

### Commit Command Details

**File:** `cursor-commands/commit.md`

Comprehensive commit workflow with security audit and testing.

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

**When to Use:** Always use for consistent commit workflow. Enable `handle_nested_repos` if you have nested git repositories. Enable `ui_testing` if you want automatic frontend testing before commits. Enable `branch_renaming` if you want automatic branch name cleanup.

**When to Customize:** Customize commit message format, add repository-specific commit message sections, adjust change categorization logic.

### Analyze Command Details

**File:** `cursor-commands/analyze.md`

Systematic competitive and partnership analysis for any project.

**Key Features:**
- Dynamically discovers current repo context from foundational documents
- Researches target project via browser tools
- Generates competitive analysis using standardized template
- Generates partnership analysis using standardized template
- Saves to private docs submodule

**Configuration:**

```yaml
strategy:
  competitive_analysis:
    enabled: false
    output_directory: "docs/private/competitive/"
  partnership_analysis:
    enabled: false
    output_directory: "docs/private/partnerships/"

private_docs:
  enabled: false
  repo_url: null  # or "https://github.com/user/private-docs.git"
  path: "docs/private"
```

**When to Use:** Analyze any project from competitive and partnership perspectives. Use when evaluating potential competitors, partnership opportunities, or understanding market landscape.

**When to Customize:** Adjust output directories, add custom assessment criteria, modify templates in `foundation/strategy/`.

## Installation

### Automatic Installation (Recommended)

Use the foundation installation script:

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
- Symlink names are prefixed with "foundation-" to avoid conflicts with other repos
- Existing "foundation-" prefixed symlinks are removed before creating new ones

### Manual Installation

If you prefer to create symlinks manually:

```bash
# Create symlinks for generic rules (with "foundation-" prefix)
cd .cursor/rules
ln -s ../../foundation/agent-instructions/cursor-rules/security.md foundation-security.md
ln -s ../../foundation/agent-instructions/cursor-rules/worktree_env.md foundation-worktree_env.md
ln -s ../../foundation/agent-instructions/cursor-rules/readme_maintenance.md foundation-readme_maintenance.md
ln -s ../../foundation/agent-instructions/cursor-rules/downstream_doc_updates.md foundation-downstream_doc_updates.md
ln -s ../../foundation/agent-instructions/cursor-rules/instruction_documentation.md foundation-instruction_documentation.md
ln -s ../../foundation/agent-instructions/cursor-rules/configuration_management.md foundation-configuration_management.md

# Create symlinks for generic commands (with "foundation-" prefix)
cd ../commands
ln -s ../../foundation/agent-instructions/cursor-commands/commit.md foundation-commit.md
# Add other commands as needed
```

Installation script removes all existing "foundation-" prefixed symlinks before creating new ones, ensuring a clean refresh. Preserves existing regular files (non-symlinks) to allow customizations. To customize a generic rule, remove the symlink and create your own file.

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

## Generic vs Repo-Specific

Generic (Foundation): instruction documentation patterns, security rules, README maintenance, worktree environment rules, commit workflow.

Repo-Specific: feature creation workflows, release management, project-specific validations, domain-specific rules.

## Best Practices

- Start with generic rules as base
- Customize via `foundation-config.yaml` when possible
- Extend, don't duplicate - reference foundation rules in custom rules
- Document customizations and rationale
- Keep generic rules updated - sync foundation updates to your repository
- Use foundation templates as starting point
- Keep instructions clear and specific
- Update regularly as project evolves
- Test with agents to verify compliance

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
      - configuration_management
      - dependency_installation
    custom_rules: []  # Your repo-specific rules

  cursor_commands:
    enabled: true
    location: ".cursor/commands/"
    generic_commands:
      - commit
    custom_commands: []  # Your repo-specific commands
```

## Example: Project-Specific Agent Instructions

```markdown
# docs/foundation/agent_instructions.md

## Repository-Wide Agent Instructions

### Loading Order
1. Load `docs/foundation/agent_instructions.md` (this file)
2. Load project manifest
3. Load specific feature/module docs

### Constraints
1. **Never commit secrets** - Run security audit before commit
2. **Always update tests** - Add tests for all new functionality
3. **Update documentation** - Keep docs in sync with code changes
4. **Follow conventions** - See `foundation/conventions/code-conventions.md`

### Forbidden Patterns
- Committing to main/dev directly
- Skipping tests
- Using deprecated APIs
- Hardcoding configuration

### Validation Checklist
- [ ] Security audit passed
- [ ] All tests passing
- [ ] Documentation updated
- [ ] Code follows conventions
- [ ] No secrets committed
```



