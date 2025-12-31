# File Naming Convention

All filenames must use underscores (snake_case), not kebab-case (dashes).

## Format

- Correct: `create_feature_unit.md`, `setup_symlinks.md`, `run_feature_workflow.md`, `command_naming.md`, `setup_instructions.md`, `api_reference.md`
- Incorrect: `create-feature-unit.md`, `setup-symlinks.md`, `run-feature-workflow.md`, `command-naming.md`, `setup-instructions.md`, `api-reference.md`

## When Creating or Renaming Files

1. Use underscores (snake_case) for all filenames
2. Use underscores when referencing files in documentation
3. Symlinks automatically use `foundation_` prefix (e.g., `foundation_create_feature_unit.md`)

## Migration

If existing files use kebab-case:

1. Rename file from `command-name.md` to `command_name.md`
2. Update references in `foundation_config.yaml`, documentation files, and scripts
3. Run `setup_cursor_rules.sh` to update symlinks

