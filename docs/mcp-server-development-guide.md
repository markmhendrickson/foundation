# MCP Server Development Guide

**Purpose:** Standardized guidance for building MCP servers, based on analysis of existing MCP servers in this repository.

**Last Updated:** 2025-12-26

## Table of Contents

1. [Overview](#overview)
2. [Repository Structure](#repository-structure)
3. [Implementation Patterns](#implementation-patterns)
4. [Authentication & Configuration](#authentication--configuration)
5. [Tool Implementation](#tool-implementation)
6. [Error Handling](#error-handling)
7. [Documentation Requirements](#documentation-requirements)
8. [Testing & Validation](#testing--validation)
9. [Deployment & Distribution](#deployment--distribution)
10. [Examples from Existing Servers](#examples-from-existing-servers)

## Overview

MCP (Model Context Protocol) servers provide a standardized interface for AI assistants to interact with external systems and data sources. This guide establishes patterns based on existing servers in this repository.

### Server Types

**Truth Layer Servers** (`truth/mcp-servers/`):
- Provide access to the Truth Layer data substrate
- Read/write operations on parquet files
- Example: `parquet/` - Data access server

**Execution Layer Servers** (`execution/mcp-servers/`):
- External API integrations
- Action execution on external systems
- Examples: `gmail/`, `dnsimple/`, `google-calendar/`, `instagram/`, `minted/`

### Language Choices

- **Python**: Simpler APIs, data processing, file operations
- **TypeScript/Node**: Complex async operations, web APIs, OAuth flows

## Repository Structure

### Submodule Organization

All MCP servers are **git submodules** in their own repositories:

```
truth/mcp-servers/
  └── parquet/          # Git submodule
execution/mcp-servers/
  ├── dnsimple/         # Git submodule
  ├── gmail/            # Git submodule
  ├── google-calendar/  # Git submodule
  ├── instagram/        # Git submodule
  └── minted/           # Git submodule
```

**Rationale:**
- Independent versioning and deployment
- Can be shared or transferred without affecting parent repo
- Each server manages its own dependencies

### Directory Structure

**Python Server (Simple):**
```
server-name/
├── __init__.py
├── server_name_mcp_server.py  # Main server file
├── README.md                  # Comprehensive documentation
├── requirements.txt           # Python dependencies
└── SETUP.md                   # Optional: Setup instructions
```

**Python Server (Complex):**
```
server-name/
├── __init__.py
├── src/
│   ├── __init__.py
│   ├── server_name_mcp_server.py
│   ├── config.py              # Configuration management
│   ├── client.py              # API client wrapper
│   └── models/
│       └── models.py          # Data models
├── tests/
│   └── test_*.py
├── README.md
├── requirements.txt
└── setup.py                   # Optional: Package setup
```

**TypeScript/Node Server:**
```
server-name/
├── src/
│   ├── index.ts              # Main entry point
│   ├── server.ts             # MCP server setup
│   ├── handlers/             # Tool handlers
│   ├── config/               # Configuration
│   └── types/                # TypeScript types
├── build/                    # Compiled output
├── package.json
├── tsconfig.json
├── README.md
└── Dockerfile                # Optional: Docker support
```

## Implementation Patterns

### Python Server Pattern

**Basic Structure:**
```python
#!/usr/bin/env python3
"""
MCP Server for [Service Name]

Provides tools for [description of functionality].
"""

import json
import os
import sys
from pathlib import Path
from typing import Any, Dict, List, Optional

from mcp.server import Server
from mcp.server.stdio import stdio_server
from mcp.types import Tool, TextContent

# Initialize MCP server
app = Server("server-name")

# Tool handlers
@app.list_tools()
async def list_tools() -> List[Tool]:
    """List available tools."""
    return [
        Tool(
            name="tool_name",
            description="Tool description",
            inputSchema={
                "type": "object",
                "properties": {
                    "param_name": {
                        "type": "string",
                        "description": "Parameter description"
                    }
                },
                "required": ["param_name"]
            }
        )
    ]

@app.call_tool()
async def call_tool(name: str, arguments: Any) -> List[TextContent]:
    """Handle tool calls."""
    if name == "tool_name":
        # Implementation
        result = {"success": True, "data": "..."}
        return [TextContent(type="text", text=json.dumps(result, indent=2))]
    
    raise ValueError(f"Unknown tool: {name}")

# Main entry point
if __name__ == "__main__":
    stdio_server(app)
```

### TypeScript/Node Server Pattern

**Basic Structure:**
```typescript
import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import {
  CallToolRequestSchema,
  ListToolsRequestSchema,
} from "@modelcontextprotocol/sdk/types.js";

const server = new Server(
  {
    name: "server-name",
    version: "1.0.0",
  },
  {
    capabilities: {
      tools: {},
    },
  }
);

// List tools
server.setRequestHandler(ListToolsRequestSchema, async () => ({
  tools: [
    {
      name: "tool_name",
      description: "Tool description",
      inputSchema: {
        type: "object",
        properties: {
          param_name: {
            type: "string",
            description: "Parameter description",
          },
        },
        required: ["param_name"],
      },
    },
  ],
}));

// Handle tool calls
server.setRequestHandler(CallToolRequestSchema, async (request) => {
  const { name, arguments: args } = request.params;

  if (name === "tool_name") {
    const result = { success: true, data: "..." };
    return {
      content: [
        {
          type: "text",
          text: JSON.stringify(result, null, 2),
        },
      ],
    };
  }

  throw new Error(`Unknown tool: ${name}`);
});

// Start server
async function main() {
  const transport = new StdioServerTransport();
  await server.connect(transport);
}

main().catch(console.error);
```

## Authentication & Configuration

### Priority Order (Standard Pattern)

1. **Environment Variables** (highest priority, recommended)
2. **Config Directory `.env` File** (portable, user-specific)
3. **1Password Integration** (optional, for backward compatibility)

### Python Authentication Pattern

```python
import os
from pathlib import Path
from typing import Optional

# Config directory (portable)
CONFIG_DIR = Path.home() / ".config" / "server-name-mcp"
CONFIG_DIR.mkdir(parents=True, exist_ok=True)
ENV_FILE = CONFIG_DIR / ".env"

# Optional: 1Password integration (backward compatibility)
HAS_CREDENTIALS_MODULE = False
try:
    server_dir = Path(__file__).parent
    possible_paths = [
        server_dir.parent.parent.parent,  # Adjust based on structure
        server_dir.parent.parent,
    ]
    
    for parent_path in possible_paths:
        credentials_path = parent_path / "execution" / "scripts" / "credentials.py"
        if credentials_path.exists():
            sys.path.insert(0, str(parent_path))
            try:
                from execution.scripts.credentials import get_credential, get_credential_by_domain
                HAS_CREDENTIALS_MODULE = True
                break
            except ImportError:
                continue
except Exception:
    pass

def load_credential_from_env() -> Optional[str]:
    """Load credential from environment variable or .env file."""
    # First check environment variable
    credential = os.getenv("SERVICE_API_TOKEN")
    if credential:
        return credential
    
    # Then check .env file
    if not ENV_FILE.exists():
        return None
    
    try:
        with open(ENV_FILE, "r") as f:
            for line in f:
                line = line.strip()
                if line.startswith("SERVICE_API_TOKEN="):
                    token = line.split("=", 1)[1].strip()
                    # Remove quotes if present
                    if token.startswith('"') and token.endswith('"'):
                        token = token[1:-1]
                    elif token.startswith("'") and token.endswith("'"):
                        token = token[1:-1]
                    return token
    except Exception:
        pass
    
    return None

def get_credential_from_1password() -> Optional[str]:
    """Get credential from 1Password."""
    if not HAS_CREDENTIALS_MODULE:
        return None
    
    try:
        field_names = ["api_token", "token", "access token"]
        for field_name in field_names:
            try:
                token = get_credential("ServiceName", field=field_name)
                if token:
                    return token
            except (ValueError, KeyError):
                continue
        
        try:
            token = get_credential_by_domain("service.com", field="api_token")
            if token:
                return token
        except (ValueError, KeyError):
            pass
        
        return None
    except Exception:
        return None

def get_credential() -> Optional[str]:
    """Get credential from environment variable, .env file, or 1Password."""
    credential = load_credential_from_env()
    if credential:
        return credential
    
    credential = get_credential_from_1password()
    return credential
```

### Configuration Directory Pattern

**Location:** `~/.config/[server-name]-mcp/`

**Benefits:**
- Portable (not tied to repository structure)
- User-specific configuration
- Secure (restricted permissions)

**Implementation:**
```python
CONFIG_DIR = Path.home() / ".config" / "server-name-mcp"
CONFIG_DIR.mkdir(parents=True, exist_ok=True)
ENV_FILE = CONFIG_DIR / ".env"

# Set restricted permissions
if ENV_FILE.exists():
    os.chmod(ENV_FILE, 0o600)  # Owner read/write only
```

## Tool Implementation

### Tool Definition Best Practices

1. **Clear Descriptions**: Describe what the tool does and when to use it
2. **Comprehensive Schemas**: Include all parameters with types, descriptions, and constraints
3. **Required vs Optional**: Clearly mark required parameters
4. **Default Values**: Provide sensible defaults where appropriate

**Example:**
```python
Tool(
    name="list_domains",
    description=(
        "List all domains in the account. Returns domain names, "
        "expiration dates, auto-renewal status, and registrant information."
    ),
    inputSchema={
        "type": "object",
        "properties": {
            "account_id": {
                "type": "string",
                "description": "Account ID (optional, uses default if not provided)"
            },
            "filter": {
                "type": "string",
                "description": "Filter domains by status (optional)",
                "enum": ["active", "expired", "all"],
                "default": "all"
            }
        }
    }
)
```

### Tool Response Format

**Standard Response Structure:**
```python
{
    "success": True,  # Boolean indicating success
    "data": {...},    # Result data
    "count": 5,       # Optional: Count of items
    "message": "..."  # Optional: Human-readable message
}
```

**Error Response:**
```python
{
    "error": "Error message",
    "code": "ERROR_CODE",  # Optional: Error code
    "details": {...}       # Optional: Additional error details
}
```

### Returning Data

**Single Tool Result:**
```python
result = {
    "success": True,
    "data": {...}
}
return [TextContent(type="text", text=json.dumps(result, indent=2))]
```

**Multiple Results:**
```python
results = {
    "success": True,
    "count": len(items),
    "items": [...]
}
return [TextContent(type="text", text=json.dumps(results, indent=2))]
```

## Error Handling

### Error Response Pattern

```python
def handle_error(error: Exception, context: str = "") -> List[TextContent]:
    """Handle errors and return structured error response."""
    error_response = {
        "error": str(error),
        "context": context,
        "type": type(error).__name__
    }
    
    # Log error (to stderr, not stdout)
    import sys
    print(f"Error in {context}: {error}", file=sys.stderr)
    
    return [TextContent(type="text", text=json.dumps(error_response, indent=2))]
```

### Common Error Types

1. **Authentication Errors**: Missing or invalid credentials
2. **API Errors**: External API failures (include status codes)
3. **Validation Errors**: Invalid parameters
4. **Network Errors**: Connection timeouts, DNS failures

**Example:**
```python
try:
    response = requests.get(url, headers=headers, timeout=10)
    response.raise_for_status()
    return response.json()
except requests.exceptions.HTTPError as e:
    error_response = {
        "error": f"API request failed: {e.response.status_code}",
        "status_code": e.response.status_code,
        "message": e.response.text
    }
    return [TextContent(type="text", text=json.dumps(error_response, indent=2))]
except requests.exceptions.Timeout:
    error_response = {
        "error": "Request timed out",
        "type": "timeout"
    }
    return [TextContent(type="text", text=json.dumps(error_response, indent=2))]
```

## Documentation Requirements

### README.md Structure

**Required Sections:**

1. **Title & Description**
   - Server name and purpose
   - Credits/attributions if based on other projects

2. **Features**
   - List of capabilities
   - Key functionality

3. **Installation**
   - Dependencies
   - Setup commands

4. **Configuration**
   - Authentication methods
   - Environment variables
   - Config file locations

5. **Cursor Configuration**
   - Complete JSON configuration example
   - Path resolution notes

6. **Claude Desktop Configuration**
   - Complete JSON configuration example
   - Platform-specific paths

7. **Available Tools**
   - For each tool:
     - Description
     - Parameters (with types and descriptions)
     - Example request JSON
     - Example response JSON
     - Notes/limitations

8. **Error Handling**
   - Common errors
   - Error response format
   - Troubleshooting tips

9. **Security Notes**
   - Credential handling
   - Security considerations
   - Best practices

10. **Troubleshooting**
    - Common issues and solutions
    - Debugging tips

11. **Notes**
    - Implementation details
    - Limitations
    - Known issues

12. **License**
    - License type

13. **Support**
    - GitHub issues link
    - Contact information

### Configuration Examples

**Cursor Configuration:**
```json
{
  "mcpServers": {
    "server-name": {
      "command": "python3",
      "args": [
        "/path/to/server_name_mcp_server.py"
      ],
      "env": {
        "SERVICE_API_TOKEN": "your-token-here"
      }
    }
  }
}
```

**Claude Desktop Configuration:**
```json
{
  "mcpServers": {
    "server-name": {
      "command": "python3",
      "args": [
        "/path/to/server_name_mcp_server.py"
      ],
      "env": {
        "SERVICE_API_TOKEN": "your-token-here"
      }
    }
  }
}
```

**Note:** Always include a note about replacing `/path/to/` with actual paths.

## Testing & Validation

### Testing Requirements

All MCP servers MUST have comprehensive test coverage to ensure reliability and maintainability.

**Minimum Coverage Thresholds:**
- Lines: ≥90%
- Branches: ≥85%
- Functions: 100%

**Required Test Categories:**
1. **Unit Tests**: Test individual components in isolation (no external dependencies)
2. **Integration Tests**: Test interactions with real APIs/services
3. **Premium/Limitation Tests**: Document and test plan-specific feature limitations

### Test Structure Standards

**Directory Structure:**
```
server-name/
├── tests/
│   ├── __init__.py
│   ├── conftest.py                # pytest fixtures and configuration
│   ├── test_tool1.py              # Tool-specific tests
│   ├── test_tool2.py
│   ├── test_error_handling.py     # Error case tests
│   ├── test_plan_limitations.py   # Premium feature tests
│   ├── test_data_permutations.py  # Comprehensive data tests
│   └── fixtures/
│       ├── __init__.py
│       ├── test_data.py           # Test data generators
│       └── test_config.py         # Test configuration
├── pytest.ini                     # pytest configuration
├── requirements-test.txt          # Test dependencies
└── PLAN_LIMITATIONS.md            # Documented limitations
```

**Naming Conventions:**
- Test files: `test_*.py`
- Test functions: `test_*`
- Test classes: `Test*`
- Fixtures: Descriptive names (e.g., `mock_api_client`, `test_config`)

### pytest Configuration

**Required `pytest.ini`:**
```ini
[pytest]
python_files = test_*.py
python_classes = Test*
python_functions = test_*

markers =
    unit: Unit tests (no external dependencies)
    integration: Integration tests (require external services)
    premium: Premium feature tests (may fail based on plan)
    slow: Slow-running tests

addopts =
    --verbose
    --strict-markers
    --cov=.
    --cov-report=term-missing
    --cov-report=html
    --cov-fail-under=90

testpaths = tests
asyncio_mode = auto
```

**Required `requirements-test.txt`:**
```
pytest>=7.0.0
pytest-asyncio>=0.21.0
pytest-cov>=4.0.0
pytest-mock>=3.10.0
pytest-timeout>=2.1.0
```

### Test Coverage Requirements

**All Tools Must Be Tested:**
- ✓ Basic functionality with minimal parameters
- ✓ Full functionality with all parameters
- ✓ All parameter combinations and permutations
- ✓ Edge cases (empty values, max lengths, special characters)
- ✓ Error conditions (invalid inputs, API failures, timeouts)

**All Data Permutations Must Be Tested:**
- ✓ Various property combinations
- ✓ Boundary conditions (min/max values)
- ✓ Special characters and Unicode
- ✓ Round-trip data integrity (import → export → verify)

**All Error Cases Must Be Tested:**
- ✓ Authentication failures
- ✓ Invalid parameters
- ✓ API errors (4xx, 5xx responses)
- ✓ Network timeouts
- ✓ Rate limiting
- ✓ Resource not found

### Test Workspace Requirements

**For Integration Tests:**
- **MUST** use dedicated test workspaces/environments
- **NEVER** use production data or workspaces
- **MUST** clean up test data after tests
- **MUST** isolate tests (no dependencies between tests)
- **SHOULD** use test environment variables (e.g., `TEST_API_TOKEN`)

**Example Test Configuration:**
```python
# tests/conftest.py
@pytest.fixture
def test_workspace_config():
    """Get test workspace configuration from environment."""
    return {
        "api_token": os.getenv("TEST_API_TOKEN"),
        "workspace_id": os.getenv("TEST_WORKSPACE_ID"),
    }

@pytest.fixture
def skip_if_no_test_workspace():
    """Skip tests if test workspace not configured."""
    if not os.getenv("TEST_API_TOKEN"):
        pytest.skip("Test workspace not configured")
```

### Premium/Plan Limitation Testing

**Requirements:**
1. **Document all plan limitations** in `PLAN_LIMITATIONS.md`
2. **Test premium feature failures** and verify graceful handling
3. **Mark premium tests** with `@pytest.mark.premium`
4. **Document error codes** and messages for each limitation

**Example `PLAN_LIMITATIONS.md` Structure:**
```markdown
# Service Plan Limitations

## Known Limitations

### Feature X (Premium Only)
- **Error**: 402 Payment Required
- **Message**: "Feature requires premium plan"
- **Handling**: Falls back to basic functionality
- **Testing**: See `test_plan_limitations.py`

## Feature Availability Matrix
| Feature | Free | Premium | Enterprise |
|---------|------|---------|------------|
| Basic API | ✓ | ✓ | ✓ |
| Advanced | ✗ | ✓ | ✓ |
```

**Example Premium Tests:**
```python
@pytest.mark.premium
@pytest.mark.unit
def test_premium_feature_graceful_failure(mock_client):
    """Test that premium features fail gracefully."""
    # Mock 402 error
    mock_client.side_effect = HTTPError(402, "Premium required")
    
    # Should handle gracefully without crashing
    result = call_tool("premium_feature", {})
    assert "error" in result
    assert "premium" in result["error"].lower()
```

### Data Integrity Testing

**Round-Trip Tests:**
```python
@pytest.mark.integration
async def test_round_trip_data_integrity():
    """Test that data survives import → export → import."""
    # Step 1: Import data
    imported = await import_data(source)
    
    # Step 2: Export data
    exported = await export_data(imported)
    
    # Step 3: Re-import
    reimported = await import_data(exported)
    
    # Verify all properties preserved
    assert imported == reimported
```

### Manual Testing

**Server Startup Test:**
```bash
python server_name_mcp_server.py
```

**Tool Listing Test:**
```json
{"jsonrpc": "2.0", "id": 1, "method": "tools/list"}
```

**Tool Call Test:**
```json
{
  "jsonrpc": "2.0",
  "id": 2,
  "method": "tools/call",
  "params": {
    "name": "tool_name",
    "arguments": {"param": "value"}
  }
}
```

### Validation Checklist

**Pre-Deployment:**
- [ ] All tests pass (unit + integration)
- [ ] Test coverage ≥90%
- [ ] Premium limitations documented
- [ ] No linter errors
- [ ] Server starts without errors
- [ ] Tools list correctly
- [ ] Tool calls return valid JSON
- [ ] Error handling works correctly
- [ ] Authentication methods work (env var, config file, 1Password)
- [ ] Documentation is complete
- [ ] Configuration examples are correct
- [ ] Paths are portable (not hardcoded)
- [ ] Test workspace properly configured
- [ ] Test cleanup working correctly

**Post-Deployment:**
- [ ] Integration tests pass in production-like environment
- [ ] Premium features documented and tested
- [ ] Error handling verified with real services
- [ ] Performance acceptable under load

### CI/CD Integration

**Recommended GitHub Actions Workflow:**
```yaml
name: Test

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.11'
      
      - name: Install dependencies
        run: |
          pip install -r requirements.txt
          pip install -r requirements-test.txt
      
      - name: Run unit tests
        run: pytest -m unit
      
      - name: Run integration tests
        if: github.event_name == 'push'
        env:
          TEST_API_TOKEN: ${{ secrets.TEST_API_TOKEN }}
        run: pytest -m integration
      
      - name: Upload coverage
        uses: codecov/codecov-action@v3
```

### Examples

**Reference Implementations:**
- **Asana MCP** (`execution/mcp-servers/asana/tests/`): Comprehensive test suite with all categories
- **Google Calendar MCP** (`execution/mcp-servers/google-calendar/src/tests/`): TypeScript testing patterns
- **Instagram MCP** (`execution/mcp-servers/instagram/tests/`): Python test structure

## Deployment & Distribution

### Git Submodule Setup

1. **Create Repository:**
   ```bash
   mkdir mcp-server-name
   cd mcp-server-name
   git init
   ```

2. **Add Files:**
   ```bash
   git add .
   git commit -m "Initial commit"
   ```

3. **Add Remote:**
   ```bash
   git remote add origin https://github.com/username/mcp-server-name.git
   git push -u origin main
   ```

4. **Add as Submodule:**
   ```bash
   cd parent-repo
   git submodule add https://github.com/username/mcp-server-name.git execution/mcp-servers/name
   ```

### Version Management

- Use semantic versioning (MAJOR.MINOR.PATCH)
- Tag releases in submodule repository
- Update parent repo submodule reference when needed

### Portability Requirements

**MUST:**
- Work standalone (no hard dependencies on parent repo)
- Use environment variables or config directories for paths
- Support multiple authentication methods
- Include all dependencies in `requirements.txt` or `package.json`

**SHOULD:**
- Support 1Password integration (optional, for backward compatibility)
- Auto-detect parent repo structure (optional, for convenience)
- Fall back to config directory if parent structure not found

**MUST NOT:**
- Hardcode repository paths
- Require specific directory structure
- Depend on parent repo scripts (except optional 1Password integration)

## Examples from Existing Servers

### Python Server: DNSimple

**Location:** `execution/mcp-servers/dnsimple/`

**Key Patterns:**
- Environment variable → config file → 1Password authentication
- Simple tool definitions with comprehensive schemas
- Structured error responses
- Comprehensive README with examples

**Reference:** `execution/mcp-servers/dnsimple/dnsimple_mcp_server.py`

### Python Server: Parquet

**Location:** `truth/mcp-servers/parquet/`

**Key Patterns:**
- Complex tool implementations (filtering, aggregation, semantic search)
- Data directory auto-detection with fallback
- Audit logging and rollback capabilities
- Extensive documentation

**Reference:** `truth/mcp-servers/parquet/parquet_mcp_server.py`

### TypeScript Server: Google Calendar

**Location:** `execution/mcp-servers/google-calendar/`

**Key Patterns:**
- OAuth 2.0 authentication
- Multi-account support
- Complex async operations
- TypeScript type safety
- Comprehensive test suite

**Reference:** `execution/mcp-servers/google-calendar/src/index.ts`

### Python Server: Instagram

**Location:** `execution/mcp-servers/instagram/`

**Key Patterns:**
- Structured logging (structlog)
- Class-based server implementation
- Separate client and models modules
- Comprehensive error handling

**Reference:** `execution/mcp-servers/instagram/src/instagram_mcp_server.py`

## Quick Reference

### Python Server Template

```python
#!/usr/bin/env python3
"""
MCP Server for [Service Name]
"""

import json
import os
from pathlib import Path
from typing import Any, Dict, List, Optional

from mcp.server import Server
from mcp.server.stdio import stdio_server
from mcp.types import Tool, TextContent

app = Server("server-name")

@app.list_tools()
async def list_tools() -> List[Tool]:
    return [Tool(...)]

@app.call_tool()
async def call_tool(name: str, arguments: Any) -> List[TextContent]:
    if name == "tool_name":
        result = {"success": True, "data": "..."}
        return [TextContent(type="text", text=json.dumps(result, indent=2))]
    raise ValueError(f"Unknown tool: {name}")

if __name__ == "__main__":
    stdio_server(app)
```

### Authentication Template

```python
def get_credential() -> Optional[str]:
    # 1. Environment variable
    credential = os.getenv("SERVICE_API_TOKEN")
    if credential:
        return credential
    
    # 2. Config file
    config_file = Path.home() / ".config" / "server-name-mcp" / ".env"
    if config_file.exists():
        # Parse .env file
        ...
    
    # 3. 1Password (optional)
    if HAS_CREDENTIALS_MODULE:
        credential = get_credential_from_1password()
        if credential:
            return credential
    
    raise ValueError("Credential not found")
```

## Additional Resources

- [MCP Specification](https://modelcontextprotocol.io/specification)
- [MCP Python SDK](https://github.com/modelcontextprotocol/python-sdk)
- [MCP TypeScript SDK](https://github.com/modelcontextprotocol/typescript-sdk)
- Existing server READMEs for detailed examples

## Revision History

- **2025-12-26**: Initial guide created based on analysis of existing servers








