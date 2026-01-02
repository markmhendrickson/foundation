# File and Folder Naming Convention

All filenames and folder names must use underscores (snake_case), not kebab-case (dashes).

## Format

**Files:**
- Correct: `create_feature_unit.md`, `setup_symlinks.md`, `run_feature_workflow.md`
- Incorrect: `create-feature-unit.md`, `setup-symlinks.md`, `run-feature-workflow.md`

**Folders:**
- Correct: `cursor_rules/`, `feature_units/`, `agent_instructions/`, `repo_adapters/`
- Incorrect: `cursor-rules/`, `feature-units/`, `agent-instructions/`, `repo-adapters/`

## Capitalization

**General Rule:** Use all lowercase for filenames and folder names.

**Code Files (.ts, .js, .tsx, .jsx):**
- All lowercase: `mcp_ws_bridge.ts`, `record_types.ts`, `entity_resolution.ts`
- Correct: `server.ts`, `db.ts`, `actions.ts`
- Incorrect: `Server.ts`, `DB.ts`, `Actions.ts`

**Documentation Files (.md):**
- All lowercase for regular documentation: `canonical_terms.md`, `architecture.md`, `getting_started.md`
- Uppercase allowed only for special files: `README.md`, `CHANGELOG.md`
- **Note on spec files:** Existing spec files in `docs/specs/` use all uppercase (e.g., `MCP_SPEC.md`, `DATA_MODELS.md`). This is legacy convention. New spec files SHOULD use all lowercase to match the general rule. Existing uppercase spec files may be migrated to lowercase in the future.
- Correct: `source_material_model.md`, `entity_resolution.md`, `README.md`, `mcp_spec.md` (preferred for new files)
- Incorrect: `Source_Material_Model.md`, `Entity_Resolution.md` (unless it's a special file)

**When in Doubt:**
- Use all lowercase
- Only use uppercase for widely recognized special files (README, CHANGELOG) or acronym-heavy spec files

## When Creating or Renaming

1. Use underscores (snake_case) for all filenames and folder names
2. Use underscores when referencing files or folders in documentation
3. Symlinks automatically use `foundation_` prefix (e.g., `foundation_create_feature_unit.md`)

## Migration

If existing files or folders use kebab-case:

1. Rename from `command-name.md` to `command_name.md` or `folder-name/` to `folder_name/`
2. Update references in `foundation_config.yaml`, documentation files, and scripts
3. Run `setup_cursor_rules.sh` to update symlinks
