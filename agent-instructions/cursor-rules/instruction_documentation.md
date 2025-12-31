# Instruction Documentation Rule

**Reference:** `docs/foundation/agent_instructions.md` (or configured location) — Repository-wide agent instructions

Ensures that important instructions, constraints, and guidelines are documented in appropriate documentation files, available to all Cursor agents automatically as repo rules, and maintained and kept up-to-date.

## Configuration

Configure instruction documentation locations in `foundation-config.yaml`:

```yaml
agent_instructions:
  enabled: true
  location: "docs/foundation/agent_instructions.md"  # or ".cursor/rules/"
  cursor_rules:
    enabled: true
    location: ".cursor/rules/"
```

## Trigger Patterns

When any of the following occur, immediately document the instruction in the appropriate repository documentation file. Documentation must happen during the same conversation, before proceeding with other work.

### High-Priority Triggers (Immediate Documentation Required)

- User says "always do X" or "never do Y" - These are permanent instructions that must be documented immediately
- User says "remember to" or "make sure to" - Persistent behavioral instructions
- User says "all agents should" or "everyone must" - Repository-wide requirements

### Standard Triggers

- User provides explicit instructions about:
  - Code style, patterns, or conventions
  - Architectural constraints or boundaries
  - Workflow processes or procedures
  - Testing requirements or standards
  - Documentation standards
  - Security or privacy requirements
  - Error handling or validation rules
  - Repository-wide policies or rules

- User mentions:
  - "follow this pattern" or "use this approach"
  - "this is important" or "critical requirement"
  - "never store docs in repo root" or similar documentation location constraints

- Instructions that affect:
  - Multiple files or subsystems
  - Future development work
  - Agent behavior or decision-making
  - Code generation patterns

## Agent Actions

### Step 0: Meta-Rule: Remember to Create Rules

**When user says "always X" or "never Y":**

1. **Recognize this as a rule creation request** - The user is requesting a permanent rule, not a one-time instruction
2. **Determine rule scope:**
   - **Foundation rule** (generic, applies to all repos using foundation):
     - Generic agent behavior patterns
     - Universal development practices
     - Cross-repository conventions
     - **Location:** `foundation/agent-instructions/cursor-rules/{topic}.md`
   - **Repository-specific rule** (applies only to this repo):
     - Project-specific constraints
     - Domain-specific patterns
     - Repository-unique workflows
     - **Location:** `.cursor/rules/{topic}.md` or `docs/` subdirectory
3. **Decision criteria:**
   - If instruction would benefit ALL repositories using foundation → Foundation rule
   - If instruction is specific to this repository's domain/architecture → Repo-specific rule
   - If instruction is about generic agent behavior → Foundation rule
   - If instruction is about project-specific features/constraints → Repo-specific rule
4. **Create rule immediately** - Do not ask for confirmation, create the rule file in the appropriate location
5. **Update references** - Add rule to appropriate index/README (foundation README for foundation rules, repo docs for repo rules)

**This meta-rule ensures:** When user requests "always X", agents automatically create appropriate rule files without asking where to place them.

**Decision Tree for Rule Placement:**

```
User says "always X" or "never Y"?
    │
    ├─ Would this benefit ALL repos using foundation?
    │   │
    │   ├─ YES → Foundation rule
    │   │   Location: foundation/agent-instructions/cursor-rules/{topic}.md
    │   │   Examples: dependency installation, security patterns, generic workflows
    │   │
    │   └─ NO → Continue to next question
    │
    ├─ Is this specific to this repository's domain/architecture?
    │   │
    │   ├─ YES → Repository-specific rule
    │   │   Location: .cursor/rules/{topic}.md or docs/ subdirectory
    │   │   Examples: project-specific constraints, domain patterns, unique workflows
    │   │
    │   └─ NO → Continue to next question
    │
    └─ Is this about generic agent behavior?
        │
        ├─ YES → Foundation rule
        │
        └─ NO → Repository-specific rule (default)
```

### Step 1: Detect Instruction Type

**Classify the instruction:**

1. **Repository-wide agent instructions:**
   - Affects all agents working on the repo
   - General constraints, patterns, or policies
   - **Location:** `docs/foundation/agent_instructions.md` (or configured)

2. **Workflow or process instructions:**
   - Affects how work is organized or executed
   - Feature, release, or development workflows
   - **Location:** `docs/feature_units/standards/` or `.cursor/rules/` (or configured)

3. **Architectural constraints:**
   - System boundaries, layer rules, invariants
   - **Location:** `docs/foundation/` or `docs/architecture/` (or configured)

4. **Code conventions:**
   - Style, patterns, naming conventions
   - **Location:** `docs/conventions/` or `.cursor/rules/` (or configured)

5. **Cursor-specific repo rules:**
   - Rules that should be automatically applied by Cursor agents
   - Detection patterns, automatic behaviors
   - **Location:** `.cursor/rules/` (or configured)

### Step 2: Document Instruction

**For repository-wide agent instructions:**

1. **Check if instruction exists:**
   - Read agent instructions file (configured location)
   - Search for similar or related instructions
   - Check if it's already documented

2. **If instruction is new or needs updating:**
   - Add to appropriate section in agent instructions file
   - Use clear, directive language (MUST/SHOULD/MUST NOT)
   - Include examples if helpful
   - Reference related documents

3. **If instruction is Cursor-specific:**
   - Create or update rule file in `.cursor/rules/` (or configured location)
   - Follow existing rule file format (see other rule files)
   - Add reference to agent instructions file or central reference if needed

### Step 3: Make Available as Repo Rule

**For Cursor repo rules:**

1. **Create rule file** in `.cursor/rules/` (or configured location):
   - Use descriptive filename: `{topic}_rule.md` or `{topic}_management.md`
   - Follow format of existing rules (Purpose, Trigger Patterns, Agent Actions, Constraints)

2. **Update central reference (if exists):**
   - Add reference to new rule in appropriate section
   - Include brief description of when rule applies
   - Link to rule file

3. **Ensure rule is discoverable:**
   - Rule files in `.cursor/rules/` are automatically available to Cursor agents
   - Reference in central reference ensures visibility

**For documentation-only instructions:**

1. **Document in appropriate location:**
   - Agent instructions file for agent instructions
   - `docs/conventions/` for conventions
   - `docs/architecture/` for architectural rules
   - `docs/feature_units/standards/` for workflow standards

2. Do NOT store documentation in repo root:
   - All documentation files must be placed in appropriate subdirectories under `docs/`
   - Summary files, review files, implementation notes, and similar documentation must be placed in relevant `docs/` subdirectories
   - Only configuration files and essential project files belong in repo root

3. **Temporary agent assessment/analysis files:**
   - MUST be stored in `tmp/` directory (create if it doesn't exist)
   - Examples: assessment files, analysis documents, temporary comparisons, agent-generated summaries
   - These files are temporary and may be deleted after use
   - Do NOT store temporary assessment files in `docs/` or repo root
   - Pattern: `tmp/assessment_{topic}.md`, `tmp/analysis_{topic}.md`, etc.

3. **Reference in central reference (if exists):**
   - Add to "Required Reading" section if critical
   - Add to relevant workflow section if process-related

## Documentation Standards

### Format for Agent Instructions

When adding to agent instructions file:

```markdown
## Section Number. Clear Title

Brief description of what this instruction covers.

### Subsection. Specific Rule

1. **Rule statement** (use MUST/SHOULD/MUST NOT)
2. **Rationale or context** (why this matters)
3. **Examples** (if helpful)
4. **Related documents** (links to relevant docs)
```

### Format for Cursor Repo Rules

When creating `.cursor/rules/{topic}.md`:

```markdown
# Rule Title

**Reference:** `docs/path/to/related/doc.md` — Related documentation

## Purpose

Clear statement of what this rule ensures.

---

## Trigger Patterns

When [conditions], agents MUST [action].

---

## Agent Actions

### Step 1: [Action]

**Agent MUST:**

1. [Specific action]
2. [Specific action]

### Step 2: [Action]

[Detailed steps]

---

## Constraints

- **MUST** / **MUST NOT** statements
- **ALWAYS** / **NEVER** statements

---

## Related Documents

- `docs/path/to/doc.md` — Related documentation
```

## Automatic Availability

**Cursor agents automatically have access to:**

1. **All files in `.cursor/rules/`** — Automatically loaded as repo rules
2. **Central reference** (e.g., agent instructions file) — Central reference that links to all rules
3. **Files referenced in central reference** — Should be loaded when relevant

**To ensure instructions are available:**

1. **For automatic agent behavior:**
   - Create rule file in `.cursor/rules/` (or configured location)
   - Add reference to central reference if exists

2. **For documentation context:**
   - Add to agent instructions file
   - Reference in central reference "Required Reading" if critical

3. **For workflow processes:**
   - Document in appropriate standards directory
   - Create detection rule in `.cursor/rules/` if automatic detection needed

## Agent Actions When Instructions Are Given

### During Conversation (MANDATORY Workflow)

**When user provides instructions (especially "always" or "never" statements):**

Follow this workflow immediately, before proceeding with any other work.

1. **Detect instruction trigger:**
   - Identify if instruction matches trigger patterns (especially "always"/"never")
   - Recognize this as a permanent instruction requiring documentation

2. **Acknowledge and commit to documentation:**
   - "I'll document this instruction permanently in [location]"
   - Do NOT proceed with other work until documentation is complete

3. **Classify instruction type and determine rule scope:**
   - Apply Step 0: Meta-Rule to determine foundation vs repository-specific placement
   - Determine appropriate documentation location (see Step 1: Detect Instruction Type)
   - Determine if Cursor repo rule is needed (usually YES for "always"/"never" statements)
   - Determine if both documentation and rule file are needed

4. **Document IMMEDIATELY (same conversation):**
   - Read the target documentation file
   - Add instruction to appropriate section using proper format
   - Create or update rule file in `.cursor/rules/` if needed
   - Update central reference if new rule file created
   - Use clear, directive language (MUST/SHOULD/MUST NOT/ALWAYS/NEVER)

5. **Update downstream documentation (if applicable):**
   - Identify downstream docs that reference or depend on this instruction
   - Update downstream docs to maintain consistency
   - See `.cursor/rules/downstream_doc_updates.md` for requirements

6. **Confirm completion with details:**
   - "Instruction documented permanently in [location]"
   - "Rule created at `.cursor/rules/[name].md`" (if applicable)
   - "Downstream docs updated: [list]" (if applicable)
   - "Available to all agents via [reference]"

Do NOT:
- Skip documentation and proceed with other work
- Promise to document "later" or in a future conversation
- Document only in conversation memory without updating repo files
- Assume the instruction is temporary or context-specific

### When Reviewing Existing Instructions

**Before starting work:**

1. **Load required rules:**
   - Read central reference if exists
   - Load referenced rule files
   - Load agent instructions file

2. **Check for updates:**
   - Verify instructions are current
   - Check if new instructions need to be added

## Constraints

- Do NOT skip documenting important instructions
- Document "always" and "never" instructions immediately during the same conversation
- Do NOT defer documentation to a future conversation or session
- Do NOT document only in conversation memory - all permanent instructions must be in repo files
- Always classify instruction type before documenting
- Always update central reference when adding new rules
- Always update downstream documentation when upstream docs change
- Always use clear, directive language (MUST/SHOULD/MUST NOT/ALWAYS/NEVER)
- Do NOT duplicate instructions across multiple files without cross-references
- Always ensure instructions are discoverable via central reference or `.cursor/rules/`
- Do NOT store documentation files in repo root - all documentation must be placed in appropriate `docs/` subdirectories
- Do NOT store temporary assessment/analysis files in `docs/` - use `tmp/` directory instead









