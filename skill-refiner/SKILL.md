---
name: skill-refiner
description: Guides the full lifecycle of creating a Claude Code skill from idea to tested package. Takes a skill idea, drafts SKILL.md with proper structure, evaluates via rubric review and simulated user testing using subagents, iterates with feedback, and writes the final skill package. Use when the user wants to create, build, design, write, or refine a skill, or mentions /skill-refiner.
---

# Refining Skills

Transform a skill idea into a tested, production-ready skill package through a structured five-phase workflow.

## Overview

| Phase | Action | Output |
|-------|--------|--------|
| 1 | Gather requirements | Skill specification |
| 2 | Draft the skill | Complete skill package draft |
| 3 | Evaluate via subagents | Rubric scores + simulated test results |
| 4 | Iterate with user | Refined skill package |
| 5 | Write final package | Skill files on disk |

---

## Context Management

At session start, resolve and memorize the absolute path to the skill-refiner's own directory (the directory containing this SKILL.md). Use this anchored path for all subsequent references to the skill-refiner's own files.

### File Namespace Separation

Maintain a clear separation between two file sets throughout the session:

- **Skill-refiner files** (read-only): This skill's own SKILL.md, `references/`, `scripts/`, `docs/` — always reference these using the absolute path memorized above, never relative paths that could resolve into a different skill's directory
- **Draft skill files** (read-write): All files belonging to the skill being created — these live in a separate staging or target directory, never inside the skill-refiner's own directory

When reading any reference file (e.g., `references/eval-guide.md`, `references/best-practices-checklist.md`), always resolve it against the skill-refiner's absolute path. Never write draft or final skill files into the skill-refiner's own directory.

---

## Phase 1 — Gather Requirements

Accept the user's skill idea in any form. Analyze it for gaps, then ask targeted follow-up questions.

### Required Information

Identify which of these are missing from the user's description:

1. **Core task** — What specific task does the skill automate or guide?
2. **Trigger conditions** — What would a user say or do that should invoke this skill?
3. **Dependencies** — Does it need external tools, packages, MCP servers, or APIs?
4. **Output format** — What does the final output look like? (files, text, commands, etc.)
5. **Scope boundaries** — What is explicitly out of scope?
6. **Failure modes** — What can go wrong? How should errors be handled?

### Gather Missing Information

- Batch all follow-up questions into a single message (max 5 questions)
- Use the AskUserQuestion tool to present questions with suggested options where appropriate
- Proceed when the user confirms answers or says to continue
- If the user's idea is already well-specified, skip directly to Phase 2

---

## Phase 2 — Draft the Skill

Read the following reference files before drafting:

- [references/skill-template.md](references/skill-template.md) — structural template and patterns
- [references/best-practices-checklist.md](references/best-practices-checklist.md) — constraints to follow

### Drafting Rules

**Frontmatter:**
- `name`: Must match the skill's folder name, 64 characters max. Example: "pdf-processor"
- `description`: Third person, states WHAT + WHEN + trigger phrases, 1024 characters max

**Body:**
- Write in imperative/infinitive form (verb-first instructions)
- Target 1,500-2,000 words, max 500 lines
- Only include information Claude does not already know
- Provide one default approach with escape hatches — not multiple equal options
- Use consistent terminology throughout
- No time-sensitive information, no Windows-style paths

**Progressive disclosure:**
- Keep the main workflow in SKILL.md
- Move detailed subtopics (>100 lines) to `references/` files
- Reference files are one level deep — no nested reference chains
- Name files descriptively: `api-reference.md`, not `doc1.md`

**Workflows:**
- Use numbered steps for sequential processes
- Include checklists for multi-step verification
- Add validation loops for quality-critical operations

**Scripts (if needed):**
- Handle errors explicitly — no silent failures
- Document all constants and thresholds
- List required packages
- Produce verifiable intermediate outputs

### Staging Directory

When writing draft files to disk for evaluation, place them in a dedicated staging directory — e.g., `/tmp/skill-refiner-drafts/<skill-name>/`. Never write draft files into the skill-refiner's own directory or a directory that already contains other skills. This prevents file namespace collisions that cause context loss.

### Draft Output

Do NOT show the full content of every file — this floods the conversation for larger skills. Instead, present an in-depth summary:

1. **Frontmatter** — Show the exact `name` and `description` fields (these are short and critical for review)
2. **Directory structure** — Show the full file tree of the skill package
3. **File summaries** — For each file, present:
   - **Purpose**: What this file does and why it exists
   - **Key sections**: The major headings or logical blocks and what each covers
   - **Design decisions**: Any notable choices (e.g., "uses a validation loop instead of a single pass", "splits Docker Compose into a separate reference because it exceeds 100 lines")
   - **Approximate size**: Line count and word count estimate
4. **Offer full content on request** — End with: "Let me know if you'd like to see the full content of any specific file."

This gives the user enough detail to provide meaningful feedback without waiting for walls of text.

Use a concrete example skill for reference: [references/example-skill.md](references/example-skill.md)

---

## Phase 3 — Evaluate via Subagents

Before starting this phase, confirm you are referencing the skill-refiner's own files at the absolute path memorized during Context Management. Do not confuse them with the draft skill's files.

Run three types of evaluation. Read [references/eval-guide.md](references/eval-guide.md) for detailed prompt templates and scoring criteria.

### Evaluation A — Rubric Review

Spawn a subagent using the Agent tool with the following task:

1. Load the full draft skill content (all files)
2. Load the checklist from `references/best-practices-checklist.md`
3. Score every checklist item as PASS, FAIL, or PARTIAL
4. List recommended fixes in priority order (FAIL items first)

Use the rubric subagent prompt template from `references/eval-guide.md` section 1.

### Evaluation B — Simulated User Testing (With/Without Comparison)

Test whether the skill actually improves Claude's responses by comparing skill-guided output against a baseline.

Generate 3 test prompts for the draft skill:

1. **Happy path** — straightforward request matching the primary use case
2. **Ambiguous** — underspecified request testing clarification behavior
3. **Edge case** — request at the boundaries of the skill's scope

### Scenario Review

Before running any evaluations, present the generated test prompts to the user for review. Show each prompt's full text alongside its type label (happy path / ambiguous / edge case).

Use the AskUserQuestion tool to ask the user to choose one of:

- **Accept** — proceed with these scenarios as-is
- **Modify** — specify which scenario(s) to change and provide replacement text
- **Replace** — provide entirely custom scenarios instead
- **Add** — keep the generated scenarios and add additional ones (note: each extra scenario adds 3 subagent calls to the evaluation)

Do not spawn any evaluation subagents until the user approves the final scenario set. Incorporate any user changes before proceeding.

### Run Evaluations

For each test prompt, spawn subagents in two rounds:

**Round 1 — Generate responses (parallel):**
- **Subagent B1 (Baseline):** Receives ONLY the test prompt with no skill loaded. Responds as Claude naturally would. This is the control.
- **Subagent B2 (Skill-guided):** Receives the draft skill + test prompt. Responds following the skill instructions. This is the test case.

**Round 2 — Independent evaluation (after Round 1 completes):**
- **Subagent B3 (Evaluator):** Receives both responses (B1 and B2), the skill content, and the test prompt. Independently evaluates:
  - Rate both responses on: guidance sufficiency, clarity, completeness, efficiency (1-5 each)
  - Identify specific improvements the skill enabled vs. gaps it introduced
  - Verdict: **BETTER** / **SAME** / **WORSE** — did the skill improve the response?

Use the prompt templates from `references/eval-guide.md` section 2.

### Evaluation C — Structural Validation

Run the validation script against the draft skill to catch structural issues early:

```bash
bash scripts/validate-skill.sh <draft-directory>
```

Include any FAIL or WARN items in the evaluation report alongside rubric and simulated test results.

### Parallel Execution

Launch evaluations in two rounds:

1. **Round 1:** Evaluation A (rubric) + Evaluation C (structural) + all B1 and B2 subagents — all in parallel
2. **Round 2:** After B1/B2 responses return, launch all B3 evaluator subagents

For N test prompts: (2N + 2) subagents in Round 1, then N evaluator subagents in Round 2. Total: 3N + 2 subagent calls across 2 rounds. With the default 3 test prompts, this is 8 + 3 = 11 calls.

### Fallback — Inline Evaluation

If the Agent tool is unavailable, perform all evaluations inline:

1. Review the draft against the checklist yourself, scoring each item
2. Run `validate-skill.sh` directly
3. For each test prompt, reason through how Claude would respond both with and without the skill, then compare the two approaches

---

## Phase 4 — Iterate with User

Before starting this phase, confirm you are referencing the skill-refiner's own files at the absolute path memorized during Context Management. Do not confuse them with the draft skill's files.

### Present Results

Combine evaluation results into a single report:

```
## Evaluation Report

### Rubric Review
- PASS: X | FAIL: X | PARTIAL: X
- Blocking issues: [list]
- Advisory issues: [list]

### Structural Validation
- PASS: X | WARN: X | FAIL: X
- Issues: [list]

### Simulated User Tests (With/Without Comparison)
| Test | Type | Baseline Avg | Skill-Guided Avg | Verdict | Key Findings |
|------|------|-------------|------------------|---------|--------------|
| 1 | Happy path | X/5 | X/5 | BETTER/SAME/WORSE | ... |
| 2 | Ambiguous | X/5 | X/5 | BETTER/SAME/WORSE | ... |
| 3 | Edge case | X/5 | X/5 | BETTER/SAME/WORSE | ... |

### Recommended Changes
1. [Most critical change]
2. [Next change]
...
```

### Collect Feedback

Ask the user one of:
- "Apply all recommended fixes?" — apply and show the delta
- "Apply some fixes?" — let the user select which
- "Additional feedback?" — incorporate user-specific changes
- "Approve as-is?" — skip to Phase 5

### Iteration Loop

1. Apply fixes to the draft
2. Re-run `validate-skill.sh` to catch any structural issues introduced by the fixes
3. Summarize what changed and why — do not re-render full files or show raw diffs
4. Re-run full evaluation if structural changes were made (re-enter Phase 3)
5. Skip full re-evaluation for minor wording or formatting fixes (structural validation in step 2 is always sufficient)
6. Maximum 3 evaluation rounds — after round 3, suggest manual testing with: "Test this skill on real prompts"

### Passing Criteria

The skill is ready to ship when:
- Zero FAIL items in rubric review and structural validation
- All simulated test verdicts are BETTER or SAME (no WORSE)
- Skill-guided scores average 3 or above across all tests
- The user approves the draft

---

## Phase 5 — Write Final Package

Before starting this phase, confirm you are referencing the skill-refiner's own files at the absolute path memorized during Context Management. Do not confuse them with the draft skill's files.

### Determine Target Directory

Ask the user where to write the skill package. Default: current working directory. The target directory must not be the skill-refiner's own directory. If the user's chosen path would place files alongside the skill-refiner, warn them and suggest an alternative path.

### Validate Before Writing

Run the validation script on the final draft:

```bash
bash scripts/validate-skill.sh <target-directory>
```

If validation reports FAIL items, fix them before writing. If it reports only WARNs, inform the user and proceed.

### Write Files

Create the full directory structure and write all files:

```
<target-directory>/
├── SKILL.md
├── references/
│   ├── <reference-files>.md
│   └── ...
├── scripts/
│   ├── <script-files>
│   └── ...
└── examples/
    └── <example-files>
```

### Post-Write Summary

After writing, present:

1. List of all created files with brief descriptions
2. The skill's name and description for easy copy-paste into a plugin manifest
3. Suggested next steps:
   - Test the skill by invoking it with a real prompt
   - Test the skill with real prompts
   - Create at least 3 evaluation scenarios
   - Gather feedback from team members

---

## Quick Reference

### Key Files

| File | Purpose |
|------|---------|
| [references/best-practices-checklist.md](references/best-practices-checklist.md) | Evaluation rubric |
| [references/eval-guide.md](references/eval-guide.md) | Subagent prompt templates and scoring |
| [references/skill-template.md](references/skill-template.md) | Structural template for new skills |
| [references/example-skill.md](references/example-skill.md) | Complete example skill |
| [scripts/validate-skill.sh](scripts/validate-skill.sh) | Structural validation script |
| [docs/anthropic-best-practices.md](docs/anthropic-best-practices.md) | Full upstream best practices reference |

### Frontmatter Limits

| Field | Max Length | Format |
|-------|-----------|--------|
| `name` | 64 chars | Must match folder name |
| `description` | 1024 chars | Third person: "Does X. Use when Y." |
