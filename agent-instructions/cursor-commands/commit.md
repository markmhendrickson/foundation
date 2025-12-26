# commit

**SUBMODULE COMMIT MODE**: If a submodule name is provided (e.g., `/commit foundation`), commit changes in that submodule only, not the main repository.

**If submodule name provided:**
1. Check if submodule exists: `git submodule status <submodule-name>`
2. Change to submodule directory: `cd <submodule-name>`
3. Run commit workflow in submodule context (security audit, staging, commit)
4. Exit after submodule commit (do NOT commit main repository)

**If no submodule name provided**, proceed with main repository commit workflow below.

---

Run entire test suite and resolve any errors as necessary. Proceed to analyze all uncommitted files for security vulnerabilities and patch as necessary.

**CRITICAL: PRE-COMMIT SECURITY AUDIT** - MUST RUN BEFORE STAGING:

Before staging ANY files, execute the security audit from `foundation/agent-instructions/cursor-rules/security.md` (or `.cursor/rules/security.md` if installed):

1. **Run security audit script:**
   ```bash
   # Use foundation security audit script if available
   if [ -f "foundation/security/pre-commit-audit.sh" ]; then
     ./foundation/security/pre-commit-audit.sh
   elif [ -f ".cursor/rules/security.md" ]; then
     # Follow security rule checks
     # (Implementation depends on how security rules are executed)
   fi
   ```

2. **If any check fails, ABORT immediately and alert the user. DO NOT proceed with staging or commit.**

**ONLY AFTER security audit passes**, proceed with:

**NESTED GIT REPOSITORY DETECTION AND COMMIT** (Optional, configurable):

**Configuration:** Enable/disable nested repo handling in `foundation-config.yaml`:
```yaml
development:
  commit:
    handle_nested_repos: false  # Set to true to enable nested repo handling
```

**If enabled**, before committing the main repository, detect and commit any nested git repositories:

**CRITICAL**: Nested repositories must be committed BEFORE the main repository to maintain consistency.

1. **Detect nested git repositories:**
   ```bash
   # Find all nested .git directories (excluding the root .git and submodules)
   # Store in a temporary file to avoid subshell issues
   NESTED_REPOS_FILE=$(mktemp)
   find . -name ".git" -type d -not -path "./.git" -not -path "./.git/*" 2>/dev/null | sed 's|/.git$||' | sort > "$NESTED_REPOS_FILE"

   if [ -s "$NESTED_REPOS_FILE" ]; then
     echo "📦 Found nested git repositories:"
     while IFS= read -r repo_path; do
       echo "  - $repo_path"
     done < "$NESTED_REPOS_FILE"
     echo ""
   fi
   ```

2. **For each nested repository, commit changes:**
   ```bash
   # Process each nested repo
   if [ -s "$NESTED_REPOS_FILE" ]; then
     while IFS= read -r repo_path; do
       if [ -n "$repo_path" ] && [ -d "$repo_path/.git" ]; then
         echo "🔄 Processing nested repository: $repo_path"

         # Save current directory
         ORIGINAL_DIR=$(pwd)

         # Change to nested repo directory
         cd "$repo_path" || {
           echo "  ❌ Failed to change to directory: $repo_path"
           rm -f "$NESTED_REPOS_FILE"
           exit 1
         }

         # Check if there are any changes
         if git status --porcelain | grep -q .; then
           echo "  📝 Found changes, committing..."

           # Run security audit for nested repo (same checks as main repo)
           echo "  🔒 Running security audit..."
           # (Run same security audit as main repo)

           # Stage all changes
           echo "  📝 Staging changes..."
           git add -A

           # Generate commit message for nested repo
           echo "  📝 Generating commit message..."
           # (Use configured commit message format)

           # Commit nested repo
           echo "  💾 Committing changes..."
           git commit -m "$COMMIT_MSG" || {
             echo "  ❌ Failed to commit nested repository: $repo_path"
             cd "$ORIGINAL_DIR"
             rm -f "$NESTED_REPOS_FILE"
             exit 1
           }

           # Push nested repo (if remote exists and configured)
           if git remote | grep -q .; then
             echo "  📤 Pushing to remote..."
             git push || {
               echo "  ⚠️  Warning: Failed to push nested repository: $repo_path"
               echo "  Continuing with main repository commit..."
             }
           else
             echo "  ℹ️  No remote configured, skipping push"
           fi

           echo "  ✓ Successfully committed nested repository: $repo_path"
         else
           echo "  ✓ No changes in $repo_path"
         fi

         # Return to original directory
         cd "$ORIGINAL_DIR" || {
           rm -f "$NESTED_REPOS_FILE"
           exit 1
         }
         echo ""
       fi
     done < "$NESTED_REPOS_FILE"

     # Clean up temp file
     rm -f "$NESTED_REPOS_FILE"
   fi
   ```

3. **If any nested repo commit fails, ABORT the entire commit process and return to root directory.**

4. **After all nested repos are successfully committed, proceed with main repository commit.**

**UI TESTING** (Optional, configurable):

**Configuration:** Enable/disable UI testing in `foundation-config.yaml`:
```yaml
development:
  commit:
    ui_testing:
      enabled: false
      frontend_paths: ["frontend/src/**"]  # Paths to check for frontend changes
```

**If enabled**, if any frontend files were modified, automatically verify user-facing changes work correctly in the browser before committing. After completing the browser run, rerun the security audit in case new assets or logs were created.

**IMPORTANT**: Before committing, ensure all changes are staged:

**CRITICAL: Exclude nested repositories from main repo staging** (if nested repo handling enabled):

1. **Detect nested repos and build exclusion patterns:**
   ```bash
   # Detect nested repos first (before staging main repo)
   NESTED_REPOS_STAGING_FILE=$(mktemp)
   find . -name ".git" -type d -not -path "./.git" -not -path "./.git/*" 2>/dev/null | sed 's|/.git$||' | sort > "$NESTED_REPOS_STAGING_FILE"

   # Build exclusion patterns for git add
   EXCLUDE_PATTERNS=""
   if [ -s "$NESTED_REPOS_STAGING_FILE" ]; then
     echo "📦 Excluding nested repositories from main repo staging:"
     while IFS= read -r repo_path; do
       if [ -n "$repo_path" ]; then
         echo "  - Excluding $repo_path"
         # Escape special characters and add to exclusion
         ESCAPED_PATH=$(echo "$repo_path" | sed 's/[[\.*^$()+?{|]/\\&/g')
         if [ -z "$EXCLUDE_PATTERNS" ]; then
           EXCLUDE_PATTERNS=":!/$ESCAPED_PATH"
         else
           EXCLUDE_PATTERNS="$EXCLUDE_PATTERNS :!/$ESCAPED_PATH"
         fi
       fi
     done < "$NESTED_REPOS_STAGING_FILE"
   fi
   ```

2. **Stage changes while excluding nested repositories:**
   ```bash
   # Stage all changes except nested repos
   if [ -n "$EXCLUDE_PATTERNS" ]; then
     git add -A $EXCLUDE_PATTERNS
   else
     git add -A
   fi
   ```

3. **Re-run security audit on staged files** to ensure nothing private or from nested repos was accidentally staged.

4. Verify staged changes with `git status` to ensure nothing is missed
5. If any files were modified after the initial `git add`, run `git add -A` again with exclusions right before committing, then re-run the security audit

**BRANCH RENAMING** (Optional, configurable):

**Configuration:** Enable/disable branch renaming in `foundation-config.yaml`:
```yaml
development:
  commit:
    branch_renaming:
      enabled: false
      patterns: ["chat-*"]  # Patterns to rename
```

**If enabled**, automatically rename branches matching configured patterns before committing.

**COMPREHENSIVE CHANGE ANALYSIS**: Before generating the commit message, perform comprehensive analysis of all staged changes:

1. **Categorize Changes by Type:**
   - Run `git diff --cached --name-status` to get all changed files with their status (A/M/D)
   - Group files by status: Added (A), Modified (M), Deleted (D)
   - Count files in each category

2. **Categorize Changes by Functional Area:**
   - Group files by directory/domain (customize per repository):
     - Documentation (`docs/**`) - further categorize by subdirectory
     - Source code (`src/**`, `frontend/src/**`, or configured paths)
     - Scripts (`scripts/**`)
     - Configuration (`*.json`, `*.yaml`, `*.toml`, `*.config.*`)
     - Tests (`**/*.test.*`, `**/*.spec.*`, or configured test paths)
     - Build/deployment (`Dockerfile`, `*.sh`, or configured paths)
   - Identify major functional areas affected

3. **Analyze Change Magnitude:**
   - Run `git diff --cached --stat` to get line counts (insertions/deletions)
   - Identify files with significant changes (>100 lines added/removed, configurable)
   - Note files that are new vs. heavily modified vs. deleted

4. **Extract Key Themes:**
   - Review file names and paths to identify common themes
   - Look for patterns: new features, refactoring, documentation updates, bug fixes, configuration changes
   - Identify if changes span multiple areas (cross-cutting concerns)

5. **Generate Structured Commit Message:**
   The commit message MUST follow the configured format from `foundation-config.yaml`:
   ```yaml
   development:
     commit_format:
       require_id: true  # whether ID is required in commit messages
       pattern: "{id}: {description}"  # or custom pattern
   ```

   **Default structure** (if no custom format configured):
   - **Summary line** (50-72 chars): High-level description of the primary change
   - **Detailed sections** organized by functional area:
     - Documentation Changes (if docs modified)
     - New Features/Components (if new files added)
     - Architecture/Design Changes (if architecture docs modified)
     - Code Changes (if source code modified)
     - Configuration Changes (if config files modified)
     - Bug Fixes (if bug fixes detected)
     - Other Changes (miscellaneous)
   - **For each section**, list:
     - Files added/modified/deleted
     - Key changes or new capabilities
     - Rationale if significant architectural changes

6. **Validation:**
   - Ensure commit message covers ALL staged files (verify with `git diff --cached --name-only`)
   - If any file category is missing from the message, add it
   - If message seems incomplete, analyze diffs more deeply using `git diff --cached --stat` and `git diff --cached <file>` for key files

**COMMIT MESSAGE GENERATION PROCESS:**

1. Run `git diff --cached --name-status` to get all changes
2. Run `git diff --cached --stat` to get change statistics
3. Analyze patterns and group changes logically
4. Generate comprehensive commit message following configured format
5. Verify all files are represented in the message
6. Proceed with commit

**FINAL PRE-COMMIT SECURITY CHECK**: Immediately before executing `git commit`, run one final security audit:

```bash
# Final check on staged files for private/sensitive files
# Use foundation security audit script or rules
if [ -f "foundation/security/pre-commit-audit.sh" ]; then
  ./foundation/security/pre-commit-audit.sh
elif [ -f ".cursor/rules/security.md" ]; then
  # Follow security rule checks
fi

# Final check for nested repository files (if nested repo handling enabled)
# (Same check as above if nested repos are configured)
```

**ONLY IF final security check passes**, proceed to git commit with the comprehensive commit message and push to origin.

**WORKTREE DETECTION:** Follow the Worktree Rule (`.cursor/rules/worktree_env.md` or `foundation/agent-instructions/cursor-rules/worktree_env.md`) to restrict all commit activity to the current worktree.

**COMMIT MESSAGE DISPLAY**: After successfully committing and pushing, always display the full commit message to the user by running `git log -1 --pretty=format:"%B"` and showing the output. This allows the user to review what was committed.

**WORKTREE COMPATIBILITY:** Per the Worktree Rule, commits made within this worktree remain visible to the shared `.git` directory.

After committing the main repository, verify no unstaged changes remain with `git status`. If any files were missed, amend the commit with `git add <file> && git commit --amend --no-edit`.

**NESTED REPOSITORY SUMMARY** (if nested repo handling enabled): After committing the main repository, display a summary of nested repository commits.

**POST-COMMIT VALIDATION**: After displaying the commit message, verify it comprehensively covers all changes by:

1. Running `git show --stat HEAD` to see what was committed
2. Comparing the commit message sections to the actual files changed
3. If significant changes are missing from the message, immediately amend with `git commit --amend` to add missing sections

## Configuration

Configure commit behavior in `foundation-config.yaml`:

```yaml
development:
  commit:
    handle_nested_repos: false  # Enable nested repository handling
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

## Submodule Commit Mode

When a submodule name is provided as an argument (e.g., `/commit foundation`):

1. **Verify submodule exists:**
   ```bash
   if ! git submodule status <submodule-name> >/dev/null 2>&1; then
     echo "❌ Submodule not found: <submodule-name>"
     exit 1
   fi
   ```

2. **Change to submodule directory:**
   ```bash
   cd <submodule-name> || exit 1
   ```

3. **Run security audit in submodule:**
   ```bash
   # Use foundation security audit if available
   if [ -f "foundation/security/pre-commit-audit.sh" ]; then
     ./foundation/security/pre-commit-audit.sh
   elif [ -f "../foundation/security/pre-commit-audit.sh" ]; then
     ../foundation/security/pre-commit-audit.sh
   fi
   ```

4. **Stage and commit in submodule:**
   ```bash
   git add -A
   # Generate commit message (analyze changes in submodule context)
   git commit -m "<commit-message>"
   git push origin HEAD  # if remote exists
   ```

5. **Exit after submodule commit** (do NOT proceed with main repository commit)

**Note:** The commit message generation and change analysis should be done in the submodule context, analyzing only files within that submodule.

## Related Documents

- `foundation/agent-instructions/cursor-rules/security.md` — Security audit rules
- `foundation/agent-instructions/cursor-rules/worktree_env.md` — Worktree environment rules
- `foundation/security/pre-commit-audit.sh` — Pre-commit audit script
- `foundation-config.yaml` — Configuration file

