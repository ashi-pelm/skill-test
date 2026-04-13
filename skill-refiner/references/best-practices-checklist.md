# Skill Best Practices Checklist

Use this checklist to evaluate a skill draft. Score each item as **PASS**, **FAIL**, or **PARTIAL**.

For detailed rationale on any item, see `docs/anthropic-best-practices.md`.

---

## Table of Contents

1. [Frontmatter Quality](#1-frontmatter-quality)
2. [Body Quality](#2-body-quality)
3. [Progressive Disclosure and Structure](#3-progressive-disclosure-and-structure)
4. [Workflows and Feedback Loops](#4-workflows-and-feedback-loops)
5. [Scripts and Code](#5-scripts-and-code-if-applicable)
6. [Testing Readiness](#6-testing-readiness)

---

## 1. Frontmatter Quality

- [ ] **Name matches folder**: `name` matches the skill's folder name exactly
- [ ] **Name length**: `name` is 64 characters or fewer
- [ ] **Third-person description**: `description` uses third person — no "I", "you", or "your"
- [ ] **WHAT clause**: `description` states what the skill does (the capability)
- [ ] **WHEN clause**: `description` states when to use it (trigger conditions and contexts)
- [ ] **Trigger terms**: `description` includes specific key terms and phrases users would say
- [ ] **Description length**: `description` is 1024 characters or fewer

## 2. Body Quality

- [ ] **Imperative form**: Body instructions use imperative/infinitive form (verb-first), not second person ("you should")
- [ ] **Line count**: Body is under 500 lines
- [ ] **Word count**: Body is between 1,500 and 3,000 words (ideal: 1,500-2,000)
- [ ] **No time-sensitive info**: No references to dates, versions, or current state that will become stale
- [ ] **Consistent terminology**: Same concept uses the same term throughout — no synonyms for the same thing
- [ ] **No Windows paths**: All file paths use forward slashes only
- [ ] **Default path with escape hatches**: Provides one recommended approach, not multiple equal options
- [ ] **Concrete examples**: Examples are specific and actionable, not abstract or hypothetical
- [ ] **Concise content**: Only includes information Claude does not already know

## 3. Progressive Disclosure and Structure

- [ ] **One-level references**: Reference files are one level deep from SKILL.md — no nested reference chains
- [ ] **Content split appropriately**: Detailed content (>100 lines on a subtopic) is moved to reference files
- [ ] **Reference TOC**: Reference files over 100 lines include a table of contents
- [ ] **Descriptive file names**: Files are named by content, not generically (e.g., `eval-guide.md` not `doc1.md`)
- [ ] **Logical organization**: Content is organized by domain or feature, not chronologically

## 4. Workflows and Feedback Loops

- [ ] **Step-by-step workflows**: Complex tasks have explicit numbered or ordered steps
- [ ] **Checklists**: Multi-step processes provide checklists for tracking progress
- [ ] **Validation loops**: Quality-critical operations include a run-check-fix cycle
- [ ] **Clear decision points**: Conditional workflows have explicit branching criteria

## 5. Scripts and Code (if applicable)

- [ ] **Explicit error handling**: Scripts handle errors directly — no bare exceptions, no silent failures
- [ ] **No magic numbers**: All constants and thresholds are documented or named
- [ ] **Dependencies listed**: Required packages and tools are listed explicitly
- [ ] **Clear intent**: Each script's purpose (execute vs. reference) is stated
- [ ] **Verifiable outputs**: Scripts produce intermediate outputs that can be inspected

## 6. Testing Readiness

- [ ] **Three evaluations minimum**: At least 3 evaluation scenarios are definable for the skill
- [ ] **Coverage**: Scenarios cover happy path, edge cases, and boundary conditions
- [ ] **Model compatibility**: Skill is testable across different models
- [ ] **Real usage scenarios**: Test cases reflect how a real user would invoke the skill
