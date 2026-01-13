# Foundation Scripts

This directory contains shared scripts used across repositories that integrate with the foundation framework.

## Available Scripts

### 1Password Environment Sync

**Script:** `op_sync_env_from_1password.py`

Syncs environment variables from 1Password to your local `.env` file.

#### Features

- **Automatic backup**: Creates timestamped backup in `.env.backups/` before modification
- **Session check**: Verifies 1Password CLI session before proceeding
- **Security**: NEVER prints secret values, only variable names
- **MCP Integration**: Uses parquet MCP server for data access (per MCP access policy)
- **Configurable exclusions**: Instance-specific exclusion lists via `foundation-config.local.yaml`
- **Repository-agnostic**: Detects repo root and adapts to different repository structures
- **Environment-based secrets**: Supports different secrets for development vs production

#### Requirements

- 1Password CLI (`op`) installed and signed in (`op signin`)
- Python 3.9+ recommended
- pandas and pyarrow for parquet file reading (fallback)
- mcp package for MCP server integration (primary method)

#### Configuration

##### Environment Variable Mappings

Mappings are stored in `data/env_var_mappings/env_var_mappings.parquet` and accessed via the parquet MCP server.

**Parquet file columns:**
- `env_var`: Environment variable name (e.g., `OPENAI_API_KEY`)
- `op_reference`: 1Password `op://` reference (e.g., `op://Private/OpenAI/api_key`)
- `environment_based`: Boolean flag for environment-specific secrets
- `environment_key`: Environment name (`development` or `production`) if environment_based is true
- Other metadata columns (service, notes, etc.)

**To add/update mappings:**

Use the parquet MCP server tools:

```python
# Example: Add a new mapping
mcp_parquet_add_record(
    data_type="env_var_mappings",
    record={
        "env_var": "NEW_API_KEY",
        "op_reference": "op://Private/ServiceName/api_key",
        "environment_based": False,
        "optional": False,
        "service": "ServiceName"
    }
)
```

**To find 1Password references:**

```bash
op item get "<item-name>" --format=json
```

##### Exclusion Lists

Exclusion lists define variables that should be removed during sync (e.g., deprecated variables, renamed variables).

**Repo-wide exclusions** (committed):
Add to `foundation-config.yaml`:

```yaml
tooling:
  env_management:
    onepassword_sync:
      default_exclusions:
        - "DEPRECATED_VAR_NAME"
        - "OLD_API_KEY"
```

**Instance-specific exclusions** (gitignored):
Add to `foundation-config.local.yaml`:

```yaml
tooling:
  env_management:
    onepassword_sync:
      exclusions:
        - "COINBASE_API_KEY_ADVANCED"  # Deprecated
        - "FALLBACK_ASSIGNEE_EMAIL"    # Replaced by ASANA_FALLBACK_ASSIGNEE_EMAIL
```

**Template file:**
Copy `foundation-config.local.yaml.example` to `foundation-config.local.yaml` and customize.

##### Environment-Based Secrets

For secrets that differ between development and production (e.g., API keys), set `environment_based: true` in the parquet file and specify `environment_key`.

The script uses the `ENVIRONMENT` environment variable (defaults to `development`) to select the correct secret.

**Example:**

```python
# Development key
{
    "env_var": "OPENAI_API_KEY",
    "op_reference": "op://Private/OpenAI/credential",
    "environment_based": True,
    "environment_key": "development"
}

# Production key
{
    "env_var": "OPENAI_API_KEY",
    "op_reference": "op://Private/OpenAI/api_key",
    "environment_based": True,
    "environment_key": "production"
}
```

#### Usage

**From repository root:**

```bash
# Sync to .env in repo root
python foundation/scripts/op_sync_env_from_1password.py

# Sync to custom path
python foundation/scripts/op_sync_env_from_1password.py path/to/.env.custom
```

**Via wrapper script** (if configured in consuming repository):

```bash
# Repository-specific wrapper
python scripts/op_sync_env_from_1password.py
```

#### How It Works

1. **Detects repository root** by looking for `foundation-config.yaml` or `.git` directory
2. **Loads configuration** from YAML files (local first, then committed)
3. **Reads mappings** from parquet file via MCP server (falls back to direct read if MCP unavailable)
4. **Checks 1Password session** to ensure CLI is authenticated
5. **Creates backup** of existing `.env` file in `.env.backups/`
6. **Resolves secrets** from 1Password using `op read` command
7. **Replaces `.env` file** with:
   - Managed variables (from 1Password)
   - Unmanaged variables (preserved from original file)
   - Excludes variables in exclusion lists

#### Security

- **Never prints secret values** - only variable names
- **Error messages sanitized** - no CLI output that might contain secrets
- **Backups gitignored** - `.env.backups/` directory is automatically ignored
- **MCP server integration** - follows MCP access policy for data operations
- **Local execution only** - never run in CI/CD

#### Troubleshooting

**1Password CLI not authenticated:**

```bash
# Sign in to 1Password
eval $(op signin)

# Or if using desktop app integration
op signin
```

**MCP server unavailable:**

The script automatically falls back to direct parquet file reading if the MCP server is unavailable. You'll see a warning message.

**Missing mappings file:**

Create the parquet file using the MCP parquet server or migration script. See repository-specific documentation.

**Placeholder values:**

Variables with `PLACEHOLDER_` prefix in the `op_reference` field are skipped until configured. Update the parquet file with actual 1Password references.

#### Integration with Consuming Repositories

To use this script in your repository:

1. **Install foundation** as a submodule or symlink
2. **Create wrapper script** at `scripts/op_sync_env_from_1password.py`:

```python
#!/usr/bin/env python3
"""Wrapper to call foundation 1Password sync script."""
import sys
from pathlib import Path

repo_root = Path(__file__).parent.parent
foundation_script = repo_root / "foundation" / "scripts" / "op_sync_env_from_1password.py"

if not foundation_script.exists():
    print("ERROR: Foundation script not found. Ensure foundation is installed.")
    sys.exit(1)

exec(open(foundation_script).read())
```

3. **Configure exclusions** in `foundation-config.local.yaml` (gitignored)
4. **Create mappings** in `data/env_var_mappings/env_var_mappings.parquet` via MCP

### Other Scripts

- `install_foundation.sh` / `install-foundation.sh`: Foundation installation scripts
- `setup_cursor_rules.sh`: Sets up Cursor rules symlinks
- `sync_foundation.sh`: Syncs foundation updates
- `validate_setup.sh`: Validates foundation setup
- `report_error_*.sh`: Error reporting utilities

## Contributing

When adding new scripts to this directory:

1. Make them repository-agnostic (detect repo root, use configuration)
2. Document usage and configuration in this README
3. Follow security best practices (never print secrets)
4. Use MCP server for data access when applicable
5. Provide clear error messages and troubleshooting guidance
