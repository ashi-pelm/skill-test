# Evaluation Guide

Instructions for evaluating a draft skill using two complementary methods: rubric-based review and simulated user testing.

---

## Table of Contents

1. [Rubric-Based Review](#1-rubric-based-review)
2. [Simulated User Testing](#2-simulated-user-testing)
3. [Synthesizing Results](#3-synthesizing-results)
4. [Iteration Strategy](#4-iteration-strategy)

---

## 1. Rubric-Based Review

### Purpose

Check the draft skill against every item in `references/best-practices-checklist.md`. Produces a structured report of PASS/FAIL/PARTIAL scores with remediation notes.

### Subagent Prompt Template

Spawn a subagent with the following prompt. Replace `{{CHECKLIST}}` with the contents of `references/best-practices-checklist.md` and `{{DRAFT}}` with the full draft skill content (all files).

```
You are a skill quality reviewer. Evaluate the following skill draft against every checklist item.

## Checklist

{{CHECKLIST}}

## Draft Skill

{{DRAFT}}

## Instructions

For each checklist item, output exactly one line in this format:

RESULT | Section | Item | Explanation

Where RESULT is one of:
- PASS — the item is fully satisfied
- FAIL — the item is not satisfied (blocking — must fix)
- PARTIAL — the item is partially satisfied (should fix)

After scoring all items, output a summary section:

## Summary
- Total: X items
- PASS: X
- FAIL: X
- PARTIAL: X

## Recommended Fixes (priority order)
1. [Most critical fix]
2. [Next fix]
...

List FAIL items first, then PARTIAL items. For each, explain specifically what to change and why.
```

### Interpreting Results

- **FAIL** items are blocking — the skill should not ship without fixing these
- **PARTIAL** items are advisory — fix if possible, but not blocking
- **PASS** items need no action
- Prioritize fixes by section: Frontmatter > Body Quality > Structure > Workflows > Scripts > Testing

### Common Failures and Remediation

| Failure | Remediation |
|---------|-------------|
| Description not third-person | Rewrite to start with verb phrase: "Processes...", "Analyzes...", "Guides..." |
| Name doesn't match folder | Set `name` to match the skill's folder name exactly |
| Body too long (>500 lines) | Move detailed subsections to `references/` files |
| Word count too low (<1500) | Add missing workflow details, examples, or troubleshooting |
| No validation loop | Add a run-check-fix cycle for quality-critical operations |
| Vague description | Add specific trigger phrases and concrete capabilities |
| Multiple equal options | Pick one default approach, mention alternatives as escape hatches |

---

## 2. Simulated User Testing (With/Without Comparison)

### Purpose

Test whether the draft skill actually improves Claude's responses by comparing skill-guided output against a baseline with no skill loaded. This eliminates self-grading bias by using an independent evaluator.

### Generating Test Prompts

Create exactly 3 test prompts for the draft skill:

1. **Happy path** — A straightforward request that matches the skill's primary use case. The skill should handle this perfectly.
2. **Ambiguous request** — An underspecified or vaguely worded request that tests whether the skill guides Claude to ask clarifying questions or make reasonable assumptions.
3. **Edge case** — A request at the boundaries of the skill's scope. Tests whether the skill handles limits gracefully (e.g., unsupported input, missing dependencies, conflicting requirements).

Guidelines for test prompts:
- Use natural language a real user would actually type
- Vary the level of detail (one very specific, one vague, one unusual)
- Include at least one prompt that references a specific tool, file, or context

### User Review Gate

After generating the test prompts, present them to the user for review before proceeding to subagent execution. The user may accept, modify, replace, or add scenarios. Do not spawn any evaluation subagents until the user approves the final set of test prompts.

### Subagent Templates

For each test prompt, run 3 subagents in 2 rounds.

#### Template B1 — Baseline (No Skill)

Replace `{{USER_PROMPT}}` with the test prompt.

```
A user sends you this message:

"{{USER_PROMPT}}"

Respond to the user's request as helpfully as you can. Produce the complete response you would actually send.
```

#### Template B2 — Skill-Guided

Replace `{{SKILL_CONTENT}}` with the draft SKILL.md content and `{{USER_PROMPT}}` with the test prompt.

```
You are Claude with the following skill loaded into your context:

---BEGIN SKILL---
{{SKILL_CONTENT}}
---END SKILL---

A user sends you this message:

"{{USER_PROMPT}}"

Follow the skill instructions to respond to the user's message. Produce the complete response you would actually send.
```

#### Template B3 — Independent Evaluator

Run after B1 and B2 complete. Replace `{{USER_PROMPT}}`, `{{SKILL_CONTENT}}`, `{{BASELINE_RESPONSE}}`, and `{{SKILL_RESPONSE}}` with the respective values.

```
You are an independent evaluator comparing two responses to the same user prompt. One response was generated WITHOUT a skill (baseline), and one was generated WITH a skill loaded.

## User Prompt
"{{USER_PROMPT}}"

## Skill Content
---BEGIN SKILL---
{{SKILL_CONTENT}}
---END SKILL---

## Baseline Response (no skill)
---BEGIN BASELINE---
{{BASELINE_RESPONSE}}
---END BASELINE---

## Skill-Guided Response (with skill)
---BEGIN SKILL-GUIDED---
{{SKILL_RESPONSE}}
---END SKILL-GUIDED---

## Instructions

Rate BOTH responses on each dimension (1=poor, 5=excellent):

| Dimension | Baseline | Skill-Guided |
|-----------|----------|--------------|
| **Task completion**: Did the response fully accomplish what the user asked? | [1-5] | [1-5] |
| **Clarity**: Was the response clear and well-structured? | [1-5] | [1-5] |
| **Completeness**: Did the response cover all relevant aspects? | [1-5] | [1-5] |
| **Efficiency**: Did the response avoid unnecessary content? | [1-5] | [1-5] |

**Verdict**: Did the skill improve the response? Answer one of:
- **BETTER** — The skill-guided response is meaningfully better than the baseline
- **SAME** — No significant difference between the two responses
- **WORSE** — The skill-guided response is worse than the baseline (skill introduced problems)

**Skill improvements identified:**
- [List specific things the skill-guided response did better than baseline]

**Skill gaps identified:**
- [List specific things the baseline did better, or problems the skill introduced]

**Suggestions for the skill:**
- [List specific changes to the skill that would improve its effectiveness]
```

### Interpreting Comparative Results

- **BETTER verdict**: The skill is providing value for this prompt type
- **SAME verdict**: The skill isn't helping here — consider whether this prompt type needs coverage
- **WORSE verdict**: The skill is actively harming output — investigate the gaps identified

Flag any test where:
- The skill-guided response scored lower than baseline on 3+ dimensions
- The evaluator identified the skill introducing incorrect information
- The baseline significantly outperformed the skill-guided response

---

## 3. Synthesizing Results

After running all evaluation types, combine results into a single report:

```markdown
## Evaluation Report

### Rubric Review
- PASS: X / FAIL: X / PARTIAL: X
- Blocking issues: [list]
- Advisory issues: [list]

### Structural Validation
- PASS: X / WARN: X / FAIL: X
- Issues: [list]

### Simulated User Tests (With/Without Comparison)
| Test | Type | Baseline Avg | Skill-Guided Avg | Verdict | Key Findings |
|------|------|-------------|------------------|---------|--------------|
| 1 | Happy path | X/5 | X/5 | BETTER/SAME/WORSE | ... |
| 2 | Ambiguous | X/5 | X/5 | BETTER/SAME/WORSE | ... |
| 3 | Edge case | X/5 | X/5 | BETTER/SAME/WORSE | ... |

### Priority Fixes
1. [Fix from rubric, structural validation, or simulation — whichever is most critical]
2. [Next fix]
...
```

### Passing Criteria

The skill is ready to ship when:
- Zero FAIL items in the rubric review
- Zero FAIL items in structural validation
- All simulated test verdicts are BETTER or SAME (no WORSE)
- Skill-guided scores average 3 or above across all tests
- No test flagged the skill introducing incorrect information

---

## 4. Iteration Strategy

### When to Re-run Evaluations

- Re-run after fixing any FAIL item from the rubric
- Re-run after significant structural changes (splitting files, rewriting workflow)
- Skip re-run for minor wording fixes or PARTIAL items

### Iteration Limits

- Maximum 3 evaluation rounds
- After round 3, present the current state to the user and suggest manual testing
- Diminishing returns: most value comes from rounds 1-2

### Fix Priority Order

1. Rubric FAIL items (blocking)
2. Simulated test scores of 1-2 (skill failures)
3. Rubric PARTIAL items (advisory)
4. Simulated test scores of 3 (room for improvement)
5. Minor polish (wording, formatting)
