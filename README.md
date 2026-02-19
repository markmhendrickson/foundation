# Foundation

Shared development processes and practices for consistent, high-quality software development.

## What is Foundation?

Foundation is a collection of generalized, composable development processes that can be shared across multiple repositories. It includes:

- **Development Workflow** - Git branch strategy, PR process, code review guidelines, Feature Unit workflow, release orchestration
- **Code Conventions** - Naming patterns, style guides for TypeScript, SQL, YAML, Shell
- **Testing Conventions** - Integration test quality, mocking guidelines, assertion standards
- **Documentation Standards** - Structure, formatting, and writing style
- **Security Practices** - Pre-commit audits, credential management, security rules
- **Agent Instructions** - Cursor rules and commands for AI coding assistants, including self-adaptive behavioral improvements
- **Configuration System** - Flexible YAML-based configuration for repo-specific customization
- **Strategy Frameworks** - Product discovery, competitive analysis, partnership evaluation (optional)
- **Validation Systems** - Spec compliance validation, documentation dependency tracking (optional)
- **Tooling** - Secrets management, environment management, agent setup (optional)
- **Integration Scripts** - Easy adoption and synchronization

## Key Features

✅ **Configurable** - Adapt to your project's needs via `foundation_config.yaml`  
✅ **Composable** - Pick and choose what you need  
✅ **Shareable** - Use across multiple repositories via git submodules  
✅ **Agent-Friendly** - Designed for AI coding assistants with self-adaptive learning  
✅ **Maintainable** - Single source of truth for best practices

## Quick Start

### Installation

1. **Install foundation as a git submodule:**

```bash
# From your repository root
./path/to/foundation/scripts/install_foundation.sh ../foundation

# Or from a remote repository
./path/to/foundation/scripts/install_foundation.sh https://github.com/user/foundation.git
```

2. **Customize configuration:**

```bash
# Edit foundation_config.yaml to match your project
vim foundation_config.yaml
```

3. **Validate setup:**

```bash
./foundation/scripts/validate-setup.sh
```

### Basic Usage

**Development Workflow:**

```bash
# Create a feature branch (worktree recommended)
./foundation/development/worktree-setup.sh my-feature

# Make changes, commit, push
git add .
git commit -m "feat: add new feature"
git push
```

**Code Review:**

- Follow PR process in `foundation/development/pr-process.md`
- Use code conventions in `foundation/conventions/code-conventions.md`

**Feature Units (if enabled):**

```bash
# Create a new Feature Unit
# (uses interactive spec creation via agent)
# Follow workflow in foundation/development/feature_unit_workflow.md
```

**Security:**

```bash
# Run pre-commit security audit
./foundation/security/pre_commit_audit.sh
```

**Setup Agent Instructions:**

```bash
# Install Cursor rules and commands as symlinks
./foundation/scripts/setup_cursor_rules.sh
```

### Self-Adaptive Agent Behavior

Foundation includes a self-adaptive learning system for AI agents. When you provide guidance that resolves an agent stopping point, the agent will:

1. **Analyze the intervention** - Identify if your guidance implies a generalizable pattern
2. **Suggest improvements** - Propose new rules, skills, or hooks to prevent similar stops
3. **Request approval** - Present the suggestion with specific content and location
4. **Implement and apply** - Once approved, create the artifact and apply it immediately

**Example:**
```
Agent stops: "Should I update related tasks?"
You respond: "Yes, always update related tasks for financial transactions"
Agent suggests: Add rule to persistence_rules.mdc
You approve: Rule is created and applied to current task
Future: Agent updates related tasks automatically without asking
```

This enables agents to continuously improve their behavior based on your preferences, reducing repetitive guidance over time while maintaining explicit control through user approval.

See `foundation/agent_instructions/cursor_rules/behavioral_self_adaptation.mdc` for full details.

## Directory Structure

```
foundation/
├── agent_instructions/   # AI agent instructions (Cursor rules & commands)
│   ├── cursor_rules/     # Generic Cursor rules
│   ├── cursor_skills/    # Foundation skills (replaced legacy commands)
│   └── README.md
├── development/          # Development workflow and branch strategy
│   ├── workflow.md
│   ├── branch-strategy.md
│   ├── pr-process.md
│   ├── feature_unit_workflow.md
│   ├── release_workflow.md
│   ├── worktree-setup.sh
│   └── templates/        # Feature Unit templates
├── conventions/          # Code and documentation conventions
│   ├── code-conventions.md
│   ├── documentation-standards.md
│   ├── testing-conventions.md
│   └── naming-patterns.yaml
├── security/             # Security practices
│   ├── security-rules.md
│   ├── pre-commit-audit.sh
│   └── credential-management.md
├── strategy/             # Strategy evaluation frameworks (optional)
│   ├── README.md
│   └── [analysis templates]
├── tooling/              # Development tooling (optional)
│   └── README.md
├── validation/           # Validation systems (optional)
│   └── README.md
├── config/               # Configuration system
│   ├── foundation_config.yaml
│   └── repo_adapters/
│       ├── template.yaml
│       └── personal.yaml
├── scripts/              # Integration and utility scripts
│   ├── install_foundation.sh
│   ├── sync_foundation.sh
│   ├── validate_setup.sh
│   └── setup_cursor_rules.sh
└── README.md
```

## Configuration

Foundation is configured via `foundation_config.yaml` in your repository root.

**Example configuration:**

```yaml
repository:
  name: "my-project"
  type: "application"

development:
  branch_strategy:
    feature_prefix: "feature"
    naming_pattern: "{prefix}/{id}-{description}"
  workflow:
    use_worktrees: true

conventions:
  typescript:
    files: "snake_case"
    string_quotes: "double"

security:
  enabled: true
  pre_commit_audit:
    enabled: true
    protected_paths:
      - "docs/private/"
      - ".env*"
```

See `foundation/config/foundation_config.yaml` for all available options.

## Sharing Across Repositories

### Using Git Submodules (Recommended)

**Setup:**

```bash
# In foundation repository
cd ~/Projects/foundation
git init
# ... add foundation content ...
git add .
git commit -m "Initial foundation"
git remote add origin <remote-url>
git push -u origin main

# In consuming repository
cd ~/Projects/my-project
git submodule add <remote-url> foundation
```

**Sync changes:**

```bash
# In consuming repository
cd foundation
git pull origin main
cd ..
git add foundation
git commit -m "Update foundation"
```

**Or use the sync script:**

```bash
./foundation/scripts/sync-foundation.sh
```

### Agent-Editable Shared Processes

When agents make changes to foundation from any consuming repository:

1. Changes are made in the submodule
2. Commit and push from the submodule
3. Other repositories pull updates via `git submodule update --remote foundation`
4. Or use `./foundation/scripts/sync-foundation.sh`

## Customization

### Repository-Specific Overrides

Create a repository adapter in `foundation/config/repo_adapters/`:

```yaml
# my-repo.yaml
repo_name: "my-repo"
extends: "template.yaml"

# Override specific settings
conventions:
  typescript:
    files: "kebab-case"  # Different from foundation default

security:
  pre_commit_audit:
    protected_paths:
      - "private/"  # Custom protected path
```

### Local Overrides

For local development overrides (not committed):

```yaml
# foundation-config.local.yaml (add to .gitignore)
development:
  workflow:
    use_worktrees: false  # Override for this machine only
```

## Documentation

- **[Development Workflow](development/workflow.md)** - Git workflow, branching, PRs
- **[Feature Unit Workflow](development/feature_unit_workflow.md)** - Spec-first development with Feature Units
- **[Release Workflow](development/release_workflow.md)** - Release orchestration and coordination
- **[Code Conventions](conventions/code-conventions.md)** - Style guides for all languages
- **[Testing Conventions](conventions/testing-conventions.md)** - Integration test quality standards
- **[Documentation Standards](conventions/documentation_standards.md)** - Doc structure and style
- **[Security Rules](security/security_rules.md)** - Security best practices
- **[Agent Instructions](agent_instructions/README.md)** - Cursor rules and commands for AI assistants, including self-adaptive learning
  - **[Behavioral Self-Adaptation](agent_instructions/cursor_rules/behavioral_self_adaptation.mdc)** - Proactive rule/skill/hook suggestions from interventions
- **[Strategy Frameworks](strategy/README.md)** - Product discovery and competitive analysis (optional)
- **[Tooling](tooling/README.md)** - Development tooling configuration (optional)
- **[Validation Systems](validation/README.md)** - Spec compliance and doc dependency validation (optional)
- **[Contributing](CONTRIBUTING.md)** - How to contribute to foundation

## Use Cases

### Scenario 1: Multiple Projects with Similar Tech Stack

Use foundation to share conventions across all projects:

- Same TypeScript conventions
- Same PR process
- Same testing standards
- Repo-specific configuration for differences

### Scenario 2: Personal Repository + Work Repository

Share common practices while keeping repo-specific content separate:

- Foundation: Generic workflow, conventions
- Work repo: Company-specific processes
- Personal repo: Personal project patterns

### Scenario 3: Team Onboarding

New team members get consistent documentation:

- Same workflow in all repositories
- Same conventions to learn once
- Same tooling and scripts

## Maintenance

### Updating Foundation

1. Make changes in the foundation repository
2. Commit and push
3. In consuming repositories:

```bash
git submodule update --remote foundation
git add foundation
git commit -m "Update foundation"
```

### Version Management

Foundation uses semantic versioning via git tags:

```bash
# In foundation repository
git tag v1.0.0
git push --tags

# In consuming repository
cd foundation
git checkout v1.0.0
```

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines on contributing to foundation.

## Migration

See [MIGRATION.md](MIGRATION.md) for migrating from project-specific processes to foundation.

## FAQ

**Q: Should I use submodules or symlinks?**  
A: Submodules for production use (version control, team collaboration). Symlinks for local development only.

**Q: Can I modify foundation files in my repository?**  
A: Yes, but prefer configuration over modification. If you need to modify, consider contributing back to foundation.

**Q: How do I handle conflicts when updating foundation?**  
A: Same as any git submodule conflict. Resolve conflicts, commit, and push.

**Q: Can I use foundation without all components?**  
A: Yes, enable/disable components in `foundation_config.yaml`. Most components are optional (Feature Units, strategy, validation, tooling).

**Q: What are Feature Units?**  
A: Feature Units are a spec-first development workflow where changes are fully specified before implementation. See `foundation/development/feature_unit_workflow.md`.

**Q: How do I set up agent instructions?**  
A: Run `./foundation/scripts/setup_cursor_rules.sh` to create symlinks from `.cursor/` to foundation rules and commands. See `foundation/agent_instructions/README.md`.

## Support

For issues or questions:
- Check existing documentation
- Review `foundation_config.yaml` for configuration options
- Create an issue in the foundation repository

## License

MIT License

Copyright (c) 2025 Mark Hendrickson

See [LICENSE](LICENSE) for full license text.

