# Feature Unit: [{FEATURE_ID}] {Feature Name}

**Status:** Draft | In Progress | Review | Completed
**Priority:** P0 (Critical) | P1 (High) | P2 (Medium) | P3 (Low)
**Risk Level:** Low | Medium | High
**Target Release:** vX.Y.Z
**Owner:** [Name]
**Reviewers:** [Names]
**Created:** YYYY-MM-DD
**Last Updated:** YYYY-MM-DD

---

## Overview

**Brief Description:**

One-paragraph summary of what this Feature Unit accomplishes.

**User Value:**

Why this matters to users. What problem does it solve? What benefit does it provide?

**Product Strategy:** _(Optional: Include if `product_strategy` tracking enabled in foundation-config)_

- **Defensible Differentiation:** How this feature validates or enables your defensible differentiators (if applicable)
- **Competitive Positioning:** How this feature positions against competitors (if applicable)

**Technical Approach:**

High-level approach. Which modules/layers/subsystems are affected?

---

## Requirements

### Functional Requirements

1. **[Requirement 1]:** Detailed description
2. **[Requirement 2]:** Detailed description
3. **[Requirement 3]:** Detailed description

### Non-Functional Requirements

1. **Performance:** Response time, throughput targets
2. **Reliability:** Uptime, error rate targets
3. **Scalability:** Load handling, growth projections
4. **Accessibility:** A11y requirements (if applicable)
5. **Internationalization:** i18n requirements (if applicable)

### Invariants (MUST/MUST NOT)

**MUST:**

- [Critical invariant 1]
- [Critical invariant 2]

**MUST NOT:**

- [Anti-pattern 1]
- [Anti-pattern 2]

---

## Architecture _(Optional: Include if `architecture` tracking enabled in foundation-config)_

### Affected Modules/Subsystems

**Primary Modules:**

- [Module 1]: What changes
- [Module 2]: What changes

**Dependencies:**

- Requires [Other Feature Unit ID or dependency]
- Blocks [Other Feature Unit ID]

**Documentation to Load:**

- `docs/architecture/[relevant_doc].md`
- `docs/modules/[relevant_module].md`

### Schema Changes _(Optional: Include if `architecture.track_schema_changes: true`)_

**Tables Affected:**

- `table_name`: ADD COLUMN `column_name` TYPE
- `table_name`: CREATE INDEX `index_name` ON ...

**Migration Required:** Yes | No

If yes, include migration file path and description.

### API Changes _(Optional: Include if `architecture.track_api_changes: true`)_

**New Endpoints:**

- `POST /api/endpoint`: Description

**Modified Endpoints:**

- `GET /api/existing`: What changed

**API Contract:**

```typescript
// Request
interface RequestType {
  field: type;
}

// Response
interface ResponseType {
  field: type;
}

// Errors
const POSSIBLE_ERRORS = ["ERROR_CODE_1", "ERROR_CODE_2"];
```

### UI Changes _(Optional: Include if `architecture.track_ui_changes: true`)_

**Components:**

- `ComponentName`: New | Modified | Deprecated

**Screens/Views:**

- `ScreenName`: Description

---

## UX Requirements _(Optional: Include if UI changes present)_

### User Flow

Step-by-step user journey:

1. User [action]
2. System [response]
3. User [action]
4. ...

### Visual Design

- Layout requirements
- Styling preferences
- Design system components to use

### Interaction Patterns

- How users interact with components
- Gestures, clicks, keyboard shortcuts

### Responsive Design

- Mobile behavior
- Tablet behavior
- Desktop behavior

### Accessibility

- Keyboard navigation requirements
- Screen reader support
- ARIA labels needed
- Focus management

### UI States

- **Empty State:** What users see when no data
- **Loading State:** How loading is indicated
- **Error State:** How errors are displayed
- **Success State:** Confirmation and feedback

### Design References

- Links to mockups, wireframes, or design files

---

## Testing Strategy

### Unit Tests

**Coverage Target:** {configured_coverage}% (from foundation-config)

**Test Cases:**

- Test case 1: Description
- Test case 2: Description

**Files:**

- `tests/unit/features/{feature_id}/test_file.test.ts`

### Integration Tests

**Test Cases:**

- Integration test 1: Description
- Integration test 2: Description

**Files:**

- `tests/integration/features/{feature_id}/test_file.test.ts`

### E2E Tests _(Optional: Include if `testing.require_e2e_tests: true`)_

**User Flows:**

- Flow 1: Description
- Flow 2: Description

**Files:**

- `tests/e2e/features/{feature_id}/test_file.spec.ts`

### Test Fixtures

**Required Fixtures:**

- `fixture_name`: Description and location

---

## Observability

**REQUIRED:** At least one metric or log pattern that would catch this Feature Unit misbehaving.

### Metrics

- `metric_name`: Type (counter/gauge/histogram), description
- `metric_name_2`: Type, description

### Logs

- **Level:** info/warn/error
- **Event:** event_name
- **Fields:** field1, field2

### Events _(Optional)_

- `event_type`: When emitted, payload fields

### Traces _(Optional)_

- `span_name`: Attributes tracked

---

## Dependencies

### Requires

- `{feature_id}`: Reason why this dependency is needed

### Blocks

- `{feature_id}`: Reason why this blocks other work

---

## Kill Switch / Defer Criteria _(Optional: Include if `kill_switch.enabled: true`)_

**Conditions for deferring or pausing this Feature Unit:**

- Condition 1: Action to take
- Condition 2: Action to take

**If any condition is met during execution, agent MUST stop and ask user: defer, pause, or continue?**

---

## Rollout Plan _(Optional)_

**Strategy:** Instant | Phased | Canary

**Phases:** (if phased)

1. Phase 1: X% for Y days
2. Phase 2: X% for Y days
3. Full rollout: 100%

**Rollback Plan:**

- Trigger conditions (error rate, performance degradation)
- Rollback steps

**Monitoring:**

- Key metrics to watch
- Alert thresholds

---

## Notes

Additional context, design decisions, or links to external resources.

---

## Related Documents

- `foundation/development/feature_unit_workflow.md` — Feature Unit workflow
- `foundation/development/templates/manifest_template_simple.yaml` or `manifest_template_extended.yaml` — Manifest template
- Repository-specific architecture/module documentation

