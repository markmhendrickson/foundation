"""
Sync selected secrets from 1Password into a local .env file.

This is a generalized script from the foundation repository that works across
multiple repositories by detecting the repo root and loading configuration.

Design:
- Read a mapping of ENV_VAR -> 1Password reference from parquet file via MCP server.
  Each reference is an op:// URL: op://<vault>/<item>/<field>
- Use the `op` CLI to resolve each secret.
- Update (or append) the corresponding ENV_VAR entries in the target .env file.

Features:
- Automatic backup: Creates timestamped backup in .env.backups/ before modification
- Session check: Verifies 1Password CLI session before proceeding
- Security: NEVER prints secret values, only variable names
- MCP Integration: Uses parquet MCP server for data access (per MCP access policy)
- Configurable inclusions: Whitelist specific variables to sync (optional)
- Configurable exclusions: Instance-specific exclusion lists via foundation-config.local.yaml
- Repository-agnostic: Detects repo root and adapts to different repository structures

Safety:
- This script NEVER prints secret values or CLI output that might contain secrets.
- It only prints which keys were updated.
- Backups are stored in .env.backups/ (gitignored via .env.* pattern).
- Run this locally, not in CI, and never commit .env to git.

Requirements:
- 1Password CLI (`op`) installed and signed in (`op signin`).
- Python 3.9+ recommended.
- mcp package for MCP server integration (required).

Configuration:
- Mappings stored in data/env_var_mappings/env_var_mappings.parquet (accessed via MCP)
- Inclusion lists (whitelist) in foundation-config.yaml - if specified, only these variables are synced
- Exclusion lists in foundation-config.local.yaml (gitignored, instance-specific)
- Default exclusions in foundation-config.yaml (committed, repo-wide)
- Update mappings via MCP parquet server (add_record/update_record)
- Variables with "PLACEHOLDER_" prefix are skipped until configured
- To find references: op item get "<item-name>" --format=json

Inclusion List (Whitelist):
- If an inclusion list is specified, ONLY variables in that list will be synced
- Supports flat list: inclusions: [VAR1, VAR2, ...]
- Supports nested format from expected_variables (required, recommended, optional, production)
- If no inclusion list is specified, all variables with mappings are synced (default)

Usage:
    python foundation/scripts/op_sync_env_from_1password.py           # uses .env in repo root
    python foundation/scripts/op_sync_env_from_1password.py path/to/.env.custom
"""

from __future__ import annotations

import argparse
import os
import subprocess
from datetime import datetime
from pathlib import Path
from typing import Any

import pandas as pd

# Try to import YAML parser
try:
    import yaml
except ImportError:
    yaml = None  # type: ignore

# Try to import MCP client dependencies
try:
    import asyncio
    import json

    from mcp import ClientSession, StdioServerParameters
    from mcp.client.stdio import stdio_client

    MCP_AVAILABLE = True
except ImportError:
    MCP_AVAILABLE = False


def find_repo_root(start_path: Path | None = None) -> Path:
    """
    Find repository root by looking for foundation-config.yaml or .git directory.

    Args:
        start_path: Path to start searching from (defaults to script location)

    Returns:
        Path to repository root

    Raises:
        RuntimeError: If repository root cannot be found
    """
    if start_path is None:
        # Start from script location (foundation/scripts/)
        start_path = Path(__file__).parent.parent.parent

    current = start_path.resolve()

    # Walk up directory tree looking for indicators
    for _ in range(10):  # Limit search depth
        # Check for foundation-config.yaml (primary indicator)
        if (current / "foundation-config.yaml").exists():
            return current

        # Check for .git directory (secondary indicator)
        if (current / ".git").exists():
            return current

        # Move up one level
        parent = current.parent
        if parent == current:  # Reached filesystem root
            break
        current = parent

    raise RuntimeError(
        "Could not find repository root. "
        "Ensure foundation-config.yaml or .git exists in the repository."
    )


def load_config(repo_root: Path) -> dict[str, Any]:
    """
    Load configuration from YAML files (local first, then committed).

    Args:
        repo_root: Path to repository root

    Returns:
        Merged configuration dictionary
    """
    if yaml is None:
        return {}

    config: dict[str, Any] = {}

    # Load committed config first (lower priority)
    committed_config = repo_root / "foundation-config.yaml"
    if committed_config.exists():
        try:
            with open(committed_config, encoding="utf-8") as f:
                committed_data = yaml.safe_load(f) or {}
                config = committed_data
        except Exception as e:
            print(f"WARNING: Failed to load {committed_config}: {e}")

    # Load local config (higher priority, overrides committed)
    local_config = repo_root / "foundation-config.local.yaml"
    if local_config.exists():
        try:
            with open(local_config, encoding="utf-8") as f:
                local_data = yaml.safe_load(f) or {}
                # Deep merge local config into committed config
                # For now, just override at top level
                config.update(local_data)
        except Exception as e:
            print(f"WARNING: Failed to load {local_config}: {e}")

    return config


def get_exclusions(config: dict[str, Any]) -> set[str]:
    """
    Get exclusion list from configuration.

    Args:
        config: Configuration dictionary

    Returns:
        Set of variable names to exclude
    """
    exclusions: set[str] = set()

    # Get default exclusions from committed config
    try:
        default_exclusions = (
            config.get("tooling", {})
            .get("env_management", {})
            .get("onepassword_sync", {})
            .get("default_exclusions", [])
        )
        if default_exclusions:
            exclusions.update(default_exclusions)
    except (AttributeError, TypeError):
        pass

    # Get instance-specific exclusions from local config
    try:
        local_exclusions = (
            config.get("tooling", {})
            .get("env_management", {})
            .get("onepassword_sync", {})
            .get("exclusions", [])
        )
        if local_exclusions:
            exclusions.update(local_exclusions)
    except (AttributeError, TypeError):
        pass

    return exclusions


def get_inclusions(config: dict[str, Any]) -> set[str] | None:
    """
    Get inclusion list (whitelist) from configuration.

    If an inclusion list is specified, only variables in this list will be synced.
    If None, all variables with mappings will be synced (default behavior).

    Args:
        config: Configuration dictionary

    Returns:
        Set of variable names to include, or None if no inclusion list is specified
    """
    inclusions: set[str] = set()

    # Get inclusions from committed config
    try:
        onepassword_sync = (
            config.get("tooling", {})
            .get("env_management", {})
            .get("onepassword_sync", {})
        )

        # Support flat list format: inclusions: [VAR1, VAR2, ...]
        flat_inclusions = onepassword_sync.get("inclusions", [])
        if flat_inclusions:
            inclusions.update(flat_inclusions)

        # Support nested format from expected_variables:
        # expected_variables:
        #   required: [VAR1, VAR2]
        #   recommended: [VAR3]
        #   optional: [VAR4]
        expected_vars = onepassword_sync.get("expected_variables", {})
        if expected_vars:
            # Flatten all categories into a single list
            for category in ["required", "recommended", "optional", "production"]:
                category_vars = expected_vars.get(category, [])
                if category_vars:
                    inclusions.update(category_vars)
    except (AttributeError, TypeError):
        pass

    # Get instance-specific inclusions from local config
    try:
        local_inclusions = (
            config.get("tooling", {})
            .get("env_management", {})
            .get("onepassword_sync", {})
            .get("inclusions", [])
        )
        if local_inclusions:
            inclusions.update(local_inclusions)
    except (AttributeError, TypeError):
        pass

    # Return None if no inclusions specified (means sync all)
    # Return set if inclusions specified (means whitelist mode)
    return inclusions if inclusions else None


class ParquetMCPClient:
    """Minimal MCP client for reading env_var_mappings parquet file."""

    def __init__(self, repo_root: Path):
        """
        Initialize Parquet MCP client.

        Args:
            repo_root: Path to repository root
        """
        self.repo_root = repo_root
        self.parquet_server_path, self.parquet_server_command = self._detect_parquet_server()

    def _detect_parquet_server(self) -> tuple[str, str]:
        """
        Auto-detect parquet MCP server location.
        
        Returns:
            Tuple of (server_path, command) where:
            - server_path: Path to the server script
            - command: Command to run (python3, bash, or from config)
        """
        # Try environment variable first
        env_path = os.getenv("PARQUET_MCP_SERVER_PATH")
        if env_path and Path(env_path).exists():
            # Determine command based on file extension
            if env_path.endswith(".sh"):
                return (env_path, "bash")
            else:
                return (env_path, self._get_python_command())

        # Check Cursor config location: ~/.cursor/mcp.json
        cursor_config_path = Path.home() / ".cursor" / "mcp.json"
        if cursor_config_path.exists():
            try:
                import json
                with open(cursor_config_path, encoding="utf-8") as f:
                    cursor_config = json.load(f)
                    mcp_servers = cursor_config.get("mcpServers", {})
                    # Look for parquet server in Cursor config
                    for server_name, server_config in mcp_servers.items():
                        # Check if server name contains "parquet" (case-insensitive)
                        if "parquet" in server_name.lower():
                            # Get command path from config
                            command = server_config.get("command")
                            if command and Path(command).exists():
                                # Determine command based on file extension
                                if command.endswith(".sh"):
                                    return (command, "bash")
                                elif command.endswith(".py"):
                                    return (command, self._get_python_command())
                                else:
                                    # Try to extract command from args if present
                                    args = server_config.get("args", [])
                                    if args and len(args) > 0:
                                        # If args[0] is a Python script, use python command
                                        if args[0].endswith(".py"):
                                            return (args[0], self._get_python_command())
                                    # Default to using the command as-is
                                    return (command, command)
            except (json.JSONDecodeError, KeyError, Exception) as e:
                # Silently continue if config parsing fails
                pass

        # Check repo location: mcp/parquet/parquet_mcp_server.py
        server_path = self.repo_root / "mcp" / "parquet" / "parquet_mcp_server.py"
        if server_path.exists():
            return (str(server_path), self._get_python_command())

        raise RuntimeError(
            "Could not find parquet MCP server. "
            f"Checked: environment variable, ~/.cursor/mcp.json, and {server_path}\n"
            "Set PARQUET_MCP_SERVER_PATH environment variable, configure in ~/.cursor/mcp.json, "
            "or ensure the server is at mcp/parquet/parquet_mcp_server.py"
        )

    def _get_python_command(self) -> str:
        """Get the Python command to use for running the parquet server."""
        # Try to find venv Python relative to repo root
        possible_venv_paths = [
            self.repo_root / "venv" / "bin" / "python3",
            self.repo_root / "execution" / "venv" / "bin" / "python3",
            self.repo_root / ".venv" / "bin" / "python3",
        ]

        for venv_python in possible_venv_paths:
            if venv_python.exists():
                return str(venv_python)

        # Fall back to system python3
        return os.getenv("PARQUET_MCP_PYTHON", "python3")

    async def _call_tool(
        self, tool_name: str, arguments: dict[str, Any]
    ) -> dict[str, Any]:
        """Call a tool on the parquet MCP server."""
        # Use the command determined during detection (python3, bash, etc.)
        cmd = self.parquet_server_command

        # Load .env file from repo root to get DATA_DIR and other env vars
        # Priority: 1) .env file, 2) environment variable, 3) default to repo_root/data
        env = os.environ.copy()
        env_file = self.repo_root / ".env"
        if env_file.exists():
            # Simple env file parsing (don't use dotenv to avoid dependency)
            with open(env_file, encoding="utf-8") as f:
                for line in f:
                    line = line.strip()
                    if line and not line.startswith("#") and "=" in line:
                        key, value = line.split("=", 1)
                        key = key.strip()
                        value = value.strip().strip('"').strip("'")
                        if key:
                            # Override existing env vars with .env file values
                            # This allows .env to override environment variables
                            env[key] = value

        # Auto-set DATA_DIR if not already set (defaults to repo_root/data)
        # This ensures MCP server can find the data directory
        # If DATA_DIR is set in .env or environment, it will be used (matches Cursor MCP config)
        if "DATA_DIR" not in env:
            data_dir = self.repo_root / "data"
            env["DATA_DIR"] = str(data_dir.resolve())

        try:
            # Prepare args: if command is bash/python3, pass server_path as arg
            # If command is the script itself, use empty args
            if cmd in ["bash", "python3", "python"] or cmd.endswith("python3") or cmd.endswith("python"):
                args = [self.parquet_server_path]
            else:
                # Command is the script itself, no args needed
                args = []
            
            async with stdio_client(
                StdioServerParameters(
                    command=cmd, args=args, env=env
                )
            ) as (read, write):
                async with ClientSession(read, write) as session:
                    await session.initialize()
                    result = await session.call_tool(tool_name, arguments)
                    # Parse the text content from the result
                    if result.content and len(result.content) > 0:
                        return json.loads(result.content[0].text)
                    return {}
        except Exception as e:
            # Re-raise with more context
            raise RuntimeError(
                f"Failed to call parquet MCP tool '{tool_name}': {e}. "
                f"Python: {python_cmd}, Server: {self.parquet_server_path}"
            ) from e

    def call_tool_sync(
        self, tool_name: str, arguments: dict[str, Any]
    ) -> dict[str, Any]:
        """Synchronous wrapper for calling MCP tools."""
        return asyncio.run(self._call_tool(tool_name, arguments))

    def read_env_var_mappings(self) -> list[dict]:
        """
        Read env_var_mappings from parquet via MCP.

        Returns:
            List of mapping records
        """
        result = self.call_tool_sync(
            "read_parquet",
            {
                "data_type": "env_var_mappings",
                "columns": [
                    "env_var",
                    "op_reference",
                    "environment_based",
                    "environment_key",
                ],
            },
        )
        return result.get("data", [])


def load_mappings_via_mcp(repo_root: Path) -> tuple[dict[str, str], set[str]]:
    """
    Load environment variable mappings via parquet MCP server (primary method).

    Args:
        repo_root: Path to repository root

    Returns:
        Tuple of (dictionary mapping env_var names to op:// references, set of environment-based keys)

    Raises:
        RuntimeError: If MCP server is unavailable or fails
    """
    if not MCP_AVAILABLE:
        raise RuntimeError(
            "MCP client dependencies not available. Install with: pip install mcp"
        )

    client = ParquetMCPClient(repo_root)
    records = client.read_env_var_mappings()

    env_to_op_ref: dict[str, str] = {}
    environment_based_keys: set[str] = set()
    current_env = os.getenv("ENVIRONMENT", "development").lower()

    for record in records:
        env_var = record.get("env_var")
        op_ref = record.get("op_reference")

        if not env_var or not op_ref:
            continue

        # Skip placeholder values
        if pd.isna(op_ref) or str(op_ref).startswith("PLACEHOLDER_"):
            continue

        # Handle environment-based keys
        is_environment_based = record.get("environment_based", False)
        if is_environment_based:
            env_key = str(record.get("environment_key", "")).lower()
            if env_key != current_env:
                continue
            environment_based_keys.add(env_var)

        env_to_op_ref[env_var] = str(op_ref)

    return env_to_op_ref, environment_based_keys


def load_mappings_from_parquet(repo_root: Path) -> tuple[dict[str, str], set[str]]:
    """
    Load environment variable mappings from parquet file directly (fallback method).

    Args:
        repo_root: Path to repository root

    Returns:
        Tuple of (dictionary mapping env_var names to op:// references, set of environment-based keys)

    Raises:
        FileNotFoundError: If parquet file doesn't exist
    """
    mappings_file = repo_root / "data" / "env_var_mappings" / "env_var_mappings.parquet"

    if not mappings_file.exists():
        raise FileNotFoundError(
            f"Environment variable mappings file not found: {mappings_file}\n"
            "Create it using the MCP parquet server or by running the migration script."
        )

    df = pd.read_parquet(mappings_file)
    env_to_op_ref: dict[str, str] = {}
    environment_based_keys: set[str] = set()

    # Get current environment for environment-based keys
    current_env = os.getenv("ENVIRONMENT", "development").lower()

    for _, row in df.iterrows():
        env_var = row["env_var"]
        op_ref = row["op_reference"]

        # Skip placeholder values
        if pd.isna(op_ref) or str(op_ref).startswith("PLACEHOLDER_"):
            continue

        # Handle environment-based keys
        is_environment_based = row.get("environment_based", False)
        if is_environment_based:
            # Only include if this row matches the current environment
            env_key = str(row.get("environment_key", "")).lower()
            if env_key != current_env:
                continue
            environment_based_keys.add(env_var)

        # For environment-based keys, we might have multiple rows (dev/prod)
        # Only add if not already present, or replace if this is the matching environment
        if env_var not in env_to_op_ref or is_environment_based:
            env_to_op_ref[env_var] = str(op_ref)

    return env_to_op_ref, environment_based_keys


def load_env_mappings(repo_root: Path) -> tuple[dict[str, str], set[str]]:
    """
    Load environment variable to 1Password op:// reference mappings via MCP parquet server.

    Always uses MCP server - no direct file access (per MCP access policy).

    Args:
        repo_root: Path to repository root

    Returns:
        Tuple of (dictionary mapping env_var names to op:// references, set of environment-based keys)

    Raises:
        RuntimeError: If MCP is unavailable or fails
    """
    if not MCP_AVAILABLE:
        raise RuntimeError(
            "MCP client dependencies not available. Install with: pip install mcp"
        )

    print("Loading mappings via parquet MCP server...")
    return load_mappings_via_mcp(repo_root)


def check_op_session() -> bool:
    """
    Check if 1Password CLI session is active.

    Returns:
        True if session is active, False otherwise.

    Security: Never prints any output from `op whoami` to avoid exposing tokens.
    """
    try:
        result = subprocess.run(
            ["op", "whoami"],
            capture_output=True,
            text=True,
            timeout=5,
        )
        return result.returncode == 0
    except (subprocess.TimeoutExpired, FileNotFoundError):
        return False


def backup_env_file(env_path: Path, repo_root: Path) -> Path | None:
    """
    Create timestamped backup of .env file in .env.backups/ directory.

    Args:
        env_path: Path to .env file to backup
        repo_root: Path to repository root

    Returns:
        Path to backup file if backup was created, None if file didn't exist

    Security: Never prints file contents, only paths.
    """
    if not env_path.exists():
        return None

    backup_dir = repo_root / ".env.backups"
    backup_dir.mkdir(parents=True, exist_ok=True)

    # Create timestamped backup filename
    timestamp = datetime.now().strftime("%Y-%m-%d-%H%M%S")
    backup_filename = f".env-{timestamp}"
    backup_path = backup_dir / backup_filename

    # Copy file contents
    backup_path.write_text(env_path.read_text(encoding="utf-8"), encoding="utf-8")

    print(f"Backup created: {backup_path}")
    return backup_path


def op_read(ref: str) -> str:
    """
    Read a secret value from 1Password using `op read <ref>`.

    Security: Error messages never include CLI output that might contain secrets.
    """
    try:
        result = subprocess.run(
            ["op", "read", ref],
            check=True,
            capture_output=True,
            text=True,
        )
    except subprocess.CalledProcessError as e:  # noqa: BLE001
        # SECURITY: Never include e.stderr or e.stdout in error message
        # as they might contain sensitive information
        raise RuntimeError(
            f"1Password CLI error for {ref}. "
            f"Ensure 'op' is installed and you're signed in (run: op signin)"
        ) from e

    value = result.stdout.rstrip("\n")
    if not value:
        raise RuntimeError(f"Empty value returned for 1Password ref: {ref}")
    return value


def write_json_to_creds_file(json_content: str, filename: str, repo_root: Path) -> Path:
    """
    Write JSON content to a gitignored .creds directory in the repo and return the path.
    
    Args:
        json_content: JSON string content to write
        filename: Name for the file (e.g., "gcp-oauth.keys.json")
        repo_root: Path to repository root
    
    Returns:
        Path to the created file
    """
    # Use repo-relative .creds directory (gitignored)
    creds_dir = repo_root / ".creds"
    creds_dir.mkdir(parents=True, exist_ok=True)
    file_path = creds_dir / filename
    
    # Validate JSON before writing
    try:
        json.loads(json_content)
    except json.JSONDecodeError:
        # If not valid JSON, try to use as-is (might be a file path)
        pass
    
    # Write to file
    file_path.write_text(json_content, encoding="utf-8")
    return file_path


def needs_file_write(env_key: str, value: str) -> bool:
    """
    Determine if an environment variable needs its value written to a file.
    
    Variables that end with _CREDENTIALS and contain JSON should be written to files.
    GOOGLE_APPLICATION_CREDENTIALS always needs a file path (even if value is already a path).
    """
    # GOOGLE_APPLICATION_CREDENTIALS always expects a file path
    if env_key == "GOOGLE_APPLICATION_CREDENTIALS":
        # If it's already a file path (not JSON), use it as-is
        if not value.strip().startswith("{") and (value.endswith(".json") or "/" in value or "\\" in value):
            return False  # Already a file path, don't write
        # If it's JSON content, write it to a file
        try:
            json.loads(value)
            return True  # It's JSON, write to file
        except (json.JSONDecodeError, TypeError):
            return False  # Not JSON, assume it's already a path
    
    # Other _CREDENTIALS variables: write if they contain JSON
    if env_key.endswith("_CREDENTIALS"):
        try:
            json.loads(value)
            return True
        except (json.JSONDecodeError, TypeError):
            return False
    
    return False


def parse_env_file(path: Path) -> tuple[list[str], dict[str, str]]:
    """
    Parse .env file into comments/headers and variable dictionary.

    Returns:
        Tuple of (comment_lines, variables_dict)
    """
    if not path.exists():
        return [], {}

    lines = path.read_text(encoding="utf-8").splitlines()
    comment_lines: list[str] = []
    variables: dict[str, str] = {}

    for line in lines:
        stripped = line.strip()
        # Preserve comments and empty lines
        if not stripped or stripped.startswith("#"):
            comment_lines.append(line)
            continue

        # Parse variable assignments
        if "=" in line:
            key, value = line.split("=", 1)
            key = key.strip()
            if key:
                variables[key] = value.strip()
        else:
            # Non-comment line without =, preserve as-is
            comment_lines.append(line)

    return comment_lines, variables


def sync_env(
    target_path: Path,
    repo_root: Path,
    exclusions: set[str],
    inclusions: set[str] | None = None,
) -> None:
    """
    Resolve all environment variable mappings via op, then REPLACE the .env file.

    Preserves unmanaged variables (variables not in 1Password mappings).
    Replaces managed variables with values from 1Password.

    Args:
        target_path: Path to .env file
        repo_root: Path to repository root
        exclusions: Set of variable names to exclude from preservation
        inclusions: Optional set of variable names to include (whitelist).
                   If None, all variables with mappings are synced.

    Security: Only prints environment variable names, never values.
    Skips variables with PLACEHOLDER references that need to be configured.
    """
    print(f"Target .env file: {target_path}")

    # Load mappings from parquet file (via MCP or direct)
    try:
        env_to_op_ref, environment_based_keys = load_env_mappings(repo_root)
    except FileNotFoundError as e:
        print(f"\nERROR: {e}")
        return

    if not env_to_op_ref:
        print("\nWARNING: No environment variable mappings found in parquet file.")
        return

    # Apply inclusion list (whitelist) if specified
    if inclusions is not None:
        original_count = len(env_to_op_ref)
        env_to_op_ref = {k: v for k, v in env_to_op_ref.items() if k in inclusions}
        filtered_count = original_count - len(env_to_op_ref)
        if filtered_count > 0:
            print(f"\nInclusion list active: {filtered_count} variable(s) filtered out")
            print(f"Syncing {len(env_to_op_ref)} variable(s) from inclusion list")
        if not env_to_op_ref:
            print(
                "\nWARNING: No environment variable mappings match the inclusion list."
            )
            print("Available variables in parquet (not in inclusion list):")
            all_mappings = load_env_mappings(repo_root)
            for var in sorted(all_mappings.keys()):
                if var not in inclusions:
                    print(f"  - {var}")
            return

    # Parse existing .env file
    comment_lines, existing_vars = parse_env_file(target_path)

    # Identify unmanaged variables (variables not in 1Password mappings)
    managed_var_names = set(env_to_op_ref.keys())
    unmanaged_vars = {
        k: v
        for k, v in existing_vars.items()
        if k not in managed_var_names and k not in exclusions
    }

    if unmanaged_vars:
        print(f"\nPreserving {len(unmanaged_vars)} unmanaged variable(s):")
        for var in sorted(unmanaged_vars.keys()):
            print(f"  - {var}")

    if exclusions:
        excluded_count = sum(1 for k in existing_vars if k in exclusions)
        if excluded_count > 0:
            print(f"\nExcluding {excluded_count} variable(s) from preservation:")
            for var in sorted(k for k in existing_vars if k in exclusions):
                print(f"  - {var}")

    # Resolve managed variables from 1Password
    updated = []
    skipped = []
    resolved_vars: dict[str, str] = {}
    environment = os.getenv("ENVIRONMENT", "development").lower()

    for env_key, op_ref in env_to_op_ref.items():
        # Skip placeholder values that need to be configured
        if op_ref.startswith("PLACEHOLDER_"):
            skipped.append(env_key)
            # If placeholder variable exists in current file, preserve it
            if env_key in existing_vars:
                resolved_vars[env_key] = existing_vars[env_key]
                print(f"- Preserving {env_key} (placeholder, using existing value)...")
            continue

        # Show environment info for environment-based keys
        if env_key in environment_based_keys:
            print(f"- Resolving {env_key} (using {environment} key)...")
        else:
            print(f"- Resolving {env_key}...")

        try:
            value = op_read(op_ref)
            
            # Special handling: Write JSON credentials to .creds file if needed
            if needs_file_write(env_key, value):
                # Generate filename from env var name
                if env_key == "GOOGLE_OAUTH_CREDENTIALS":
                    filename = "gcp-oauth.keys.json"
                elif env_key == "GOOGLE_APPLICATION_CREDENTIALS":
                    filename = "gcp-service-account.json"
                else:
                    # Generic fallback: convert ENV_VAR_CREDENTIALS to filename
                    filename = env_key.lower().replace("_", "-") + ".json"
                
                # Write JSON to .creds file
                creds_file_path = write_json_to_creds_file(value, filename, repo_root)
                # Set env var to relative path from repo root
                relative_path = creds_file_path.relative_to(repo_root)
                resolved_vars[env_key] = f'"{relative_path}"'
                print(f"  → Saved JSON to {relative_path}")
            else:
                # Regular value: wrap in quotes
                resolved_vars[env_key] = f'"{value}"'
            
            updated.append(env_key)
        except RuntimeError as e:
            print(f"  WARNING: Failed to resolve {env_key}: {e}")
            # If variable exists in current file, preserve it as fallback
            if env_key in existing_vars:
                resolved_vars[env_key] = existing_vars[env_key]
                print("  Using existing value as fallback")

    # Build new .env file content
    new_lines: list[str] = []

    # Add comments/headers from original file (strip leading empty lines and our own section headers)
    stripped_comments = comment_lines[:]
    # Remove leading empty lines
    while stripped_comments and not stripped_comments[0].strip():
        stripped_comments.pop(0)
    # Remove our own section headers if they exist (from previous runs)
    stripped_comments = [
        line
        for line in stripped_comments
        if not line.strip().startswith("# Variables managed by 1Password sync")
        and not line.strip().startswith("# Variables not managed by 1Password")
    ]
    # Remove trailing empty lines from comments
    while stripped_comments and not stripped_comments[-1].strip():
        stripped_comments.pop()
    new_lines.extend(stripped_comments)

    # Add managed variables (from 1Password)
    if resolved_vars:
        # Add separator only if we have meaningful comments (don't start file with empty line)
        if stripped_comments:
            new_lines.append("")  # Blank line separator
        new_lines.append("# Variables managed by 1Password sync")
        for key in sorted(resolved_vars.keys()):
            new_lines.append(f"{key}={resolved_vars[key]}")

    # Add unmanaged variables (preserved from original file)
    if unmanaged_vars:
        new_lines.append("")
        new_lines.append("# Variables not managed by 1Password (preserved)")
        for key in sorted(unmanaged_vars.keys()):
            new_lines.append(f"{key}={unmanaged_vars[key]}")

    # Write new file (replaces entire file)
    target_path.write_text("\n".join(new_lines) + "\n", encoding="utf-8")

    if updated:
        print(
            f"\n✓ Replaced {len(updated)} managed variable(s) in .env (values NOT shown):"
        )
        for k in sorted(updated):
            print(f"  - {k}")
    else:
        print("\nNo managed variables were updated.")

    if skipped:
        print("\nSkipped keys with PLACEHOLDER references (need configuration):")
        for k in skipped:
            print(f"  - {k}")
        print("\nTo configure these variables:")
        print('  1. Find the 1Password item: op item get "<item-name>" --format=json')
        print(
            "  2. Update data/env_var_mappings/env_var_mappings.parquet with actual op:// references"
        )
        print(
            "  3. Use MCP parquet server (add_record/update_record) or edit parquet directly"
        )
        print("  4. Remove the PLACEHOLDER_ prefix from op_reference field")


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Sync selected env vars from 1Password into a .env file.",
    )
    parser.add_argument(
        "env_path",
        nargs="?",
        help="Path to .env file (default: .env in repo root)",
    )
    args = parser.parse_args()

    # Find repository root
    try:
        repo_root = find_repo_root()
        print(f"Repository root: {repo_root}\n")
    except RuntimeError as e:
        print(f"ERROR: {e}")
        return 1

    # Load configuration
    config = load_config(repo_root)
    exclusions = get_exclusions(config)
    inclusions = get_inclusions(config)

    if exclusions:
        print(f"Loaded {len(exclusions)} exclusion(s) from configuration")
    if inclusions:
        print(f"Inclusion list active: {len(inclusions)} variable(s) will be synced")

    # Determine target .env file path
    if args.env_path:
        target = Path(args.env_path).expanduser()
    else:
        # Default to .env in repo root
        target = repo_root / ".env"

    # Step 1: Check 1Password session
    print("\nChecking 1Password session...")
    if not check_op_session():
        print("\nERROR: 1Password CLI is not authenticated.")
        print("Please sign in to 1Password:")
        print("  eval $(op signin)")
        print("\nOr if using desktop app integration:")
        print("  op signin")
        return 1
    print("✓ 1Password session active\n")

    # Step 2: Backup existing .env file
    print("Creating backup...")
    backup_path = backup_env_file(target, repo_root)
    if backup_path:
        print(f"✓ Backup created: {backup_path}\n")
    else:
        print(f"No existing .env file to backup at: {target}\n")

    # Step 3: Sync environment variables
    print("Syncing environment variables from 1Password...\n")
    try:
        sync_env(target, repo_root, exclusions, inclusions)
        print("\n✓ Sync completed successfully!")
        return 0
    except Exception as e:
        print(f"\n✗ Sync failed: {e}")
        if backup_path:
            print(f"\nYou can restore from backup: {backup_path}")
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
