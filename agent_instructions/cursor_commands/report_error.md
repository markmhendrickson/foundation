# Report Error Command

## Purpose

Enable agents to report errors for automated resolution by Cursor Cloud Agent. This command detects, classifies, and documents errors in a structured format for systematic resolution.

Supports **cross-repo reporting**: Report errors to sibling repositories (repos sharing the same parent directory) by passing the target repo name.

## Command Usage

```bash
/report_error [target-repo-name] [--wait] [--timeout SECONDS] [--poll-interval SECONDS]
```

**Parameters:**
- `target-repo-name` (optional): Name of sibling repository to report error to
  - Must be a sibling repository (shares same parent directory)
  - Example: If current repo is `/Users/user/Projects/personal`, target `neotoma` resolves to `/Users/user/Projects/neotoma`
  - If omitted: Reports error to current repository (local reporting)
- `--wait` (optional): Enable wait-for-resolution mode (monitor error status until resolved)
- `--timeout SECONDS` (optional): Maximum time to wait for resolution (default: 300 seconds / 5 minutes)
- `--poll-interval SECONDS` (optional): How often to check error status (default: 5 seconds)

**Examples:**
```bash
# Local reporting (current repo)
/report_error

# Cross-repo reporting to sibling repo
/report_error neotoma
/report_error personal-project

# Report error and wait for resolution
/report_error --wait

# Report error with custom timeout (10 minutes)
/report_error --wait --timeout 600

# Report error with custom poll interval (check every 2 seconds)
/report_error --wait --poll-interval 2

# Cross-repo reporting with wait mode
/report_error neotoma --wait --timeout 600
```

## When to Use

Use this command when you encounter:
- Build errors (TypeScript compilation, module resolution)
- Runtime errors (MCP server errors, API failures, database errors)
- Test failures
- Dependency issues (missing modules, version conflicts)
- Configuration errors (missing env vars, invalid config)

## Workflow

### 1. Target Repository Resolution

1. **Get Current Repository Path:**
   ```bash
   git rev-parse --show-toplevel
   ```
   Store as `current_repo_path`

2. **Resolve Target Repository Path:**
   - If `target-repo-name` parameter provided:
     - Get parent directory: `dirname(current_repo_path)`
     - Construct target path: `parent_dir/target-repo-name`
     - Example: Current repo at `/Users/user/Projects/personal`, target `neotoma` → `/Users/user/Projects/neotoma`
   - If parameter omitted:
     - Use `current_repo_path` (local reporting)

3. **Sanitize Repository Name** (if provided):
   - Ensure repo name doesn't contain path traversal characters (`..`, `/`, `\`)
   - Validate repo name is a valid directory name (alphanumeric, hyphens, underscores, dots)
   - Abort if repo name contains invalid characters

4. **Validate Target Repository:**
   - Verify target path exists and is a directory
   - Verify target contains `.git` directory (is a git repository)
   - Verify write permissions to target directory
   - If validation fails: abort with clear error message

### 2. Error Detection & Collection

Extract the following from context:
- Error message and stack trace
- Affected files/modules from error paths
- Agent context (agent_id, task being performed)
- Environment details (Node version, OS, etc.)

### 3. Error Classification

Classify error into one of these categories:
- **build**: TypeScript compilation, module resolution, missing dependencies
- **runtime**: MCP server errors, API failures, database errors
- **test**: Test failures, assertion errors
- **dependency**: Missing modules, version conflicts
- **configuration**: Missing env vars, invalid config

### 4. Severity Assessment

Assign severity based on impact:
- **critical**: Server crashes, data loss, security issues
- **high**: Feature breakage, blocking errors
- **medium**: Non-blocking errors, warnings
- **low**: Cosmetic issues, deprecation warnings

### 5. Generate Error Report

Create a structured error report with:
- Error ID (UUIDv7 or timestamp-based)
- Timestamp (ISO 8601)
- Category and severity
- Sanitized error message (no PII)
- Truncated stack trace (max 5000 chars)
- Affected files and modules
- Agent context
- Environment details
- **Repository metadata** (source_repo, target_repo)
- Resolution status (initially "pending")

### 6. Store Error Report in Target Repository

1. **Ensure Target Directory Structure:**
   - Create `target_repo/.cursor/error_reports/` if missing
   - Create `target_repo/.cursor/error_reports/resolved/` if missing

2. **Write Error Report Files:**
   - Save JSON: `target_repo/.cursor/error_reports/error_[timestamp]_[category].json`
   - Save Markdown: `target_repo/.cursor/error_reports/error_[timestamp]_[category].md`

3. **Update Pending Queue:**
   - Append to `target_repo/.cursor/error_reports/pending.json`
   - Include priority/severity for processing order

### 7. Output Summary

Present to user:
- Error ID and category
- Severity level
- Target repository path
- Location of report files
- Queue status

## Error Report Schema

```json
{
  "error_id": "uuid-v7",
  "timestamp": "ISO-8601",
  "category": "build|runtime|test|dependency|configuration",
  "severity": "critical|high|medium|low",
  "error_message": "sanitized error message",
  "stack_trace": "truncated stack trace",
  "affected_files": ["path/to/file1.ts", "path/to/file2.ts"],
  "affected_modules": ["module_name"],
  "agent_context": {
    "agent_id": "cursor-agent",
    "task": "description of task",
    "command": "command_name if applicable"
  },
  "repositories": {
    "source_repo": {
      "path": "/absolute/path/to/source/repo",
      "name": "repo-name",
      "remote_url": "git@github.com:user/repo.git"
    },
    "target_repo": {
      "path": "/absolute/path/to/target/repo",
      "name": "target-repo-name",
      "remote_url": "git@github.com:user/target.git"
    }
  },
  "environment": {
    "node_version": "v20.x.x",
    "os": "darwin|linux|windows",
    "neotoma_env": "development|production"
  },
  "resolution_status": "pending|in_progress|resolved|failed",
  "resolution_notes": ""
}
```

## Path Sanitization Rules

**Repository Name Validation:**
- Ensure repo name doesn't contain path traversal: `..`, `/`, `\`
- Allow only valid directory name characters: alphanumeric, hyphens, underscores, dots
- Reject repo names that don't match pattern: `^[a-zA-Z0-9._-]+$`
- Example valid names: `neotoma`, `personal-project`, `my_repo`, `repo.2`
- Example invalid names: `../other`, `repo/subdir`, `../../secret`

**Path Construction:**
```javascript
// Get current repo root
const currentRepoPath = execSync('git rev-parse --show-toplevel').toString().trim();

// If target repo name provided
if (targetRepoName) {
  // Sanitize repo name first
  if (!/^[a-zA-Z0-9._-]+$/.test(targetRepoName)) {
    throw new Error(`Invalid repo name: ${targetRepoName}. Only alphanumeric, hyphens, underscores, and dots allowed.`);
  }
  
  // Get parent directory
  const parentDir = path.dirname(currentRepoPath);
  
  // Construct target repo path
  const targetPath = path.join(parentDir, targetRepoName);
  
  return targetPath;
} else {
  // Use current repo
  return currentRepoPath;
}
```

## Target Repository Validation

Before writing error report, validate target repository:

1. **Path Exists:**
   ```javascript
   if (!fs.existsSync(targetPath)) {
     throw new Error(`Target repository not found: ${targetPath}`);
   }
   ```

2. **Is Directory:**
   ```javascript
   if (!fs.statSync(targetPath).isDirectory()) {
     throw new Error(`Target path is not a directory: ${targetPath}`);
   }
   ```

3. **Is Git Repository:**
   ```javascript
   const gitPath = path.join(targetPath, '.git');
   if (!fs.existsSync(gitPath)) {
     throw new Error(`Target path is not a git repository: ${targetPath}`);
   }
   ```

4. **Is Writable:**
   ```javascript
   try {
     fs.accessSync(targetPath, fs.constants.W_OK);
   } catch {
     throw new Error(`No write permission for target repository: ${targetPath}`);
   }
   ```

If any validation fails, abort with clear error message and do not write error report.

## Error Message Sanitization Rules

Apply these rules when generating reports:
1. Remove PII from error messages
2. Truncate stack traces to max 5000 characters
3. Replace sensitive paths with placeholders
4. Redact API keys, tokens, credentials
5. Remove user-specific data from file paths

## Error Handling & User Feedback

**Validation Failures:**

1. **Invalid Repo Name:**
   ```
   Error: Invalid repo name: ../other. Only alphanumeric, hyphens, underscores, and dots allowed.
   ```

2. **Target Repo Not Found:**
   ```
   Error: Target repository not found: /Users/user/Projects/non-existent-repo
   
   Available sibling repositories:
   - neotoma
   - personal-project
   - another-repo
   ```

3. **Not a Git Repository:**
   ```
   Error: Target path is not a git repository: /Users/user/Projects/some-dir
   
   Target must be a git repository (contains .git directory).
   ```

4. **No Write Permission:**
   ```
   Error: No write permission for target repository: /Users/user/Projects/neotoma
   
   Check file permissions and try again.
   ```

**Success Feedback:**
```
Error report created successfully.

Error ID: 01JQZ8X9K2M3N4P5Q6R7S8T9U0
Category: build
Severity: high
Target: /Users/user/Projects/neotoma

Report saved to:
- /Users/user/Projects/neotoma/.cursor/error_reports/error_20250131_143022_build.json
- /Users/user/Projects/neotoma/.cursor/error_reports/error_20250131_143022_build.md

Added to pending queue for resolution.
```

## Example Usage

### Scenario 1: Local Error Reporting

```
Agent: I encountered a TypeScript compilation error while building the project.

Error: Cannot find module '../db'
  at Object.<anonymous> (/Users/user/Projects/neotoma/src/services/raw_storage.ts:1:1)
  ...

Command: /report_error
```

Agent will:
1. Use current repository as target (local reporting)
2. Classify as "build" error with "high" severity
3. Extract affected files: `src/services/raw_storage.ts`, etc.
4. Generate error report with sanitized paths
5. Save to current repo's `.cursor/error_reports/error_20250131_143022_build.json`
6. Add to pending queue
7. Output summary with error ID

### Scenario 2: Cross-Repo Error Reporting

```
Agent: Working in personal-project repo, encountered error that should be tracked in neotoma repo.

Error: MCP error -32603: Failed to upload to storage: Bucket not found

Command: /report_error neotoma
```

Agent will:
1. Resolve target repo: `/Users/user/Projects/neotoma` (sibling of personal-project)
2. Validate target repo exists and is writable
3. Classify as "runtime" error with "high" severity
4. Generate error report with repository metadata (source: personal-project, target: neotoma)
5. Save to neotoma repo's `.cursor/error_reports/`
6. Add to neotoma's pending queue
7. Output summary showing target repo path

### Scenario 3: Invalid Target Repo

```
Command: /report_error ../secret-repo
```

Agent will:
1. Detect invalid repo name (contains `..`)
2. Abort with error: "Invalid repo name: ../secret-repo. Only alphanumeric, hyphens, underscores, and dots allowed."
3. Do not create error report

## Cross-Repo File Writing Logic

**Directory Creation:**
```javascript
const errorReportsDir = path.join(targetRepoPath, '.cursor', 'error_reports');
const resolvedDir = path.join(errorReportsDir, 'resolved');

// Create directories if they don't exist
fs.mkdirSync(errorReportsDir, { recursive: true });
fs.mkdirSync(resolvedDir, { recursive: true });
```

**File Naming:**
```javascript
const timestamp = new Date().toISOString().replace(/[:.]/g, '').slice(0, 15);
const jsonFilename = `error_${timestamp}_${category}.json`;
const mdFilename = `error_${timestamp}_${category}.md`;

const jsonPath = path.join(errorReportsDir, jsonFilename);
const mdPath = path.join(errorReportsDir, mdFilename);
```

**Write Error Reports:**
```javascript
// Write JSON report
fs.writeFileSync(jsonPath, JSON.stringify(errorReport, null, 2), 'utf8');

// Write Markdown summary
fs.writeFileSync(mdPath, markdownSummary, 'utf8');

// Update pending queue
const pendingPath = path.join(errorReportsDir, 'pending.json');
let pending = [];
if (fs.existsSync(pendingPath)) {
  pending = JSON.parse(fs.readFileSync(pendingPath, 'utf8'));
}
pending.push({
  error_id: errorReport.error_id,
  timestamp: errorReport.timestamp,
  category: errorReport.category,
  severity: errorReport.severity,
  file_path: jsonPath
});
fs.writeFileSync(pendingPath, JSON.stringify(pending, null, 2), 'utf8');
```

## File Structure

Error reports are stored in the **target repository's** `.cursor/error_reports/` directory:

```
target_repo/.cursor/
  error_reports/
    pending.json                           # Queue of errors awaiting resolution
    error_20250131_143022_build.json      # Individual error reports (JSON)
    error_20250131_143022_build.md        # Human-readable summaries (Markdown)
    resolved/                              # Archived resolved errors
      error_20250131_143022_build.json
      error_20250131_143022_build.md
```

## Integration with Cursor Cloud Agent

The Cursor Cloud Agent will:
1. Monitor `.cursor/error_reports/pending.json`
2. Process errors in priority order (critical → low)
3. Update `resolution_status` when working on error
4. Move resolved errors to `.cursor/error_reports/resolved/`
5. Add resolution notes to error report

## Integration with Existing Commands

### With `fix_feature_bug`

- Errors classified as bugs can trigger the `fix_feature_bug` command
- Agent can auto-classify certain error types as bugs
- Bug fix workflow will update error report resolution status

### With `analyze`

- Can analyze error patterns across multiple reports
- Identify recurring issues
- Generate error trend reports

## Configuration

Error reporting behavior can be configured in `foundation-config.yaml`:

```yaml
development:
  error_reporting:
    enabled: true
    auto_detect: true
    auto_classify_bugs: true
    severity_threshold: "medium"
    max_stack_trace_length: 5000
    retention_days: 30
    output_directory: ".cursor/error_reports"
```

## Error Detection Patterns

Auto-detect errors matching these patterns:
- MCP error responses: `MCP error -32603`, `UNKNOWN_CAPABILITY`, etc.
- Build errors: TypeScript compilation failures, `tsc` errors
- Module resolution: `Cannot find module`, `Module not found`
- Runtime exceptions: Stack traces with `Error:`, `Exception:`
- Test failures: `Test failed`, `AssertionError`

## Implementation Checklist

When reporting an error:
- [ ] Parse target-repo-name parameter (if provided)
- [ ] Sanitize repo name (validate pattern)
- [ ] Resolve target repository path (parent_dir + repo_name)
- [ ] Validate target repository (exists, is git repo, writable)
- [ ] Extract error message and stack trace
- [ ] Classify error category
- [ ] Assign severity level
- [ ] Sanitize sensitive data
- [ ] Collect repository metadata (source and target)
- [ ] Generate unique error ID
- [ ] Create target repo directory structure if missing
- [ ] Create JSON report file in target repo
- [ ] Create Markdown summary file in target repo
- [ ] Update pending queue in target repo
- [ ] Output summary to user with target repo path

## Example Error Report Files

### JSON Report (`error_20250131_143022_build.json`)

**Example: Local Reporting**
```json
{
  "error_id": "01JQZ8X9K2M3N4P5Q6R7S8T9U0",
  "timestamp": "2025-01-31T14:30:22Z",
  "category": "build",
  "severity": "high",
  "error_message": "Cannot find module '../db'",
  "stack_trace": "Error: Cannot find module '../db'\n  at Object.<anonymous> (src/services/raw_storage.ts:1:1)\n  at Module._compile (node:internal/modules/cjs/loader:1376:14)\n  ...",
  "affected_files": [
    "src/services/raw_storage.ts",
    "src/services/interpretation.ts",
    "src/services/entity_queries.ts"
  ],
  "affected_modules": ["db"],
  "agent_context": {
    "agent_id": "cursor-agent",
    "task": "Transfer contacts from Parquet to Neotoma",
    "command": null
  },
  "repositories": {
    "source_repo": {
      "path": "/Users/user/Projects/neotoma",
      "name": "neotoma",
      "remote_url": "git@github.com:user/neotoma.git"
    },
    "target_repo": {
      "path": "/Users/user/Projects/neotoma",
      "name": "neotoma",
      "remote_url": "git@github.com:user/neotoma.git"
    }
  },
  "environment": {
    "node_version": "v20.11.0",
    "os": "darwin",
    "neotoma_env": "development"
  },
  "resolution_status": "pending",
  "resolution_notes": ""
}
```

**Example: Cross-Repo Reporting**
```json
{
  "error_id": "01JQZ8X9K2M3N4P5Q6R7S8T9U1",
  "timestamp": "2025-01-31T14:35:10Z",
  "category": "runtime",
  "severity": "high",
  "error_message": "MCP error -32603: Failed to upload to storage: Bucket not found",
  "stack_trace": "...",
  "affected_files": ["src/actions.ts"],
  "affected_modules": ["mcp_neotoma"],
  "agent_context": {
    "agent_id": "cursor-agent",
    "task": "Ingest structured contact data",
    "command": "ingest_structured"
  },
  "repositories": {
    "source_repo": {
      "path": "/Users/user/Projects/personal-project",
      "name": "personal-project",
      "remote_url": "git@github.com:user/personal-project.git"
    },
    "target_repo": {
      "path": "/Users/user/Projects/neotoma",
      "name": "neotoma",
      "remote_url": "git@github.com:user/neotoma.git"
    }
  },
  "environment": {
    "node_version": "v20.11.0",
    "os": "darwin",
    "neotoma_env": "development"
  },
  "resolution_status": "pending",
  "resolution_notes": ""
}
```

### Markdown Summary (`error_20250131_143022_build.md`)

**Example: Cross-Repo Reporting**
```markdown
# Error Report: Runtime Error

**Error ID:** `01JQZ8X9K2M3N4P5Q6R7S8T9U1`  
**Timestamp:** 2025-01-31T14:35:10Z  
**Category:** runtime  
**Severity:** high  
**Status:** pending

## Error Message

MCP error -32603: Failed to upload to storage: Bucket not found

## Source Repository

- **Name:** personal-project
- **Path:** /Users/user/Projects/personal-project
- **Remote:** git@github.com:user/personal-project.git

## Target Repository

- **Name:** neotoma
- **Path:** /Users/user/Projects/neotoma
- **Remote:** git@github.com:user/neotoma.git

## Affected Files

- `src/actions.ts`

## Affected Modules

- mcp_neotoma

## Stack Trace

```
...
```

## Context

Agent was ingesting structured contact data when this runtime error occurred.

## Environment

- Node: v20.11.0
- OS: darwin
- Environment: development

## Resolution

Awaiting resolution by Cursor Cloud Agent.
```

## Best Practices

1. **Always sanitize**: Remove PII and sensitive data before storing
2. **Be specific**: Include relevant context about the task being performed
3. **Truncate wisely**: Keep stack traces informative but not excessive
4. **Update status**: Mark errors as resolved when fixed
5. **Archive old errors**: Move resolved errors to archive directory
6. **Review patterns**: Periodically analyze error reports for trends
7. **Use cross-repo reporting**: Report errors to appropriate repo (e.g., foundation errors to neotoma)
8. **Validate target repo**: Always validate target exists and is writable before attempting to write

## Testing Scenarios

### Test 1: Local Reporting (No Target)
```bash
/report_error
```
Expected: Error report written to current repo's `.cursor/error_reports/`

### Test 2: Valid Sibling Repo
```bash
/report_error neotoma
```
Expected: Error report written to `../neotoma/.cursor/error_reports/`

### Test 3: Non-Existent Sibling Repo
```bash
/report_error non-existent-repo
```
Expected: Error message: "Target repository not found: /Users/user/Projects/non-existent-repo"

### Test 4: Invalid Repo Name (Path Traversal)
```bash
/report_error ../other-dir
```
Expected: Error message: "Invalid repo name: ../other-dir. Only alphanumeric, hyphens, underscores, and dots allowed."

### Test 5: Valid Name but Not Git Repo
```bash
/report_error some-directory
```
Expected: Error message: "Target path is not a git repository: /Users/user/Projects/some-directory"

### Test 6: Cross-Repo with Directory Creation
```bash
/report_error neotoma
```
(Where neotoma repo exists but `.cursor/error_reports/` doesn't exist yet)
Expected: Directories created automatically, error report written successfully

## Wait-for-Resolution Mode

When using the `--wait` flag, the agent will monitor the error report status and wait for resolution before continuing.

### Workflow with --wait

1. **Report Error:**
   - Agent executes `/report_error --wait`
   - Error report created with `resolution_status: "pending"`
   - Error ID returned to agent

2. **Monitor Resolution:**
   - Agent polls error report file for status changes
   - Checks `resolution_status` field in JSON report
   - Status values: `pending` → `in_progress` → `resolved` | `failed`

3. **Resolution Detection:**
   - **Resolved:** Status changes to `"resolved"`
     - Agent can resume/retry the operation that failed
     - Check `resolution_notes` for details about the fix
   - **Failed:** Status changes to `"failed"`
     - Agent should handle failure case (log, skip, or escalate)
     - Check `resolution_notes` for failure reason

4. **Timeout Handling:**
   - If timeout reached while status is still `pending` or `in_progress`:
     - Agent logs warning and continues (assumes resolution in progress)
     - Agent can check status later or proceed without waiting

5. **Resume/Retry Logic:**
   - After resolution, agent can:
     - **Resume:** Continue from where error occurred
     - **Retry:** Re-execute the operation that failed
     - **Skip:** If error indicates operation should be skipped

### Configuration

Wait mode settings are read from `foundation-config.yaml`:
- `error_reporting.wait_mode.default_timeout` - Default timeout (overridden by `--timeout`)
- `error_reporting.wait_mode.default_poll_interval` - Default poll interval (overridden by `--poll-interval`)
- `error_reporting.wait_mode.max_timeout` - Maximum allowed timeout
- `error_reporting.wait_mode.min_poll_interval` - Minimum allowed poll interval

### Implementation Example

```javascript
// Agent workflow with --wait
try {
  await performOperation();
} catch (error) {
  // Report error and wait for resolution
  const result = await reportError('--wait', '--timeout', '600');
  
  if (result.resolved) {
    // Retry operation after resolution
    console.log(`Retrying operation after error resolution: ${result.errorId}`);
    await performOperation(); // Retry
  } else if (result.failed) {
    // Handle failure case
    console.log(`Error resolution failed: ${result.resolutionNotes}`);
    throw new Error(`Operation failed and could not be resolved: ${result.errorId}`);
  } else if (result.timeout) {
    // Timeout - proceed or skip
    console.log(`Timeout waiting for resolution, skipping operation`);
    // Agent decides whether to skip or continue
  }
}
```

### Status Monitoring

The agent polls the error report JSON file for status changes:

```javascript
async function waitForErrorResolution(errorId, errorReportPath, options = {}) {
  const {
    timeout = 300, // 5 minutes default
    pollInterval = 5, // 5 seconds default
  } = options;

  const startTime = Date.now();
  const timeoutMs = timeout * 1000;

  while (true) {
    // Check timeout
    if (Date.now() - startTime > timeoutMs) {
      throw new Error(`Timeout waiting for error resolution: ${errorId}`);
    }

    // Read error report
    const report = JSON.parse(fs.readFileSync(errorReportPath, 'utf8'));
    const status = report.resolution_status;

    // Check if resolved or failed
    if (status === 'resolved') {
      return {
        status: 'resolved',
        errorId,
        resolutionNotes: report.resolution_notes || '',
        report
      };
    }

    if (status === 'failed') {
      return {
        status: 'failed',
        errorId,
        resolutionNotes: report.resolution_notes || '',
        report
      };
    }

    // Still pending or in_progress, wait and check again
    console.log(`[WAIT] Error ${errorId} status: ${status}, waiting...`);
    await new Promise(resolve => setTimeout(resolve, pollInterval * 1000));
  }
}
```

## Related Documentation

- `.cursor/commands/fix_feature_bug.md` - Bug fix workflow
- `.cursor/commands/analyze.md` - Analysis command
- `.cursor/commands/debug_pending_errors.md` - Debug pending errors workflow
- `foundation-config.yaml` - Configuration file (in repository root)

