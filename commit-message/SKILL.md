---
name: commit-message
description: Generates structured, conventional commit messages from staged changes. Analyzes diffs to determine change type, scope, and impact. Use when the user asks to write a commit message, draft a commit, describe staged changes, or mentions /commit-message.
---

# Commit Message Generator

## Quick Start

Generate a commit message for currently staged changes:

1. Run `git diff --cached --stat` to list staged files
2. Run `git diff --cached` to read the full diff
3. Analyze the changes for type, scope, and intent
4. Output a formatted commit message following the Conventional Commits specification

## Workflow

### Phase 1 — Gather Context

1. Check for staged changes: `git diff --cached --stat`
   - If nothing is staged, inform the user and suggest staging files first
2. Read the full diff: `git diff --cached`
3. Read recent commit history for style reference: `git log --oneline -10`
4. Identify the repository's existing commit conventions (Conventional Commits, Angular, custom)

### Phase 2 — Classify the Change

Determine the change type from the diff:

| Type | When to Use |
|------|------------|
| `feat` | New functionality visible to users |
| `fix` | Bug fix |
| `refactor` | Code restructuring with no behavior change |
| `docs` | Documentation only |
| `test` | Adding or updating tests |
| `chore` | Build, config, dependency changes |
| `perf` | Performance improvement |
| `style` | Formatting, whitespace, semicolons |
| `ci` | CI/CD pipeline changes |

Determine the scope from the primary directory or module affected. Omit scope if changes span multiple unrelated areas.

### Phase 3 — Draft the Message

Follow this format:

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Subject line rules:**
- Imperative mood ("add feature" not "added feature")
- Lowercase first letter
- No period at the end
- Max 50 characters for subject, 72 for the full first line

**Body rules:**
- Wrap at 72 characters
- Explain *what* and *why*, not *how*
- Separate from subject with a blank line
- Omit if the subject is self-explanatory

**Footer rules:**
- Reference issues: `Closes #123`, `Fixes #456`
- Note breaking changes: `BREAKING CHANGE: <description>`
- Omit if not applicable

### Phase 4 — Present and Confirm

1. Present the draft commit message
2. If the repository uses a specific convention detected in Phase 1, note how the message follows it
3. Offer to adjust tone, scope, or detail level

## Reference Files

- **Conventional Commits spec**: See [references/conventional-commits.md](references/conventional-commits.md) for the full specification and examples
- **Common patterns**: See [references/patterns.md](references/patterns.md) for language-specific and framework-specific commit patterns

## Troubleshooting

| Problem | Cause | Fix |
|---------|-------|-----|
| No staged changes | Nothing added to index | Run `git add <files>` first |
| Diff too large | Many files changed | Suggest splitting into smaller commits |
| Unclear intent | Refactor mixed with feature | Recommend separate commits per concern |
