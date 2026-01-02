# Feature Unit Workflow

_(Atomic, Testable, Spec-First Development with Human Checkpoints)_

---

## Purpose

Defines the **Feature Unit workflow** — a structured approach to software development where every change is fully specified before implementation, independently testable, and reviewed at critical checkpoints.

**Location:** This is a foundation workflow document. It applies to repositories that enable Feature Unit development in their foundation configuration.

---

## What is a Feature Unit?

A **Feature Unit** is a complete, self-contained unit of functionality consisting of:

1. **Spec Document** — Complete specification written before coding
2. **Manifest** (YAML) — Machine-readable metadata
3. **Implementation** — Code changes
4. **Tests** — Unit, integration, E2E as appropriate
5. **Documentation Updates** — If introducing new patterns

**Feature Units MUST be:**

- **Atomic:** Complete a single logical feature or fix
- **Testable:** Include comprehensive tests
- **Documented:** Fully specified before coding
- **Reviewable:** Complete context for human review
- **Traceable:** Requirements → Implementation → Tests

---

## Workflow Overview

The Feature Unit workflow has **3 interactive checkpoints** where human input is required:

1. **Checkpoint 0: Spec Creation** — Interactive questions to create complete spec
2. **Checkpoint 1: Prototype Review** — Human approval before implementation (UI features only)
3. **Checkpoint 2: Final Review** — Human approval before completion

All other steps are autonomous.

**Configuration:** Feature Unit workflow is configured in `foundation-config.yaml`:

```yaml
feature_units:
  enabled: true
  directory: "docs/feature_units/"
  id_pattern: "FU-YYYY-MM-NNN"
  manifest_complexity: "simple"  # or "extended"
  product_strategy:
    track_defensible_differentiation: true
    differentiation_types: ["privacy-first", "deterministic"]
```

---

## Prerequisites

Before creating a Feature Unit, verify:

- [ ] Feature Unit ID follows configured pattern (check `foundation-config.yaml`)
- [ ] Feature Unit is not a duplicate of existing work
- [ ] Feature Unit scope is atomic (single logical feature/fix)
- [ ] All dependencies are identified

---

## Workflow Steps

### Step 0: Checkpoint 0 — Spec Creation

**Trigger:** User requests creation of Feature Unit with `feature_id`

**Agent Actions:**

1. **Load configuration:**
   - Read `foundation-config.yaml` to get feature unit settings
   - Determine directory structure, ID pattern, required sections
   - Check if product strategy tracking is enabled
   - Check manifest complexity mode (simple vs extended)

2. **Check if spec exists:**
   - Look for `{configured_directory}/completed/{feature_id}/{feature_id}_spec.md`
   - Look for `{configured_directory}/in_progress/{feature_id}/{feature_id}_spec.md`
   - Look for project-specific FU inventory (if configured)

3. **If spec exists:**
   - Load existing spec
   - Validate completeness using template checklist
   - If complete → proceed to Step 1
   - If incomplete → prompt user to complete missing sections

4. **If spec does NOT exist:**

   **STOP and prompt user interactively for required information:**

   **Core Questions (always asked):**
   - Feature name and brief description
   - Priority (P0/P1/P2/P3)
   - Risk level (Low/Medium/High)
   - User value (why this matters to users)
   - Functional requirements (list)
   - Non-functional requirements (performance, reliability, etc.)
   - Dependencies (list of feature_ids this requires)
   - Testing strategy (unit, integration, E2E)
   - Observability (metrics, logs) — At least one required

   **Product Strategy Questions (if enabled in config):**
   - If `product_strategy.track_defensible_differentiation: true`:
     - "How does this feature validate or enable your defensible differentiators?"
     - Show configured differentiation types as options
   - If `product_strategy.track_competitive_positioning: true`:
     - "How does this feature position against competitors?"
   
   **Architecture Questions (if extended manifest mode):**
   - If `architecture.track_subsystems: true`:
     - "Which architecture modules are affected?"
     - Show configured subsystems as options
   - If `architecture.track_schema_changes: true`:
     - "Any database schema changes?"
   - If `architecture.track_api_changes: true`:
     - "Any API/endpoint changes?"
   - If `architecture.track_ui_changes: true`:
     - "Any UI changes?"
   
   **UI Questions (if UI changes indicated):**
   - User flow description
   - Visual design requirements
   - Interaction patterns
   - Responsive design requirements
   - Accessibility priorities
   - Empty/error/loading/success states
   - Mockups or design references

   **Agent Actions After User Input:**
   - Generate spec following template (use configured sections)
   - Generate manifest following complexity mode (simple or extended)
   - If product strategy tracking enabled, add strategy sections to spec
   - If UI changes present, add UX Requirements section to spec
   - Validate all required sections present
   - Save to `{configured_directory}/in_progress/{feature_id}/`

   **Alignment Check (Spec vs Mental Model):**

   After drafting the spec, produce a concise summary covering:
   - Problem it solves and why it exists
   - What is explicitly in scope and out of scope
   - Which modules/subsystems it will touch (if architecture tracking enabled)
   - Critical constraints or invariants
   
   Present to user and ask:
   - "Does this accurately capture what you want this Feature Unit to do? (yes/no)"
   - "What feels off, missing, or over-scoped?"
   
   Incorporate corrections immediately and re-summarize if needed.
   
   **MUST NOT** proceed until user confirms spec matches their mental model.

5. **Dependency Validation (if enabled in config):**

   If `dependencies.validate_on_create: true`:
   - Extract all feature_ids from `dependencies.requires` in manifest
   - For each dependency, check if it exists and is completed
   - If `dependencies.reject_missing_dependencies: true`:
     - **REJECT** if dependency not found or not started
   - If `dependencies.allow_partial_dependencies: true`:
     - **WARN** but allow if dependency is in progress (requires user confirmation)
   - If `dependencies.reject_missing_dependencies: false`:
     - **WARN** but allow missing dependencies

6. **Create file structure:**

   ```
   {configured_directory}/in_progress/{feature_id}/
     ├── {feature_id}_spec.md
     └── manifest.yaml
   ```

7. **Create test directories (if tests enabled):**
   ```
   tests/unit/features/{feature_id}/
   tests/integration/features/{feature_id}/
   tests/e2e/features/{feature_id}/      (if e2e tests required)
   tests/regression/features/{feature_id}/
   ```

---

### Step 1: Prototype Creation (UI Features Only)

**Trigger:** Spec created with UI requirements OR no UI changes

**Agent Actions:**

1. **If UI changes present:**
   - Create fully functional client-side prototype
   - Use configured prototype directory structure
   - Mock all backend APIs
   - Include all states (loading, error, empty, success)
   - Make prototype runnable
   - Document mock API responses

2. **Prototype requirements:**
   - Fully interactive (click, type, navigate)
   - All API calls mocked (no real backend)
   - All UI states testable
   - Accessible (keyboard nav, ARIA if applicable)
   - Uses existing design system

3. **If no UI changes:**
   - Skip to Step 2

---

### Step 2: Checkpoint 1 — Prototype Review (UI Features Only)

**Trigger:** Prototype created OR no UI changes

**Agent Actions:**

1. **If prototype was created:**
   - Present prototype location and run command
   - Summarize what prototype demonstrates
   - **STOP and prompt user:**
     - "Review prototype at [location]"
     - "Does it meet your requirements? (yes/no)"
     - "Any changes needed?"

2. **If user requests changes:**
   - Update prototype
   - Repeat until approved

3. **If approved or no UI changes:**
   - Document approval in spec (if prototype was reviewed)
   - Proceed to Step 3

---

### Step 3: Implementation

**Trigger:** Spec approved (and prototype approved if UI feature)

**Agent Actions:**

1. **Setup git workflow (if configured):**
   - If `git_workflow.use_worktrees: true`, create worktree
   - Otherwise create feature branch
   - Push branch to remote

2. **Implement feature:**
   - Follow spec requirements exactly
   - Implement tests alongside code
   - Add observability (metrics, logs)
   - Update documentation if patterns change

3. **Testing requirements (from config):**
   - Unit tests (if `testing.require_unit_tests: true`)
   - Integration tests (if `testing.require_integration_tests: true`)
   - E2E tests (if `testing.require_e2e_tests: true`)
   - Coverage targets (from `testing.coverage_targets`)

4. **Spec-to-Implementation Diff Check:**
   - Compare implementation against spec
   - List any intentional divergences
   - For each divergence: update spec or fix implementation
   - **MUST NOT** proceed until spec and implementation are aligned

5. **Run tests:**
   - Run all tests for this feature
   - Verify coverage meets targets
   - Fix any failures

---

### Step 4: Checkpoint 2 — Final Review

**Trigger:** Implementation complete, tests passing

**Agent Actions:**

1. **Gather implementation summary:**
   - Files changed
   - Tests added (with pass status)
   - Documentation updated
   - Coverage achieved

2. **Verify completion:**
   - All required tests passing
   - Coverage targets met
   - Spec and implementation aligned
   - PR created (if required by config)

3. **STOP and prompt user:**
   - "Implementation complete. PR: [link]"
   - "Please review the implementation"
   - "Approve for merge? (yes/no)"
   - "Any final changes needed?"

4. **If user requests changes:**
   - Apply changes
   - Re-run tests
   - Update PR
   - Repeat until approved

5. **If approved:**
   - Mark spec status as `Completed`
   - Move files from `in_progress/` to `completed/`
   - Update manifest `status: "completed"`
   - Mark PR as ready for merge
   - Clean up worktree (if using worktrees)

---

## Configuration Reference

### Minimal Configuration (Simple Projects)

```yaml
feature_units:
  enabled: true
  directory: "docs/features/"
  id_pattern: "F-YYYY-MM-NNN"
  manifest_complexity: "simple"
  product_strategy:
    track_user_value: true
  testing:
    require_unit_tests: true
    require_integration_tests: true
```

### Full Configuration (Complex Projects)

```yaml
feature_units:
  enabled: true
  directory: "docs/feature_units/"
  id_pattern: "FU-YYYY-MM-NNN"
  manifest_complexity: "extended"
  product_strategy:
    track_defensible_differentiation: true
    differentiation_types: ["privacy-first", "deterministic"]
  architecture:
    track_subsystems: true
    subsystems: ["ingestion", "schema", "search"]
    track_schema_changes: true
    track_api_changes: true
  testing:
    require_unit_tests: true
    require_integration_tests: true
    require_e2e_tests: true
    coverage_targets:
      critical_paths: 100
```

---

## Agent Instructions

### When to Load This Document

Load when:
- User requests creation of a new Feature Unit
- Planning feature development
- Understanding Feature Unit workflow

### Required Co-Loaded Documents

- `foundation/development/feature_unit_workflow.md` — This document
- `foundation/development/templates/feature_unit_spec_template.md` — Spec template
- `foundation/development/templates/manifest_template_simple.yaml` or `manifest_template_extended.yaml` — Manifest template
- Repository-specific execution instructions (if they exist)

### Constraints Agents Must Enforce

1. **NEVER create Feature Unit without complete spec**
2. **ALWAYS validate dependencies** (if enabled in config)
3. **REJECT creation if dependencies not implemented** (if configured)
4. **ALWAYS prompt user at configured checkpoints**
5. **ALWAYS create prototype for UI features before implementation** (if checkpoint enabled)
6. **ALWAYS get user approval before proceeding past checkpoints**
7. **ALWAYS include required observability** (if configured)
8. **ALWAYS perform spec-to-implementation diff check** before final review

### Forbidden Patterns

- Creating Feature Unit when dependencies are not implemented (if validation enabled)
- Implementing code before prototype approval (for UI features)
- Skipping dependency validation (if enabled)
- Proceeding past checkpoints without user approval
- Creating incomplete specs

---

## Quick Reference

### Command Sequence

1. **Create Feature Unit:** Use `create_feature_unit` command with `feature_id`
2. **Interactive spec creation:** Answer questions at Checkpoint 0
3. **Review prototype (if UI):** Approve prototype at Checkpoint 1
4. **Implementation:** Autonomous (follows spec)
5. **Final review:** Approve implementation at Checkpoint 2

### Status Flow

```
Draft → In Progress → Review → Completed
```

---

## Related Foundation Documents

- `foundation/development/release_workflow.md` — Release orchestration (coordinates multiple Feature Units)
- `foundation/development/templates/feature_unit_spec_template.md` — Spec template
- `foundation/development/templates/manifest_template_simple.yaml` — Simple manifest
- `foundation/development/templates/manifest_template_extended.yaml` — Extended manifest
- `foundation/agent_instructions/cursor_commands/create_feature_unit.md` — Creation command
- `foundation/agent_instructions/cursor_commands/run_feature_workflow.md` — Implementation command

