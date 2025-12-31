# Project Assessment Framework

This framework orchestrates competitive and partnership analysis for any target project relative to your current repository.

## Purpose

This document provides step-by-step instructions for analyzing any project (URL or term) from both competitive and partnership perspectives, generating standardized assessment documents.

---

## When to Use

Use this framework to:
- Assess competitive positioning of a potential competitor
- Evaluate partnership opportunities with another project
- Understand market landscape relative to your repo
- Make strategic decisions about collaboration or differentiation

---

## Prerequisites

**Required Repository Structure:**

- `docs/foundation/core_identity.md` - What your repo is/is not
- `docs/foundation/product_positioning.md` - Your repo's positioning (optional but recommended)
- `docs/foundation/problem_statement.md` - Problems your repo solves (optional but recommended)
- `docs/foundation/philosophy.md` - Your repo's principles (optional but recommended)

**Required Tools:**

- Browser tools for web research
- File write capabilities for output generation

---

## Assessment Workflow

### Phase 1: Discover Current Repo Context

**Objective:** Dynamically discover your repository's identity and positioning

**Steps:**

1. **Check for foundational documents:**
   - Look for `docs/foundation/core_identity.md`
   - Look for `docs/foundation/product_positioning.md`
   - Look for `docs/foundation/problem_statement.md`
   - Look for `docs/foundation/philosophy.md`

2. **Extract repo identity:**
   - Read document titles (e.g., "Neotoma Core Identity")
   - Extract repo name from first paragraph or explicit identity statements
   - Extract core value proposition
   - Extract defensible differentiators (if documented)
   - Extract target users
   - Extract core principles

3. **Handle missing docs:**
   - If no foundational docs exist, warn user
   - Proceed with generic analysis (no repo-specific context)
   - Recommend creating foundational docs for better analysis

4. **Store context:**
   - Keep extracted context in memory for all subsequent comparisons
   - Use discovered repo name in all output

---

### Phase 2: Research Target Project

**Objective:** Gather comprehensive information about the target project

**Steps:**

1. **Navigate to target:**
   - **If URL provided:** Navigate directly using browser tools
   - **If term provided:** Search for term, navigate to top result
   - Capture page snapshot and screenshot (if accessible)

2. **Extract basic information:**
   - Project name
   - Tagline/positioning statement
   - Core value proposition
   - Key features (list 5-10 main features)
   - Pricing model (if visible)
   - Target users (if stated or inferable)

3. **Analyze technology stack:**
   - Check network requests for tech stack indicators
   - Identify frontend framework (React, Vue, Next.js, etc.)
   - Identify backend indicators (API calls, headers)
   - Note third-party integrations (analytics, payments, etc.)

4. **Document business model:**
   - Freemium vs. paid
   - Pricing tiers (if available)
   - Enterprise offering (if available)
   - Revenue model (subscription, one-time, usage-based)

5. **Identify positioning:**
   - Category (what type of product is this?)
   - Key messaging (what do they emphasize?)
   - Competitive positioning (who they compare against, if stated)
   - Differentiators (what makes them unique, if stated)

6. **Research additional context (if needed):**
   - Check for GitHub repository (if open source)
   - Check for documentation or developer docs
   - Check for blog posts or announcements
   - Check for pricing page details

---

### Phase 2.5: Determine Resource Type

**Objective:** Classify resource to determine appropriate analysis type

**Steps:**

1. **Analyze resource characteristics:**
   - **Product/Project indicators:**
     - Has features, pricing, business model
     - Target users, value proposition
     - Technology stack, architecture
     - Examples: SaaS apps, platforms, developer tools, products
   
   - **Content/Thought Leadership indicators:**
     - Article, blog post, research paper
     - Video, podcast, presentation
     - Tweet thread, analysis, commentary
     - Thought leadership, market analysis
     - Examples: Karpathy articles, research papers, industry analysis

2. **Decision:**
   - **If Product/Project:** Proceed to Phase 3 (Competitive Analysis) and Phase 4 (Partnership Analysis)
   - **If Content/Thought Leadership:** Proceed to Phase 3a (Relevance Analysis)
   - **If Hybrid:** Generate both competitive/partnership AND relevance analyses

### Phase 3: Competitive Analysis (Products/Projects Only)

**Objective:** Generate competitive assessment relative to your repo

**Steps:**

1. **Load competitive analysis template:**
   - Read `foundation/strategy/competitive_analysis_template.md`

2. **Fill out template sections:**
   - **Section 1:** Project Overview (target info from Phase 2)
   - **Section 2:** Current Repo Context (from Phase 1)
   - **Section 3:** Competitive Dynamic Summary
     - Assess: Direct / Adjacent / Complementary / Not Competitive
     - Consider: data type, use cases, users, features
   - **Section 4:** Executive Summary (one-paragraph comparison)
   - **Section 5:** Core Value Propositions (side-by-side table)
   - **Section 6:** Feature Comparison (structured table)
   - **Section 7:** Use Case Differentiation (overlap vs. divergence)
   - **Section 8:** Technical Architecture Comparison
   - **Section 9:** Market Positioning
   - **Section 10:** Competitive Advantages
   - **Section 11:** Overlap and Distinction
   - **Section 12:** Defensible Differentiation Assessment
     - Evaluate target against your repo's defensible differentiators
     - Can they pursue your differentiators? Why or why not?
   - **Section 13:** Strategic Implications
     - Risk level (competitive risk to your repo)
     - Response strategy (what should you do?)
   - **Section 14:** Conclusion (summary and recommendations)

3. **Generate output:**
   - Create filename: `[target_name]_competitive_analysis.md`
   - Fill template with all gathered information
   - Save to `docs/private/competitive/` (create directory if needed)

---

### Phase 3a: Relevance Analysis (Content/Thought Leadership)

**Objective:** Generate holistic relevance analysis for non-product resources

**Steps:**

1. **Load relevance analysis template:**
   - Read `foundation/strategy/relevance_analysis_template.md`

2. **Fill out template sections:**
   - **Section 1:** Resource Overview (resource info from Phase 2)
   - **Section 2:** Current Repo Context (from Phase 1)
   - **Section 3:** Relevance Summary (overall relevance assessment)
   - **Section 4:** Key Insights and Takeaways (3-5 main insights with implications)
   - **Section 5:** Competitive Intelligence (competitors/trends mentioned)
   - **Section 6:** Technical Insights (technical concepts relevant to repo)
   - **Section 7:** Strategic Implications (positioning, market direction, user needs)
   - **Section 8:** Validation of Architectural Choices (validates/challenges differentiators)
   - **Section 9:** Actionable Recommendations (immediate actions, strategic considerations)
   - **Section 10:** Related Resources (follow-up analysis opportunities)
   - **Section 11:** Conclusion (summary and next steps)

3. **Generate output:**
   - Create filename: `[target_name]_relevance_analysis.md`
   - Fill template with all gathered information
   - Save to `docs/private/insights/` (create directory if needed)

**Skip to Phase 5 if resource is Content/Thought Leadership.**

### Phase 4: Partnership Analysis (Products/Projects Only)

**Objective:** Generate partnership assessment relative to your repo

**Steps:**

1. **Load partnership analysis template:**
   - Read `foundation/strategy/partnership_analysis_template.md`

2. **Fill out template sections:**
   - **Section 1:** Project Overview (same as competitive analysis)
   - **Section 2:** Current Repo Context (from Phase 1)
   - **Section 3:** Partnership Dynamic Summary
     - Assess: High Value / Moderate Value / Low Value / Not Viable
     - Consider: complementary value, user overlap, integration feasibility
   - **Section 4:** Executive Summary (partnership opportunity)
   - **Section 5:** Integration Potential
     - Technical compatibility
     - API availability
     - Integration scenarios (3 specific scenarios)
   - **Section 6:** Complementary Value
     - What target brings to your repo
     - What your repo brings to target
   - **Section 7:** User Overlap
     - Shared user segments
     - Cross-user opportunities
   - **Section 8:** Technical Architecture Compatibility
   - **Section 9:** Business Model Alignment
     - Revenue model compatibility
     - Potential conflicts
   - **Section 10:** Strategic Value
     - What each party gains
     - Win-win assessment
   - **Section 11:** Integration Scenarios (detailed)
   - **Section 12:** Risks and Concerns
     - Privacy, security, business, technical risks
     - Conflicts with your repo's principles
   - **Section 13:** Partnership Recommendations
     - Type of partnership
     - Structure and next steps
   - **Section 14:** Conclusion (viability and recommendation)

3. **Generate output:**
   - Create filename: `[target_name]_partnership_analysis.md`
   - Fill template with all gathered information
   - Save to `docs/private/partnerships/` (create directory if needed)

---

### Phase 5: Output and Presentation

**Objective:** Deliver analysis to user

**Steps:**

1. **Verify output files:**
   - Confirm competitive analysis saved correctly
   - Confirm partnership analysis saved correctly

2. **Present summary to user:**
   - **Competitive Summary:**
     - Overall assessment (Direct / Adjacent / Complementary / None)
     - Competitive risk level
     - Key differentiators
     - Strategic recommendations
   - **Partnership Summary:**
     - Overall assessment (High / Moderate / Low / Not Viable)
     - Integration feasibility
     - Strategic value
     - Recommended next steps

3. **Provide file paths:**
   - Link to competitive analysis document
   - Link to partnership analysis document

---

## Output File Naming

**Competitive Analysis (Products/Projects):**
- Filename: `[target_name]_competitive_analysis.md`
- Location: `docs/private/competitive/`
- Full path: `docs/private/competitive/[target_name]_competitive_analysis.md`

**Partnership Analysis (Products/Projects):**
- Filename: `[target_name]_partnership_analysis.md`
- Location: `docs/private/partnerships/`
- Full path: `docs/private/partnerships/[target_name]_partnership_analysis.md`

**Relevance Analysis (Content/Thought Leadership):**
- Filename: `[target_name]_relevance_analysis.md`
- Location: `docs/private/insights/`
- Full path: `docs/private/insights/[target_name]_relevance_analysis.md`

**Target Name Derivation:**
- Use domain name if URL (e.g., "memorae" from "memorae.ai")
- Use sanitized term if search term (e.g., "memory_layer_productivity")
- Format: lowercase, underscores for spaces, remove special characters

---

## Error Handling

### Missing Foundational Docs

**If no foundational docs exist:**

1. Warn user: "No foundational docs found. Analysis will be generic without repo-specific context."
2. Suggest creating foundational docs for better analysis
3. Proceed with generic analysis (no current repo context section)

### Invalid URL or No Results

**If URL cannot be accessed:**

1. Attempt web search for term
2. If search fails, notify user: "Cannot access URL or find information about '[term]'"
3. Provide user option to: retry / provide alternative URL / cancel

### Missing Private Docs Submodule

**If `docs/private/` doesn't exist:**

1. Warn user: "Private docs directory not found. Output will be saved to `docs/competitive/` and `docs/partnerships/` instead."
2. Create `docs/competitive/` and `docs/partnerships/` directories
3. Recommend setting up private docs submodule (see `foundation/README.md`)

---

## Assessment Criteria Reference

### Competitive Risk Levels

- **Direct:** Target solves same problem for same users with similar approach
- **Adjacent:** Target solves related problem or targets adjacent users
- **Complementary:** Target addresses different problem or complements your solution
- **None:** No competitive overlap

### Partnership Value Levels

- **High Value:** Clear integration path, high user overlap, strong complementary value
- **Moderate Value:** Some integration potential, moderate overlap, partial complementary value
- **Low Value:** Limited integration potential, low overlap, minimal complementary value
- **Not Viable:** No integration path, conflicting principles, or no mutual benefit

### Integration Feasibility

- **High:** Public API, compatible architecture, straightforward integration
- **Medium:** Some technical compatibility, moderate integration effort required
- **Low:** Limited compatibility, significant integration effort required
- **Not Feasible:** Incompatible architectures, no API, or fundamental conflicts

---

## Templates Reference

**Competitive Analysis Template:**
- `foundation/strategy/competitive_analysis_template.md`
- Use for competitive positioning assessment

**Partnership Analysis Template:**
- `foundation/strategy/partnership_analysis_template.md`
- Use for partnership potential assessment

---

## Related Documents

- `foundation/strategy/README.md` - Strategy evaluation framework overview
- `foundation/agent-instructions/cursor-commands/analyze.md` - Analyze command definition
- Current repo foundational docs (dynamically discovered):
  - `docs/foundation/core_identity.md`
  - `docs/foundation/product_positioning.md`
  - `docs/foundation/problem_statement.md`
  - `docs/foundation/philosophy.md`

---

## Agent Instructions

### When to Use This Framework

Use this framework when executing the `analyze` command or when manually assessing a project.

### Required Steps

1. **ALWAYS load current repo context first** - Phase 1 is mandatory
2. **Research thoroughly** - Phase 2 requires comprehensive information gathering
3. **Be systematic** - Follow template structure exactly
4. **Be objective** - Base assessments on evidence, not assumptions
5. **Use discovered repo name** - All comparisons reference dynamically discovered current repo name

### Forbidden Patterns

- **Never skip Phase 1** - Current repo context is required
- **Never hardcode repo name** - Always discover dynamically
- **Never make assumptions** - Research thoroughly before assessing
- **Never skip sections** - Complete all template sections
- **Never save to wrong location** - Use `docs/private/competitive/` and `docs/private/partnerships/`

### Validation Checklist

Before completing analysis:

- [ ] Current repo context loaded from foundational docs
- [ ] Repo name extracted dynamically (not hardcoded)
- [ ] Target project researched thoroughly
- [ ] All template sections completed
- [ ] All comparisons reference current repo
- [ ] Assessment criteria applied correctly
- [ ] Output files saved to correct locations
- [ ] User presented with summary

---

## Example Workflow

**Input:** `analyze memorae.ai`

**Execution:**

1. **Phase 1: Discover Context**
   - Load `docs/foundation/core_identity.md`
   - Extract: "Neotoma" as repo name
   - Extract: "Truth Layer for AI Memory" as positioning
   - Extract: Privacy-first, Deterministic, Cross-platform as differentiators

2. **Phase 2: Research Target**
   - Navigate to https://memorae.ai
   - Capture: Features, pricing, positioning
   - Identify: "Memory layer above all apps" positioning
   - Document: Productivity/reminder focus, 200k+ users, Next.js stack

3. **Phase 3: Competitive Analysis**
   - Assessment: "Complementary, Not Competitive"
   - Risk: Low
   - Key insight: Different layers (consumer app vs. infrastructure substrate)
   - Output: `docs/private/competitive/memorae_competitive_analysis.md`

4. **Phase 4: Partnership Analysis**
   - Assessment: "Low Value"
   - Feasibility: Low (different user bases, different layers)
   - Recommendation: "Monitor, but not priority partnership"
   - Output: `docs/private/partnerships/memorae_partnership_analysis.md`

5. **Phase 5: Present Summary**
   - Show competitive summary to user
   - Show partnership summary to user
   - Provide file paths

---

## Configuration

The analyze command respects these configuration options from `foundation-config.yaml` (if available):

```yaml
strategy:
  competitive_analysis:
    enabled: true
    output_directory: "docs/private/competitive/"  # Default
  partnership_analysis:
    enabled: true
    output_directory: "docs/private/partnerships/"  # Default
```

If configuration doesn't exist, use defaults.

---

## Notes

- This framework is generic and works for any repo using foundation as submodule
- All analysis is relative to the current repo where command is executed
- Templates are designed to be thorough but flexible
- Agents should complete all sections but can adapt formatting if needed
- Output documents are stored in private docs submodule for confidentiality
- X/Twitter URLs are handled via browser tools or MCP integration (set up separately as MCP if needed)

