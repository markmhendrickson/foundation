# Agent Instructions

Optional agent instruction templates for AI coding assistants. Configurable via `foundation_config.yaml`.

## Configuration

```yaml
agent_instructions:
  enabled: true
  location: "docs/foundation/agent_instructions.md"
  cursor_rules:
    enabled: true
    location: ".cursor/rules/"
  cursor_skills:
    enabled: true
    location: ".cursor/skills/"
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

Eight generic Cursor rules for use across repositories:

1. **Behavioral Self-Adaptation** - Proactive rule/skill/hook suggestions from user interventions
2. **Security** - Pre-commit security audit
3. **Worktree Environment** - Environment file handling in worktrees
4. **README Maintenance** - Automatic README synchronization
5. **Downstream Doc Updates** - Documentation dependency management
6. **Instruction Documentation** - Rules for documenting agent instructions
7. **Configuration Management** - Configuration file placement and scope
8. **Dependency Installation** - Automatic installation of required dependencies

All rules located in `foundation/agent_instructions/cursor_rules/`. Installed to `.cursor/rules/` directory via symlinks.

### Rule Details

#### 1. Behavioral Self-Adaptation Rule

**File:** `cursor_rules/behavioral_self_adaptation.mdc`

Enables agents to learn from user interventions and proactively suggest behavioral improvements.

**Key Features:**
- Post-intervention analysis when user resolves agent stopping points
- Pattern detection for generalizable behaviors
- Automatic classification of intervention types (scope expansion, decision rule, workflow extension, etc.)
- Integration with strategy/tactics/operations hierarchy
- Proactive suggestions for rules, skills, or hooks
- User approval required before implementation

**How It Works:**

When an agent stops and asks for guidance, and you provide a response that implies a persistent pattern:

1. **Analysis:** Agent identifies the stopping point context and analyzes your intervention
2. **Classification:** Determines intervention type (scope expansion, decision rule, workflow extension, constraint clarification, automation preference)
3. **Alignment Check:** Verifies suggestion aligns with strategy/tactics/operations and respects constraints
4. **Suggestion:** Presents specific rule/skill/hook with exact content and location
5. **Implementation:** If approved, creates/updates the artifact and applies it immediately to current task

**Example:**
```
Agent stops: "Should I update related tasks?"
You: "Yes, always update related tasks for financial transactions"
Agent: Analyzes pattern → Suggests rule enhancement to persistence_rules.mdc
You: Approve
Agent: Updates rule and applies to current task
Future: Agent updates related tasks automatically
```

**Configuration:** No configuration needed - integrates with existing rules and frameworks.

**When to Use:** Always enabled. Works alongside `prompt_integration_rules.mdc` (explicit instructions) by handling implicit patterns from interventions.

**Integration:**
- Works with `prompt_integration_rules.mdc` (explicit "always do X" instructions)
- Respects `risk_management.mdc` (won't suggest bypassing security holds)
- Validates against `agent_constraints.mdc` (respects architectural boundaries)
- Checks `decision_framework_rules.mdc` (aligns with strategy/tactics/operations)

**Benefits:**
- Reduces repetitive guidance over time
- Captures implicit preferences as explicit rules
- Maintains user control through approval process
- Continuously improves agent behavior
- Transparent learning mechanism

#### 2. Security Rule

**File:** `cursor_rules/security.md`

Prevents accidental commits of private, sensitive, or confidential documentation and data.

**Key Features:**
- Configurable protected paths (via `foundation_config.yaml`)
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

#### 3. Worktree Environment Rule

**File:** `cursor_rules/worktree_env.md`

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

#### 4. README Maintenance Rule

**File:** `cursor_rules/readme_maintenance.md`

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

#### 5. Downstream Doc Updates Rule

**File:** `cursor_rules/downstream_doc_updates.md`

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

#### 6. Instruction Documentation Rule

**File:** `cursor_rules/instruction_documentation.md`

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

#### 7. Configuration Management Rule

**File:** `cursor_rules/configuration_management.md`

Ensures configuration files are placed in the correct location based on their scope and purpose.

**Key Features:**
- Clear distinction between repository-specific and shared configuration
- Prevents single-repo configs from being added to foundation submodule
- Decision tree for configuration placement

**Configuration:** No configuration needed - this is a rule about configuration placement itself.

**When to Use:** Always enabled when working with foundation configuration. Prevents common mistake of adding repo-specific configs to foundation submodule.

**When to Customize:** Add repository-specific configuration placement rules if needed.

#### 8. Dependency Installation Rule

**File:** `cursor_rules/dependency_installation.md`

Ensures agents automatically install required dependencies when needed to fulfill prompts.

**Key Features:**
- Automatic detection of missing dependencies
- Installation without asking for permission
- Support for multiple package managers (npm, yarn, pip, etc.)
- Automatic updates to dependency manifest files

**Configuration:** No configuration needed - applies universally to all projects.

**When to Use:** Always enabled. Ensures agents install dependencies automatically when implementing features or making changes that require new packages or tools.

**When to Customize:** No customization needed - rule applies to all package managers and dependency systems.

## Foundation Skills (replaced legacy commands)

Foundation workflows are in `foundation/agent_instructions/cursor_skills/{slug}/SKILL.md` and are copied to `.cursor/skills/` by setup. Load the skill when the trigger matches (see router rule).

1. **commit** - Commit workflow with security audit, nested repo handling, configurable commit message generation
2. **create-release** - Release orchestration workflow for coordinating multiple Feature Units
3. **create-feature-unit** - Scaffold new Feature Unit with interactive spec creation and dependency validation
4. **run-feature-workflow** - Implement Feature Unit following spec-first development flow
5. **create-prototype** - Create interactive prototype for UI features (Checkpoint 1)
6. **final-review** - Present completed implementation for approval (Checkpoint 2)
7. **analyze** - Competitive and partnership analysis for any project/URL relative to current repo
8. **setup-cursor-copies** - Set up foundation cursor rules and skills in `.cursor/` (copies from foundation; skills replace legacy commands)

### Commit skill details

**Skill:** `commit` (`.cursor/skills/commit/SKILL.md` or `foundation/agent_instructions/cursor_skills/commit/SKILL.md`)

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

### Analyze skill details

**Skill:** `analyze` (`.cursor/skills/analyze/SKILL.md` or `foundation/agent_instructions/cursor_skills/analyze/SKILL.md`)

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
./foundation/scripts/setup_cursor_rules.sh
```

The setup script copies foundation rules and **copies foundation skills** into `.cursor/skills/`, ensuring:
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
ln -s ../../foundation/agent_instructions/cursor_rules/behavioral_self_adaptation.mdc foundation-behavioral_self_adaptation.mdc
ln -s ../../foundation/agent_instructions/cursor_rules/security.md foundation-security.md
ln -s ../../foundation/agent_instructions/cursor_rules/worktree_env.md foundation-worktree_env.md
ln -s ../../foundation/agent_instructions/cursor_rules/readme_maintenance.md foundation-readme_maintenance.md
ln -s ../../foundation/agent_instructions/cursor_rules/downstream_doc_updates.md foundation-downstream_doc_updates.md
ln -s ../../foundation/agent_instructions/cursor_rules/instruction_documentation.md foundation-instruction_documentation.md
ln -s ../../foundation/agent_instructions/cursor_rules/configuration_management.md foundation-configuration_management.md

# Foundation skills are copied (not symlinked) by setup_cursor_copies.sh from foundation/agent_instructions/cursor_skills/
# Run ./foundation/scripts/setup_cursor_copies.sh to refresh .cursor/skills/
```

Installation script removes all existing "foundation-" prefixed symlinks before creating new ones, ensuring a clean refresh. Preserves existing regular files (non-symlinks) to allow customizations. To customize a generic rule, remove the symlink and create your own file.

## Customization

### Repository-Specific Rules

Create repository-specific rules in `.cursor/rules/` that extend or override generic rules:

```markdown
# .cursor/rules/my_custom_rule.md

# My Custom Rule

**Extends:** `foundation/agent_instructions/cursor_rules/security.md`

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
cp foundation/agent_instructions/cursor_rules/security.md .cursor/rules/security.md
# Edit .cursor/rules/security.md to customize
```

**Note:** Repository-specific rules in `.cursor/rules/` take precedence over foundation rules.

## Generic vs Repo-Specific

Generic (Foundation): instruction documentation patterns, security rules, README maintenance, worktree environment rules, commit workflow.

Repo-Specific: feature creation workflows, release management, project-specific validations, domain-specific rules.

## Best Practices

- Start with generic rules as base
- Customize via `foundation_config.yaml` when possible
- Extend, don't duplicate - reference foundation rules in custom rules
- Document customizations and rationale
- Keep generic rules updated - sync foundation updates to your repository
- Use foundation templates as starting point
- Keep instructions clear and specific
- Update regularly as project evolves
- Test with agents to verify compliance

## Configuration Reference

All cursor rules and commands are configured in `foundation_config.yaml`:

```yaml
agent_instructions:
  cursor_rules:
    enabled: true
    location: ".cursor/rules/"
    generic_rules:
      - behavioral_self_adaptation
      - security
      - worktree_env
      - readme_maintenance
      - downstream_doc_updates
      - instruction_documentation
      - configuration_management
      - dependency_installation
    custom_rules: []  # Your repo-specific rules

  cursor_skills:
    enabled: true
    location: ".cursor/skills/"
    # Foundation skills (commit, create-release, fix-feature-bug, etc.) are copied from foundation/agent_instructions/cursor_skills/
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



