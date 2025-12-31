# Debug Pending Errors Command

## Purpose

Check for pending error reports and debug/resolve them. Supports cross-repo error queue checking for sibling repositories.

## Command Usage

```bash
/debug_pending_errors [target-repo-name]
```

**Parameters:**
- `target-repo-name` (optional): Name of sibling repository to check for pending errors
  - Must be a sibling repository (shares same parent directory)
  - If omitted: Checks current repository's pending errors

**Examples:**
```bash
# Check current repo's pending errors
/debug_pending_errors

# Check sibling repo's pending errors
/debug_pending_errors neotoma
/debug_pending_errors personal-project
```

## Workflow

### 1. Target Repository Resolution

1. **Get Current Repository Path:**
   ```bash
   git rev-parse --show-toplevel
   ```
   Store as `current_repo_path`

2. **Resolve Target Repository Path:**
   - If `target-repo-name` provided:
     - Sanitize repo name (same rules as `report_error`: alphanumeric, hyphens, underscores, dots only)
     - Get parent directory: `dirname(current_repo_path)`
     - Construct target path: `parent_dir/target-repo-name`
   - If omitted:
     - Use `current_repo_path` (check current repo)

3. **Validate Target Repository:**
   - Path exists and is a directory
   - Contains `.git` directory (is git repo)
   - Has `.cursor/error_reports/` directory
   - Has `pending.json` file (if not, no pending errors)

### 2. Load Pending Errors

1. **Read Pending Queue:**
   ```javascript
   const pendingPath = path.join(targetRepoPath, '.cursor', 'error_reports', 'pending.json');
   
   if (!fs.existsSync(pendingPath)) {
     console.log(`No pending errors found in ${targetRepoName}.`);
     return;
   }
   
   const pending = JSON.parse(fs.readFileSync(pendingPath, 'utf8'));
   
   if (pending.length === 0) {
     console.log(`No pending errors found in ${targetRepoName}. All clear!`);
     return;
   }
   ```

2. **Sort by Priority:**
   ```javascript
   const severityOrder = { critical: 0, high: 1, medium: 2, low: 3 };
   
   pending.sort((a, b) => {
     // Sort by severity first
     const severityDiff = severityOrder[a.severity] - severityOrder[b.severity];
     if (severityDiff !== 0) return severityDiff;
     
     // Then by timestamp (oldest first)
     return new Date(a.timestamp) - new Date(b.timestamp);
   });
   ```

3. **Display Pending Errors:**
   ```
   Found {count} pending error(s) in {target_repo_name}:
   
   1. [CRITICAL] Build Error (error_20250131_143022_build.json)
      - ID: 01JQZ8X9K2M3N4P5Q6R7S8T9U0
      - Timestamp: 2025-01-31T14:30:22Z
      - Message: Cannot find module '../db'
   
   2. [HIGH] Runtime Error (error_20250131_144510_runtime.json)
      - ID: 01JQZ8X9K2M3N4P5Q6R7S8T9U1
      - Timestamp: 2025-01-31T14:45:10Z
      - Message: MCP error -32603: UNKNOWN_CAPABILITY
   ```

### 3. Select Error to Debug

**Default Behavior: Auto-select highest priority**

1. **Select First Error:**
   - Highest severity (critical > high > medium > low)
   - Oldest timestamp within same severity

2. **Prompt User for Confirmation:**
   ```
   Debugging highest priority error:
   
   Error ID: 01JQZ8X9K2M3N4P5Q6R7S8T9U0
   Category: build
   Severity: critical
   Message: Cannot find module '../db'
   Affected files: src/services/raw_storage.ts
   
   Proceed with debugging? (yes/no/choose-different/list-only)
   
   - yes: Debug this error
   - no: Skip debugging
   - choose-different: Select a different error from the list
   - list-only: Display errors without debugging
   ```

3. **Handle User Response:**
   - `yes`: Proceed to step 4
   - `no`: Exit without debugging
   - `choose-different`: Display numbered list, prompt for selection
   - `list-only`: Display all errors and exit (same as --list-only flag)

### 4. Load Error Details

1. **Read Full Error Report:**
   ```javascript
   const errorJsonPath = pending[selectedIndex].file_path;
   const errorReport = JSON.parse(fs.readFileSync(errorJsonPath, 'utf8'));
   ```

2. **Display Error Details:**
   ```
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   Error Report Details
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   
   Error ID: 01JQZ8X9K2M3N4P5Q6R7S8T9U0
   Category: build
   Severity: critical
   Timestamp: 2025-01-31T14:30:22Z
   
   Error Message:
   Cannot find module '../db'
   
   Stack Trace:
   Error: Cannot find module '../db'
     at Object.<anonymous> (src/services/raw_storage.ts:1:1)
     at Module._compile (node:internal/modules/cjs/loader:1376:14)
     ...
   
   Affected Files:
   - src/services/raw_storage.ts
   - src/services/interpretation.ts
   - src/services/entity_queries.ts
   
   Affected Modules:
   - db
   
   Original Task:
   Transfer contacts from Parquet to Neotoma
   
   Source Repository:
   personal-project (/Users/user/Projects/personal-project)
   
   Target Repository:
   neotoma (/Users/user/Projects/neotoma)
   
   Environment:
   - Node: v20.11.0
   - OS: darwin
   - Environment: development
   
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   ```

### 5. Debug & Fix Error

**Integration with `fix_feature_bug` Command:**

1. **Prepare Context for Bug Fix:**
   - Error message and stack trace
   - Affected files list
   - Affected modules list
   - Original task description

2. **Trigger Bug Fix Workflow:**
   - If `development.error_debugging.integrate_fix_feature_bug: true`:
     - Call `fix_feature_bug` command with error context
     - Pass affected files and error details
   - If integration disabled:
     - Present error details and let user fix manually

3. **Follow Standard Bug Fix Process:**
   - Load relevant documents (specs, subsystems)
   - Classify bug (if error classification configured)
   - Apply correction rules
   - Add regression test
   - Run tests
   - Verify fix resolves the error

4. **Alternative: Manual Debugging Mode:**
   - If user selects manual mode:
     - Display error details
     - Open affected files in editor
     - User investigates and fixes manually
     - User indicates when fix is complete

### 6. Update Resolution Status

**After successful fix:**

1. **Update Error Report:**
   ```javascript
   errorReport.resolution_status = 'resolved';
   errorReport.resolution_notes = 'Fixed by correcting import path in raw_storage.ts';
   errorReport.resolved_at = new Date().toISOString();
   errorReport.resolved_by = 'cursor-agent';
   
   fs.writeFileSync(errorJsonPath, JSON.stringify(errorReport, null, 2), 'utf8');
   ```

2. **Move to Resolved Directory:**
   ```javascript
   const resolvedDir = path.join(targetRepoPath, '.cursor', 'error_reports', 'resolved');
   fs.mkdirSync(resolvedDir, { recursive: true });
   
   const jsonBasename = path.basename(errorJsonPath);
   const mdBasename = jsonBasename.replace('.json', '.md');
   
   const resolvedJsonPath = path.join(resolvedDir, jsonBasename);
   const resolvedMdPath = path.join(resolvedDir, mdBasename);
   
   const errorMdPath = errorJsonPath.replace('.json', '.md');
   
   fs.renameSync(errorJsonPath, resolvedJsonPath);
   if (fs.existsSync(errorMdPath)) {
     fs.renameSync(errorMdPath, resolvedMdPath);
   }
   ```

3. **Remove from Pending Queue:**
   ```javascript
   const pending = JSON.parse(fs.readFileSync(pendingPath, 'utf8'));
   const filtered = pending.filter(e => e.error_id !== errorReport.error_id);
   fs.writeFileSync(pendingPath, JSON.stringify(filtered, null, 2), 'utf8');
   ```

4. **Update Markdown Summary:**
   - Append resolution notes to markdown file
   - Add resolved timestamp
   - Move to resolved directory

**If fix fails:**

1. **Update Status to Failed:**
   ```javascript
   errorReport.resolution_status = 'failed';
   errorReport.resolution_notes = 'Fix attempted but tests still failing. Requires manual investigation.';
   errorReport.failed_at = new Date().toISOString();
   
   fs.writeFileSync(errorJsonPath, JSON.stringify(errorReport, null, 2), 'utf8');
   ```

2. **Keep in Pending Queue:**
   - Do not move to resolved
   - Update error report with failure notes
   - User can retry later

### 7. Output Summary

**On Successful Resolution:**
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Error Resolved Successfully
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Error ID: 01JQZ8X9K2M3N4P5Q6R7S8T9U0
Category: build
Severity: critical

Resolution:
Fixed by correcting import path in raw_storage.ts

Files Changed:
- src/services/raw_storage.ts

Tests Added:
- tests/integration/import_resolution.test.ts

Archived to:
- {target_repo}/.cursor/error_reports/resolved/error_20250131_143022_build.json
- {target_repo}/.cursor/error_reports/resolved/error_20250131_143022_build.md

Remaining pending errors: 1
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**On Failed Resolution:**
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Error Resolution Failed
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Error ID: 01JQZ8X9K2M3N4P5Q6R7S8T9U0
Category: build
Severity: critical

Status: Failed
Notes: Fix attempted but tests still failing. Requires manual investigation.

Error remains in pending queue for retry.

Remaining pending errors: 2
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## Command Flags

### --list-only

Display pending errors without debugging:

```bash
/debug_pending_errors --list-only
/debug_pending_errors neotoma --list-only
```

**Behavior:**
- Display all pending errors
- Do not prompt for debugging
- Exit after displaying list

### --all

Process all pending errors in priority order:

```bash
/debug_pending_errors --all
/debug_pending_errors neotoma --all
```

**Behavior:**
- Process each error in priority order
- Prompt for confirmation before each error (unless --auto also specified)
- Continue until all errors processed or user cancels

### --auto

Skip confirmation prompts:

```bash
/debug_pending_errors --auto
/debug_pending_errors neotoma --auto
```

**Behavior:**
- Auto-debug highest priority error without confirmation
- Useful for automated Cloud Agent processing

### Combined Flags

```bash
/debug_pending_errors neotoma --all --auto
```
Process all pending errors in neotoma repo without prompts

## Error Handling

### Validation Failures

**No Error Reports Directory:**
```
No error reports found in {target_repo}.

Directory .cursor/error_reports/ does not exist.
Use /report_error to create error reports.
```

**Empty Pending Queue:**
```
No pending errors found in {target_repo}.

All clear!
```

**Invalid Target Repo:**
```
Error: Target repository not found: /Users/user/Projects/non-existent-repo

Check repo name and try again.
```

**Invalid Repo Name (Path Traversal):**
```
Error: Invalid repo name: ../secret-repo. Only alphanumeric, hyphens, underscores, and dots allowed.
```

**Permission Error:**
```
Error: No write permission for target repository: /Users/user/Projects/neotoma

Cannot update error reports. Check file permissions.
```

## Configuration

Add to `foundation-config.yaml`:

```yaml
development:
  error_debugging:
    enabled: true
    auto_select_highest_priority: true
    require_confirmation: true  # Prompt before debugging
    integrate_fix_feature_bug: true  # Use fix_feature_bug for resolution
    max_errors_to_display: 10
    auto_archive_resolved: true  # Move resolved errors to archive
```

## Integration Points

### With `report_error` Command

- Reads error reports created by `report_error`
- Processes the pending queue created by `report_error`
- Updates resolution status
- Moves resolved errors to archive

### With `fix_feature_bug` Command

- Automatically triggers `fix_feature_bug` for each error
- Passes error context (message, stack trace, affected files)
- Captures fix results and updates error report
- Updates resolution_status based on fix success/failure

### With Cursor Cloud Agent

- Can be used by Cloud Agent to process error queue automatically
- Updates resolution status as Cloud Agent works
- Provides structured feedback on resolution progress
- Moves resolved errors to archive for audit trail

## Example Usage Scenarios

### Scenario 1: Check & Debug Current Repo

```bash
/debug_pending_errors
```

**Output:**
```
Found 2 pending error(s) in neotoma:

1. [CRITICAL] Build Error (error_20250131_143022_build.json)
   - ID: 01JQZ8X9K2M3N4P5Q6R7S8T9U0
   - Timestamp: 2025-01-31T14:30:22Z
   - Message: Cannot find module '../db'

2. [HIGH] Runtime Error (error_20250131_144510_runtime.json)
   - ID: 01JQZ8X9K2M3N4P5Q6R7S8T9U1
   - Timestamp: 2025-01-31T14:45:10Z
   - Message: MCP error -32603: UNKNOWN_CAPABILITY

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Debugging highest priority error (CRITICAL):

Error ID: 01JQZ8X9K2M3N4P5Q6R7S8T9U0
Category: build
Severity: critical
Message: Cannot find module '../db'

Affected files:
- src/services/raw_storage.ts
- src/services/interpretation.ts
- src/services/entity_queries.ts

Proceed with debugging? (yes/no/choose-different/list-only)
```

### Scenario 2: Check Sibling Repo

```bash
/debug_pending_errors neotoma
```

**Output:**
```
Checking pending errors in: /Users/user/Projects/neotoma

Found 1 pending error(s) in neotoma:

1. [HIGH] Runtime Error (error_20250131_144510_runtime.json)
   - ID: 01JQZ8X9K2M3N4P5Q6R7S8T9U1
   - Timestamp: 2025-01-31T14:45:10Z
   - Message: Storage bucket not found
   - Source: personal-project

Debugging error...

[Proceeds with debugging workflow]
```

### Scenario 3: List Only Mode

```bash
/debug_pending_errors --list-only
```

**Output:**
```
Found 2 pending error(s) in neotoma:

1. [CRITICAL] Build Error (2025-01-31T14:30:22Z)
   - ID: 01JQZ8X9K2M3N4P5Q6R7S8T9U0
   - Message: Cannot find module '../db'
   - Affected: src/services/raw_storage.ts

2. [HIGH] Runtime Error (2025-01-31T14:45:10Z)
   - ID: 01JQZ8X9K2M3N4P5Q6R7S8T9U1
   - Message: MCP error -32603: UNKNOWN_CAPABILITY
   - Affected: src/server.ts

Use /debug_pending_errors to debug highest priority error.
```

### Scenario 4: No Pending Errors

```bash
/debug_pending_errors
```

**Output:**
```
No pending errors found in current repository.

All clear!
```

### Scenario 5: Debug All Errors

```bash
/debug_pending_errors --all
```

**Output:**
```
Found 3 pending error(s). Processing all in priority order...

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Processing error 1 of 3: [CRITICAL] Build Error
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[Debugging workflow for error 1]

[After error 1 resolved]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Processing error 2 of 3: [HIGH] Runtime Error
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[Debugging workflow for error 2]

...

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
All Errors Processed
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Total errors: 3
Resolved: 2
Failed: 1

Remaining pending errors: 1
```

## Implementation Checklist

When debugging pending errors:
- [ ] Parse target-repo-name parameter (if provided)
- [ ] Sanitize repo name (prevent path traversal)
- [ ] Resolve target repository path
- [ ] Validate target repository exists and is git repo
- [ ] Check for .cursor/error_reports/ directory
- [ ] Read pending.json queue
- [ ] Sort errors by priority (severity + timestamp)
- [ ] Display pending errors to user
- [ ] Select error to debug (highest priority or user choice)
- [ ] Prompt user for confirmation (unless --auto flag)
- [ ] Load full error report details
- [ ] Display error context to user
- [ ] Trigger fix_feature_bug with error context (or manual mode)
- [ ] Update resolution_status in error report
- [ ] Move resolved error to archive
- [ ] Remove from pending queue
- [ ] Output resolution summary
- [ ] Handle --list-only flag (display without debugging)
- [ ] Handle --all flag (process all errors)
- [ ] Handle --auto flag (skip confirmation)

## Repository Metadata Collection

For each error report, collect repository metadata:

```javascript
function getRepositoryMetadata(repoPath) {
  const name = path.basename(repoPath);
  
  let remoteUrl = null;
  try {
    remoteUrl = execSync('git remote get-url origin', { cwd: repoPath })
      .toString()
      .trim();
  } catch {
    // No remote or error getting remote
  }
  
  return {
    path: repoPath,
    name: name,
    remote_url: remoteUrl
  };
}
```

## Testing Scenarios

### Test 1: Debug Current Repo with Pending Errors
**Setup:** Create sample pending.json with 2 errors
**Expected:** Display errors, debug highest priority

### Test 2: Debug Sibling Repo with Pending Errors
**Setup:** Create errors in sibling repo
**Expected:** Display errors from sibling repo, debug highest priority

### Test 3: No Pending Errors
**Setup:** Empty or missing pending.json
**Expected:** Message "No pending errors found. All clear!"

### Test 4: Missing Error Reports Directory
**Setup:** Target repo without .cursor/error_reports/
**Expected:** Error message with instruction to use /report_error

### Test 5: Invalid Target Repo Name
**Setup:** Use non-existent sibling repo name
**Expected:** Error message about target repo not found

### Test 6: List Only Mode
**Setup:** Pending errors exist
**Expected:** Display errors without debugging, exit

### Test 7: Debug All Mode
**Setup:** Multiple pending errors
**Expected:** Process all errors in priority order

### Test 8: Auto Mode
**Setup:** Pending errors exist
**Expected:** Debug highest priority without confirmation prompt

### Test 9: Manual Debugging Mode
**Setup:** Error exists, user chooses manual mode
**Expected:** Display error details, wait for user to fix, then update status

### Test 10: Failed Fix
**Setup:** Fix attempt fails (tests still failing)
**Expected:** Update status to 'failed', keep in pending queue

## Best Practices

1. **Always validate target repo** before reading error reports
2. **Sort by priority** to debug critical errors first
3. **Prompt for confirmation** unless --auto flag specified
4. **Archive resolved errors** for audit trail
5. **Update resolution notes** with details of fix
6. **Handle failed fixes gracefully** - update status, don't remove from queue
7. **Support manual mode** for errors that need human investigation
8. **Display clear summaries** of pending errors and resolution results

## Related Documentation

- `foundation/agent_instructions/cursor_commands/report_error.md` - Error reporting workflow
- `foundation/agent_instructions/cursor_commands/fix_feature_bug.md` - Bug fix workflow
- `foundation-config.yaml` - Configuration file

