# Instruction Documentation Rule

Documents important instructions, constraints, and guidelines in appropriate files. Ensures availability to all Cursor agents via repo rules.

## Configuration

```yaml
agent_instructions:
  enabled: true
  location: "docs/foundation/agent_instructions.md"
  cursor_rules:
    enabled: true
    location: ".cursor/rules/"
```

## Trigger Patterns

Document immediately during the same conversation, before proceeding with other work.

**High-priority triggers:**
- "always do X" or "never do Y"
- "remember to" or "make sure to"
- "all agents should" or "everyone must"

**Standard triggers:**
- Code style, patterns, conventions
- Architectural constraints or boundaries
- Workflow processes or procedures
- Testing requirements or standards
- Documentation standards
- Security or privacy requirements
- Error handling or validation rules
- Repository-wide policies

## Meta-Rule: Creating Rules

When user says "always X" or "never Y":

1. Recognize as rule creation request
2. Determine scope:
   - **Foundation rule** (benefits all repos): `foundation/agent-instructions/cursor-rules/{topic}.md`
   - **Repository-specific rule**: `.cursor/rules/{topic}.md` or `docs/` subdirectory
3. Create rule immediately without asking for confirmation
4. Update references (foundation README for foundation rules, repo docs for repo-specific)

**Decision tree:**
- Benefits ALL repos using foundation → Foundation rule
- Generic agent behavior → Foundation rule
- Repository-specific domain/architecture → Repo-specific rule
- Project-specific features/constraints → Repo-specific rule

## Instruction Classification

**Repository-wide agent instructions:**
- Location: `docs/foundation/agent_instructions.md`
- Affects all agents working on the repo

**Workflow or process instructions:**
- Location: `docs/feature_units/standards/` or `.cursor/rules/`
- Affects work organization or execution

**Architectural constraints:**
- Location: `docs/foundation/` or `docs/architecture/`
- System boundaries, layer rules, invariants

**Code conventions:**
- Location: `docs/conventions/` or `.cursor/rules/`
- Style, patterns, naming conventions

**Cursor-specific repo rules:**
- Location: `.cursor/rules/`
- Automatic agent behaviors, detection patterns

## Documenting Instructions

**For repository-wide agent instructions:**
1. Check if instruction exists in agent instructions file
2. Add to appropriate section using directive language (MUST/SHOULD/MUST NOT)
3. Create rule file in `.cursor/rules/` if Cursor-specific

**For Cursor repo rules:**
1. Create rule file in `.cursor/rules/`
2. Use filename: `{topic}_rule.md` or `{topic}_management.md`
3. Follow existing rule format (Purpose, Trigger Patterns, Agent Actions, Constraints)
4. Update central reference if exists

**For documentation-only instructions:**
1. Document in appropriate location (agent instructions file, `docs/conventions/`, `docs/architecture/`, `docs/feature_units/standards/`)
2. Do NOT store documentation in repo root - use `docs/` subdirectories
3. Store temporary assessment/analysis files in `tmp/` directory
4. Update central reference if exists

## Format Standards

**Agent instructions format:**
```markdown
## Section Number. Clear Title

Brief description.

### Subsection. Specific Rule

1. Rule statement (use MUST/SHOULD/MUST NOT)
2. Rationale or context (if needed)
3. Examples (if helpful)
```

**Cursor repo rules format:**
```markdown
# Rule Title

## Purpose

Clear statement of what this rule ensures.

## Trigger Patterns

When [conditions], agents MUST [action].

## Agent Actions

### Step 1: [Action]

1. [Specific action]
2. [Specific action]

## Constraints

- MUST / MUST NOT statements
- ALWAYS / NEVER statements
```

## Workflow

When user provides instructions (especially "always" or "never"):

1. Detect trigger pattern
2. Acknowledge: "Documenting instruction permanently in [location]"
3. Classify instruction type and determine rule scope (apply Meta-Rule above)
4. Document immediately (same conversation):
   - Read target documentation file
   - Add instruction using proper format
   - Create or update rule file if needed
   - Update central reference if new rule created
   - Use directive language (MUST/SHOULD/MUST NOT/ALWAYS/NEVER)
5. Update downstream documentation if applicable (see `downstream_doc_updates.md`)
6. Confirm completion with details

**Do NOT:**
- Skip documentation and proceed with other work
- Promise to document "later" or in future conversation
- Document only in conversation memory
- Assume instruction is temporary

**Before starting work:**
1. Load required rules (central reference, rule files, agent instructions file)
2. Verify instructions are current

## Constraints

- Document "always" and "never" instructions immediately during same conversation
- Do NOT defer documentation to future conversation
- Do NOT document only in conversation memory
- Classify instruction type before documenting
- Update central reference when adding new rules
- Update downstream documentation when upstream docs change
- Use directive language (MUST/SHOULD/MUST NOT/ALWAYS/NEVER)
- Do NOT duplicate instructions across multiple files without cross-references
- Ensure instructions are discoverable via central reference or `.cursor/rules/`
- Do NOT store documentation files in repo root
- Do NOT store temporary assessment/analysis files in `docs/` - use `tmp/`

## Availability

Cursor agents automatically have access to:
1. All files in `.cursor/rules/`
2. Central reference (e.g., agent instructions file)
3. Files referenced in central reference
