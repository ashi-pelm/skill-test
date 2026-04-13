# Skill Template

An annotated template for writing a well-formed SKILL.md with supporting files.

---

## Table of Contents

1. [Frontmatter](#frontmatter)
2. [Body Structure](#body-structure)
3. [When to Split into References](#when-to-split-into-references)
4. [Workflow Pattern](#workflow-pattern)
5. [Feedback Loop Pattern](#feedback-loop-pattern)
6. [Directory Layout](#directory-layout)

---

## Frontmatter

```yaml
---
# name: Must match the skill's folder name. 64 characters max.
# Examples: "pdf-processor", "pr-reviewer", "db-manager"
name: <folder-name>

# description: Third person. State WHAT it does + WHEN to use it.
# Include specific trigger phrases users would say. 1024 characters max.
# Pattern: "<What it does>. Use when <trigger conditions>."
description: <Third-person description with WHAT + WHEN + trigger terms>
---
```

## Body Structure

Write the body in imperative/infinitive form (verb-first instructions). Target 1,500-2,000 words, under 500 lines.

```markdown
# <Skill Name>

## Quick Start

<!-- Minimal instructions to accomplish the most common task. -->
<!-- Include a concrete code example or command if applicable. -->

## Workflow

<!-- Step-by-step process for the primary use case. -->
<!-- Use numbered steps for sequential operations. -->
<!-- Use checklists for multi-step verification. -->

1. Step one — do this first
2. Step two — then this
3. Step three — validate the result

## Reference Files

<!-- Point to bundled reference files for detailed content. -->
<!-- Only reference files one level deep — no chains. -->

- **Detailed guide**: See [references/guide-name.md](references/guide-name.md) for full details
- **API reference**: See [references/api.md](references/api.md) for method signatures

## Utility Scripts

<!-- List any bundled scripts and their purpose. -->

- `scripts/validate.sh` — validate output before finalizing
- `scripts/process.py` — automate the main transformation

## Troubleshooting

<!-- Common failure modes and how to handle them. -->
<!-- Keep this section short — move long debugging guides to references. -->

| Problem | Cause | Fix |
|---------|-------|-----|
| Error X | Missing dependency | Run `pip install dep` |
| Empty output | Wrong input format | Check file encoding |
```

## When to Split into References

Move content to a `references/` file when:

- A subtopic exceeds ~100 lines of detail
- Content is only needed for specific sub-tasks (progressive disclosure)
- Multiple distinct domains exist (organize one file per domain)

Keep in SKILL.md when:

- Content is always needed regardless of the user's specific request
- The section is under 50 lines
- Splitting would break the flow of a critical workflow

Reference files should:

- Have a table of contents if over 100 lines
- Be named descriptively (`eval-guide.md`, not `ref1.md`)
- Be one level deep from SKILL.md — never reference other reference files

## Workflow Pattern

Use numbered steps for sequential processes. Include validation checkpoints.

```markdown
## Workflow

1. **Gather inputs** — collect required information from the user
   - [ ] Input A confirmed
   - [ ] Input B confirmed
2. **Process** — transform inputs into outputs
   - Run `scripts/process.py <input>`
   - Verify intermediate output before continuing
3. **Validate** — check the result meets requirements
   - Run `scripts/validate.sh <output>`
   - Fix any reported issues
4. **Deliver** — present the result to the user
```

## Feedback Loop Pattern

Use when operations need iterative quality improvement.

```markdown
## Validation Loop

Repeat until all checks pass (max 3 iterations):

1. Run validation: `scripts/validate.sh <target>`
2. Review results — fix any FAIL or PARTIAL items
3. Re-run validation to confirm fixes
4. If all checks pass, proceed to next phase
5. If 3 iterations exhausted, present current state to user for manual review
```

## Directory Layout

```
skill-name/
├── SKILL.md                # Required — metadata + main instructions
├── references/             # Optional — detailed docs loaded on demand
│   ├── guide-name.md       # Descriptive name, one level deep
│   └── api-reference.md
├── examples/               # Optional — working code examples
│   └── sample-usage.sh
├── scripts/                # Optional — executable utilities
│   ├── validate.sh         # Validation script
│   └── process.py          # Processing script
└── docs/                   # Optional — upstream or external documentation
    └── external-ref.md
```
