# Example Skill: Reviewing Pull Requests

This is a complete example of a well-formed skill. Use it as a concrete reference for what the output of the skill-refiner should look like.

---

## SKILL.md

```markdown
---
name: Reviewing pull requests
description: Performs structured code reviews on GitHub pull requests. Analyzes diffs for bugs, style issues, security concerns, and test coverage gaps. Use when the user asks to review a PR, check a pull request, do a code review, or mentions a PR number or URL.
---

# Reviewing Pull Requests

## Quick Start

Review a pull request by number:

1. Fetch the PR diff: `gh pr diff <number>`
2. Read changed files to understand context
3. Analyze changes against the review checklist
4. Present findings organized by severity

## Review Workflow

### Phase 1 — Understand the Change

1. Fetch PR metadata: `gh pr view <number>`
2. Read the PR description for intent and scope
3. List changed files: `gh pr diff <number> --stat`
4. Identify the type of change: feature, bugfix, refactor, or config

### Phase 2 — Analyze the Diff

For each changed file:

1. Read the full file (not just the diff) for context
2. Check against the review checklist below
3. Note any findings with file path, line number, and severity

### Review Checklist

- [ ] **Correctness**: Does the logic match the stated intent?
- [ ] **Edge cases**: Are boundary conditions handled?
- [ ] **Error handling**: Are failures caught and reported?
- [ ] **Security**: No injection vectors, no hardcoded secrets, no unsafe deserialization
- [ ] **Tests**: Are new code paths tested? Are edge cases covered?
- [ ] **Naming**: Are variables and functions named clearly?
- [ ] **Consistency**: Does the change follow existing project patterns?

### Phase 3 — Report Findings

Organize findings by severity:

1. **Blockers** — Must fix before merge (bugs, security issues, data loss risks)
2. **Suggestions** — Should fix, but not blocking (style, naming, minor improvements)
3. **Nits** — Optional improvements (formatting, comments, minor preferences)

Format each finding as:

```
**[SEVERITY]** `file/path.ext:line` — Description of the issue
> Suggested fix or explanation
```

### Phase 4 — Summary

Provide a one-paragraph summary:
- Overall assessment (approve, request changes, or needs discussion)
- Key strengths of the change
- Primary concerns if any

## Reference Files

- **Security patterns**: See [references/security-checklist.md](references/security-checklist.md) for language-specific security checks
- **Style guides**: See [references/style-patterns.md](references/style-patterns.md) for common style rules by language

## Troubleshooting

| Problem | Cause | Fix |
|---------|-------|-----|
| Cannot fetch PR | Auth issue | Run `gh auth login` |
| Large diff timeout | PR too big | Review file-by-file with `gh pr diff <n> -- <file>` |
```

---

## What This Example Demonstrates

- **Frontmatter**: Name matches folder, third-person description with WHAT + WHEN + trigger phrases
- **Quick start**: Minimal steps for the most common case
- **Phased workflow**: Numbered phases with clear progression
- **Checklist**: Actionable items for the review process
- **Structured output format**: Defined format for findings with severity levels
- **Reference files**: Progressive disclosure — detailed checks in separate files
- **Troubleshooting table**: Common problems with causes and fixes
- **Imperative form**: All instructions use verb-first phrasing
- **Concise body**: ~150 lines, ~800 words — well under limits
