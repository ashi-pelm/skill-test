# Common Commit Patterns

Patterns and conventions for commit messages in specific contexts.

---

## Table of Contents

1. [Monorepo Patterns](#monorepo-patterns)
2. [Frontend Patterns](#frontend-patterns)
3. [Backend Patterns](#backend-patterns)
4. [Database Patterns](#database-patterns)
5. [DevOps Patterns](#devops-patterns)
6. [Multi-change Commits](#multi-change-commits)

---

## Monorepo Patterns

In monorepos, use the package or workspace name as the scope:

```
feat(web): add dark mode toggle
fix(api): handle null response from payment provider
chore(shared-utils): bump typescript to 5.3
test(mobile): add integration tests for onboarding flow
```

For changes spanning multiple packages:

```
refactor: migrate from CommonJS to ESM across all packages
```

---

## Frontend Patterns

### Component changes
```
feat(Button): add loading state variant
fix(Modal): prevent scroll lock on iOS Safari
refactor(NavBar): convert class component to hooks
```

### Styling
```
style(theme): update color tokens for accessibility
fix(layout): correct grid alignment on tablet breakpoint
```

### State management
```
feat(store): add optimistic updates for cart actions
fix(auth-slice): clear stale tokens on logout
```

---

## Backend Patterns

### API changes
```
feat(api): add pagination to /users endpoint
fix(api): return 404 instead of 500 for missing resources
perf(api): add response caching for product listings
```

### Service layer
```
feat(notifications): add email digest scheduling
fix(payments): retry failed webhook deliveries
refactor(auth): extract JWT validation into middleware
```

---

## Database Patterns

### Migrations
```
feat(db): add indexes for user search queries
fix(db): correct foreign key constraint on orders table
chore(db): add migration for analytics events table
```

### Schema changes
```
feat(schema): add soft delete columns to all entities
fix(schema): increase varchar limit on address fields

BREAKING CHANGE: Requires running migration 0042 before deploying
```

---

## DevOps Patterns

### CI/CD
```
ci: add parallel test execution to GitHub Actions
ci(deploy): fix staging environment variable injection
ci: cache node_modules between pipeline runs
```

### Infrastructure
```
chore(docker): optimize image size with multi-stage build
chore(terraform): add auto-scaling policy for API instances
fix(nginx): correct proxy headers for WebSocket connections
```

---

## Multi-change Commits

When a commit necessarily touches multiple concerns, lead with the primary change:

```
feat(checkout): add Apple Pay support

Also update the payment types enum and add corresponding test
fixtures for the new payment method.
```

If the changes are truly independent, prefer splitting into separate commits. A good test: can you describe the commit in one sentence without using "and"?
