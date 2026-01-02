# Strategy Evaluation Framework

Optional framework for product discovery and strategy validation.

## Overview

Foundation provides configuration and templates for strategy evaluation based on product discovery best practices, including:

- **Discovery Process Framework** - Cagan's four risks (Value, Usability, Feasibility, Business Viability)
- **Mom Test Methodology** - Unbiased user interview techniques
- **Hypothesis Validation** - Structured testing of assumptions
- **Go/No-Go Decision Framework** - Evidence-based decision making

All strategy tools are optional and configurable via `foundation-config.yaml`.

## Configuration

```yaml
strategy:
  discovery:
    enabled: true
    framework: "cagan"  # or "lean", "jobs-to-be-done"
    risks:
      value:
        enabled: true
        method: "interviews"
        success_threshold: 70  # % validating problem
        min_participants: 5
      usability:
        enabled: true
        method: "prototype_testing"
        success_threshold: 80
        min_participants: 5
      feasibility:
        enabled: true
        method: "poc"
      business_viability:
        enabled: true
        method: "pricing_interviews"
        success_threshold: 50
        min_participants: 5
    mom_test:
      enabled: true
      require_live_interviews: true
      commitment_signals:
        - "time_spent"
        - "money_spent"
        - "reputation_risk"
    continuous_discovery:
      enabled: true
      frequency: "weekly"
      min_participants_per_cycle: 2
```

## Cagan's Four Risks

### 1. Value Risk
"Will users buy/use this?"

**Methods:**
- User interviews (Mom Test methodology)
- Surveys
- Prototype testing
- Pre-orders/letters of intent

### 2. Usability Risk
"Can users figure out how to use this?"

**Methods:**
- Prototype testing
- Usability studies
- Think-aloud sessions
- Wizard of Oz testing

### 3. Feasibility Risk
"Can we build this?"

**Methods:**
- Proof of concept (POC)
- Technical spike
- Architectural review
- Dependency analysis

### 4. Business Viability Risk
"Will this work for the business?"

**Methods:**
- Pricing interviews
- Cost analysis
- Market sizing
- Competitive analysis

## Mom Test Methodology

Framework for conducting unbiased user interviews.

**Key Principles:**

1. **Talk about their life, not your idea**
   - Bad: "Would you use a feature that does X?"
   - Good: "How do you currently handle X?"

2. **Ask about past behavior, not future intent**
   - Bad: "Would you pay for this?"
   - Good: "How much did you spend on Y last month?"

3. **Listen for commitment signals**
   - Time: Have they spent time on this problem?
   - Money: Have they spent money trying to solve it?
   - Reputation: Have they put their reputation on the line?

**Example Questions:**

- "Tell me about the last time you dealt with [problem]..."
- "How are you currently solving this?"
- "What have you tried in the past?"
- "How much time/money does this cost you?"

## Hypothesis Validation

Structure assumptions as testable hypotheses.

**Format:**

```
We believe that [target user]
has a problem with [problem description]
because [reason/evidence].

We will know we're right when we see [success metric].
```

**Example:**

```
We believe that small business owners
have a problem with tracking financial documents
because they spend 5+ hours per week on manual data entry.

We will know we're right when 70% of interviewed owners
confirm this is a significant pain point
and are currently using spreadsheets or paper.
```

## Go/No-Go Decision Framework

Make evidence-based decisions after discovery.

**Decision Criteria:**

- **GO**: All four risks sufficiently de-risked
- **PIVOT**: Some risks validated, others not - change approach
- **NO-GO**: Critical risks not validated - stop or defer

**Thresholds (configurable):**

- Value: 70%+ validate problem
- Usability: 80%+ complete workflows
- Feasibility: POC demonstrates viability
- Business Viability: 50%+ willing to pay

## Templates

Foundation provides templates for discovery and competitive analysis:

**Product Discovery:**
- `discovery-templates/value-discovery-template.md`
- `discovery-templates/usability-discovery-template.md`
- `discovery-templates/business-viability-template.md`
- `discovery-templates/discovery-report-template.md`

**Competitive and Partnership Analysis:**
- `competitive_analysis_template.md` - Systematic competitive positioning assessment (for products/projects)
- `partnership_analysis_template.md` - Partnership potential evaluation (for products/projects)
- `relevance_analysis_template.md` - Holistic relevance analysis (for content/thought leadership)
- `project_assessment_framework.md` - Combined assessment methodology

## Usage

1. **Before building a feature:**
   - Identify risks
   - Define hypotheses
   - Plan discovery activities
   - Set success criteria

2. **During discovery:**
   - Conduct interviews (Mom Test)
   - Test prototypes
   - Build POCs
   - Validate pricing

3. **After discovery:**
   - Analyze results
   - Make go/no-go decision
   - Document findings
   - Share with team

## Continuous Discovery

Ongoing user research throughout development.

**Recommended cadence:**
- Weekly interviews (2-3 users)
- Bi-weekly synthesis
- Monthly strategy review

**Activities:**
- User interviews
- Prototype testing
- Usage analytics review
- Customer feedback analysis

## References

- "Inspired" by Marty Cagan
- "The Mom Test" by Rob Fitzpatrick
- "Continuous Discovery Habits" by Teresa Torres

## Competitive and Partnership Analysis

Foundation includes tools for analyzing projects from competitive and partnership perspectives.

### Analyze Command

**Command:** `analyze <url_or_term>`

**Purpose:** Systematically analyze any project (URL or term) from both competitive and partnership perspectives relative to your current repository.

**Examples:**
- `analyze memorae.ai`
- `analyze https://memorae.ai`
- `analyze "memory layer productivity"`

**Process:**

1. Dynamically discovers your repo's identity from foundational documents
2. Researches target project via browser tools
3. Generates competitive analysis using standardized template
4. Generates partnership analysis using standardized template
5. Saves both to `docs/private/competitive/` and `docs/private/partnerships/`

**Output:**
- `docs/private/competitive/[target_name]_competitive_analysis.md`
- `docs/private/partnerships/[target_name]_partnership_analysis.md`

**See:** `foundation/agent_instructions/cursor_commands/analyze.md` for complete documentation.

### Framework and Templates

**Project Assessment Framework:**
- `project_assessment_framework.md` - Complete methodology for analyzing projects

**Templates:**
- `competitive_analysis_template.md` - Competitive positioning assessment
- `partnership_analysis_template.md` - Partnership potential evaluation

**All analysis is:**
- Relative to your current repository
- Dynamically discovers repo context from foundational docs
- Generic and works for any repo using foundation as submodule
- Stored in private docs submodule for confidentiality

---

## Implementation

Strategy evaluation is optional. Enable in `foundation-config.yaml` for projects that need product discovery.

See Neotoma's `docs/feature_units/standards/discovery_process.md` for detailed implementation example.










