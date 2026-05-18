# Plan Workflow

Plans are first-class Neotoma entities (`entity_type: plan`). They live in the knowledge graph, not as files in a repo directory. This workflow covers creating, progressing, and closing a plan. Configuration is read from `foundation-config.yaml`.

## Why Neotoma entities, not files

Plans stored as Neotoma entities:
- Are automatically mirrored to `plans/` via the `neotoma-plans` mirror profile (canonical, unidirectional DB → filesystem)
- Support relationships (REFERS_TO objectives, feedback, releases, issues)
- Have a full observation history (every update is a new observation, never an edit)
- Can be queried, filtered, and cross-linked from any agent context

The `plans/` directory in the repo is a read-only mirror. Do not edit files there directly.

## Plan entity fields

Required fields when storing a plan:

| Field | Description |
|---|---|
| `title` | Short, imperative name (e.g. "Add selective mirror profiles") |
| `status` | `draft` \| `active` \| `blocked` \| `completed` \| `abandoned` |
| `description` | Problem being solved and why it matters |
| `scope` | What is explicitly in scope |
| `out_of_scope` | What is explicitly out of scope |
| `success_criteria` | Measurable conditions for completion |

Optional fields:

| Field | Description |
|---|---|
| `priority` | `P0` \| `P1` \| `P2` \| `P3` |
| `phase` | Freeform phase label (e.g. "MVP", "v0.3") |
| `target_release` | Version or date |
| `deliverables` | List of concrete outputs |
| `dependencies` | Other plan canonical names this plan requires |
| `testing_notes` | Testing strategy and coverage requirements |
| `observability_notes` | Metrics, logs, traces needed |

## Checkpoint 0 — Plan creation

Before writing any code, store the plan in Neotoma.

1. **Collect required fields** (see table above). Ask the user for any that are missing.

2. **Alignment check.** After drafting the plan fields, summarize:
   - Problem it solves and why it exists
   - What is explicitly in scope and out of scope
   - Critical invariants or constraints
   
   Ask: "Does this accurately capture what you want this plan to do?"
   
   Incorporate corrections and re-summarize if changes are substantial. Do not proceed until the user confirms.

3. **Store the plan** using `store` or `submit_entity` with `entity_type: plan`. The canonical name is derived from the title slug.

4. **Create relationships** to any relevant entities:
   - `REFERS_TO` for objectives, releases, or parent plans
   - `DEPENDS_ON` for plans this plan requires
   - `INFORMED_BY` for issues, feedback, or research that motivated the plan

5. **Mirror refresh** (optional). The `neotoma-plans` mirror profile writes the plan to `docs/plans/{title}.md` automatically on every write. Run `neotoma mirror rebuild --profile neotoma-plans` to force a full refresh.

## Checkpoint 1 — Mid-execution review

When significant implementation work is complete (or when blocked), update the plan:

1. Update `status` to `active` (or `blocked` with a `blocked_reason` field).
2. Add an observation with progress notes.
3. Resolve or add `DEPENDS_ON` relationships as implementation reveals new dependencies.

## Checkpoint 2 — Completion

When all success criteria are met:

1. Update `status` to `completed`.
2. Add a final observation summarizing what was delivered and any deviations from the original scope.
3. Update or close any `DEPENDS_ON` relationships from plans that depended on this one.

## Querying plans

```
# List all active plans
neotoma query --entity-type plan --field status=active

# Rebuild the plans mirror directory
neotoma mirror rebuild --profile neotoma-plans
```

## Configuration

Plans configuration in `foundation-config.yaml`:

```yaml
plans:
  enabled: true
  mirror_profile: "neotoma-plans"   # Mirror profile ID in canonical_mirror.ts defaults
  mirror_output_path: "docs/plans"        # Repo-relative path mirrored files are written to
```

## Related documents

- `foundation/development/release_workflow.md` — Release orchestration (references plans)
- `src/services/canonical_mirror.ts` — Mirror profile implementation
- `docs/subsystems/ingestion/ingestion.md` — How store observations work
