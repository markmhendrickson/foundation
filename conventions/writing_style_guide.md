# Writing Style Guide

**Purpose:** Defines writing style rules for all content (essays, articles, posts, documentation) to ensure authentic human voice and avoid AI-generated patterns.

**Reference:** Based on Neotoma writing style guide (`../neotoma/docs/conventions/writing_style_guide.md`)

This guide ensures consistent, professional writing that avoids AI-generated patterns and maintains clarity and precision across all content.

## Core Principles

1. **Direct and declarative**: Use simple, clear statements
2. **Active voice**: Prefer "The system processes files" over "Files are processed by the system"
3. **One idea per sentence**: Break complex thoughts into multiple sentences
4. **No AI-generated patterns**: Avoid machine-written stylistic quirks
5. **Professional tone**: Technical and precise, conversational but not casual

## Prohibited Patterns

### Generic AI Phrases

**NEVER use:**
- "Furthermore", "Moreover", "In addition"
- "leverage" → use "use" or "draw on"
- "empower" → use "enable" or "let"
- "cutting-edge" → use specific technical terms
- "revolutionary", "game-changing", "seamless" → remove marketing hype

### Corporate Speak

**NEVER overuse:**
- "solution" → use specific description
- "platform" → use "tool" or "system" where appropriate
- "ecosystem" → use only when necessary, prefer specific names

### Over-Formal Language

**NEVER use:**
- "utilize" → "use"
- "facilitate" → "enable" or "help"
- "remembrances" → "memories"
- "structural foundation" → "foundation"

### Em Dashes and En Dashes

**NEVER use:**
- Em dashes (—)
- En dashes (–)

**Use instead:**
- Commas for appositives and lists: "files, records, and entities"
- Periods to separate ideas: "The system processes files. It then validates them."
- Colons to introduce lists or explanations: "Three steps: processing, validation, and storage"
- Standard hyphens (-) for compound words and ranges: "file-based", "v0.1.0-v0.2.0"

**Examples:**
❌ "Neotoma transforms fragmented personal data—connecting people, companies, and events—into a unified memory graph."
✅ "Neotoma transforms fragmented personal data into a unified memory graph. The graph connects people, companies, and events."

❌ "The system processes files—validates them—and stores records."
✅ "The system processes files, validates them, and stores records."

### Conversational Transitions

**NEVER use:**
- "Now, let's..."
- "So, you might..."
- "Interestingly..."
- "As you can see..."
- "Keep in mind that..."

**Use instead:**
- Direct statements without transition words
- "The system..." instead of "Now, the system..."
- Start with the subject directly

### Soft Questions and Offers

**NEVER use:**
- "Would you like to...?"
- "Have you considered...?"
- "Want to try...?"
- "Need help with...?"

**Use instead:**
- Direct instructions: "Use the `store_record` action to..."
- Declarative statements: "The system supports..."

### Motivational Language

**NEVER use:**
- "Get started!"
- "Try it now!"
- "You're all set!"
- "Ready to go!"
- "Let's dive in!"

**Use instead:**
- Neutral completion statements: "Setup is complete."
- Direct next steps: "Next, configure environment variables."

### Excessive Parentheticals

**NEVER use:**
- Multiple parenthetical asides in one sentence
- Long explanatory parentheticals that break flow

**Use instead:**
- Separate sentences for explanations
- Commas for brief clarifications

**Example:**
❌ "The system processes files (which can be PDFs, images, or documents) and extracts data (using deterministic rules) before storing records (in the PostgreSQL database)."
✅ "The system processes files. Supported formats include PDFs, images, and documents. It extracts data using deterministic rules and stores records in the PostgreSQL database."

### Redundant Qualifiers

**NEVER use:**
- "very", "quite", "rather", "somewhat", "pretty"
- "incredibly", "extremely", "highly"

**Use instead:**
- Direct adjectives: "fast" not "very fast"
- Specific measurements when available: "processes 100 files/second" not "very quickly"

### Complex Sentence Structures

**NEVER use:**
- Overly nested clauses
- Multiple dependent clauses in one sentence
- Sentences over 25 words

**Use instead:**
- Simple, short sentences (15-20 words)
- One idea per sentence
- Break complex thoughts into multiple sentences

### Passive Voice

**NEVER use when active voice is clearer:**
- "it was found that..." → "I found that..."
- "Files are processed by the system" → "The system processes files"

**Use passive voice only when:**
- The actor is unknown or unimportant
- The action is more important than who performed it

## Preferred Patterns

### Punctuation

- **Commas**: For lists, appositives, and joining related clauses
- **Periods**: To end sentences and separate distinct ideas
- **Colons**: To introduce lists, explanations, or definitions
- **Semicolons**: Sparingly, only to connect closely related independent clauses
- **Hyphens**: For compound words (file-based, user-controlled) and ranges (v0.1.0-v0.2.0)

### List Formatting

**For descriptions after list items, use colons:**
✅
```
- **Structured extraction**: Deterministic field extraction from documents
- **Entity resolution**: Hash-based canonical IDs unify entities
```

❌
```
- **Structured extraction** — Deterministic field extraction from documents
- **Entity resolution** — Hash-based canonical IDs unify entities
```

### Sentence Structure

**Preferred:**
- Active voice: "The system validates input"
- Simple subject-verb-object structure
- Present tense for descriptions
- Past tense only for historical events or completed actions

**Example:**
✅ "The system processes files, validates them, and stores records."
❌ "Files are processed by the system (which validates them) and then stored in records—creating a unified memory graph."

### Authentic Human Voice

**Characteristics:**
- Conversational but professional
- First person where appropriate ("I built this", "When I use...")
- Personal insights and examples
- Natural language flow (contractions, varied sentence length)
- Direct, clear statements

## Application Checklist

When writing or editing content, verify:
- [ ] No em dashes (—) or en dashes (–)
- [ ] No conversational transitions ("Now, let's...", "So, you might...")
- [ ] No soft questions ("Would you like to...?", "Have you considered...?")
- [ ] No motivational language ("Get started!", "Try it now!")
- [ ] No excessive parentheticals
- [ ] No redundant qualifiers ("very", "quite", "rather")
- [ ] No generic AI phrases ("Furthermore", "leverage", "empower")
- [ ] No corporate speak overuse ("solution", "platform", "ecosystem")
- [ ] Simple, declarative sentences
- [ ] Active voice preferred
- [ ] One idea per sentence
- [ ] Colons used for list descriptions, not dashes
- [ ] Sentences under 25 words (prefer 15-20 words)

## Integration with Documentation Standards

This style guide complements `foundation/conventions/documentation_standards.md`. Apply both:
- **Documentation Standards**: Structure, format, required sections, diagrams
- **Writing Style Guide**: Language patterns, punctuation, tone

Always load both documents when creating or editing documentation or content.

## Related Documents

- `foundation/conventions/documentation_standards.md` - Documentation structure and format
- `foundation/conventions/code_conventions.md` - Code style and conventions
