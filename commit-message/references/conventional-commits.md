# Conventional Commits Specification

A reference for the Conventional Commits 1.0.0 specification and its application.

---

## Table of Contents

1. [Format](#format)
2. [Type Definitions](#type-definitions)
3. [Scope Guidelines](#scope-guidelines)
4. [Breaking Changes](#breaking-changes)
5. [Examples](#examples)

---

## Format

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

The commit message consists of a **header**, **body**, and **footer**, separated by blank lines.

### Header

The header is mandatory and has the format:

```
<type>(<scope>): <subject>
```

- **type**: Required. Must be one of the defined types below.
- **scope**: Optional. A noun describing the section of the codebase (e.g., `auth`, `api`, `parser`).
- **subject**: Required. A short summary in imperative mood.

### Body

The body is optional. Use it to explain the motivation for the change. Wrap lines at 72 characters.

### Footer

The footer is optional. Use it for:
- Issue references: `Closes #123`
- Breaking change notices: `BREAKING CHANGE: description`
- Co-author credits: `Co-authored-by: Name <email>`

---

## Type Definitions

| Type | Purpose | Appears in Changelog |
|------|---------|---------------------|
| `feat` | A new feature | Yes |
| `fix` | A bug fix | Yes |
| `docs` | Documentation changes only | No |
| `style` | Formatting, missing semicolons, etc. | No |
| `refactor` | Code change that neither fixes a bug nor adds a feature | No |
| `perf` | Performance improvement | No |
| `test` | Adding or correcting tests | No |
| `chore` | Maintenance tasks (build, CI, deps) | No |
| `ci` | CI/CD configuration changes | No |
| `revert` | Reverts a previous commit | Yes |

---

## Scope Guidelines

Choose a scope that identifies the module, component, or area affected:

- **By directory**: `feat(auth):`, `fix(api):`
- **By feature**: `feat(search):`, `fix(checkout):`
- **By layer**: `refactor(db):`, `test(middleware):`

Omit the scope when changes are broad or touch many areas.

---

## Breaking Changes

A breaking change must be indicated in one of two ways:

1. **Footer notation** (preferred):
   ```
   feat(api): change authentication endpoint

   BREAKING CHANGE: /auth/login now requires a JSON body instead of form data
   ```

2. **Type suffix**:
   ```
   feat(api)!: change authentication endpoint
   ```

Both methods are valid per the spec. Use footer notation when the breaking change needs a detailed explanation.

---

## Examples

### Simple feature
```
feat(search): add fuzzy matching to search bar
```

### Bug fix with body
```
fix(auth): prevent session fixation on login

Regenerate session ID after successful authentication to prevent
session fixation attacks. The previous implementation reused the
pre-auth session ID.

Closes #892
```

### Refactor
```
refactor(parser): extract token validation into helper
```

### Breaking change
```
feat(api)!: require API key for all endpoints

BREAKING CHANGE: All API endpoints now require an X-API-Key header.
Previously, read-only endpoints were publicly accessible.

Migration: Generate an API key in the dashboard and include it in
all requests as the X-API-Key header.
```

### Chore with scope
```
chore(deps): upgrade lodash to 4.17.21
```

### Multi-paragraph body
```
fix(upload): handle timeout on large file uploads

The upload handler was using the default 30-second timeout, causing
failures for files over 100MB on slower connections.

Increase the timeout to 5 minutes for uploads and add a progress
callback so the client can track upload status.

Fixes #1045
```
