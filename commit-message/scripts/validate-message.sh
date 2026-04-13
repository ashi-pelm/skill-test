#!/usr/bin/env bash
# validate-message.sh — Validate a commit message against Conventional Commits rules
#
# Usage: bash validate-message.sh <message-file-or-string>
#   If argument is a file, reads the file content.
#   If argument is a string, validates it directly.
#
# Exit codes:
#   0 — all checks pass
#   1 — one or more checks failed

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

PASS=0
FAIL=0
WARN=0

pass() { echo -e "  ${GREEN}PASS${NC}  $1"; ((PASS++)); }
fail() { echo -e "  ${RED}FAIL${NC}  $1"; ((FAIL++)); }
warn() { echo -e "  ${YELLOW}WARN${NC}  $1"; ((WARN++)); }

# --- Read input ---

if [ $# -lt 1 ]; then
    echo "Usage: bash validate-message.sh <message-file-or-string>"
    exit 1
fi

if [ -f "$1" ]; then
    MESSAGE=$(cat "$1")
else
    MESSAGE="$1"
fi

if [ -z "$MESSAGE" ]; then
    fail "Commit message is empty"
    exit 1
fi

HEADER=$(echo "$MESSAGE" | head -n1)
BODY=$(echo "$MESSAGE" | tail -n +3)

echo "Validating commit message..."
echo "Header: $HEADER"
echo ""

# --- Header checks ---

# Check type prefix
VALID_TYPES="feat|fix|docs|style|refactor|perf|test|chore|ci|revert"
if echo "$HEADER" | grep -qE "^(${VALID_TYPES})(\(.+\))?(!)?: .+"; then
    pass "Header has valid type prefix"
else
    fail "Header must start with a valid type (feat, fix, docs, etc.)"
fi

# Check header length
HEADER_LEN=${#HEADER}
if [ "$HEADER_LEN" -le 72 ]; then
    pass "Header length ($HEADER_LEN chars) within 72-char limit"
else
    fail "Header length ($HEADER_LEN chars) exceeds 72-char limit"
fi

# Check subject length (after type/scope prefix)
SUBJECT=$(echo "$HEADER" | sed -E "s/^(${VALID_TYPES})(\(.+\))?(!)?: //")
SUBJECT_LEN=${#SUBJECT}
if [ "$SUBJECT_LEN" -le 50 ]; then
    pass "Subject length ($SUBJECT_LEN chars) within 50-char limit"
else
    warn "Subject length ($SUBJECT_LEN chars) exceeds 50-char soft limit"
fi

# Check imperative mood (basic heuristic: no -ed, -ing suffix on first word)
FIRST_WORD=$(echo "$SUBJECT" | awk '{print $1}')
if echo "$FIRST_WORD" | grep -qE "(ed|ing)$"; then
    warn "Subject may not be in imperative mood ('$FIRST_WORD' — use 'add' not 'added')"
else
    pass "Subject appears to use imperative mood"
fi

# Check for lowercase first letter in subject
FIRST_CHAR=$(echo "$SUBJECT" | cut -c1)
if echo "$FIRST_CHAR" | grep -qE "^[a-z]"; then
    pass "Subject starts with lowercase letter"
else
    warn "Subject should start with a lowercase letter"
fi

# Check for trailing period
if echo "$HEADER" | grep -qE "\.$"; then
    fail "Header should not end with a period"
else
    pass "Header has no trailing period"
fi

# --- Body checks ---

if [ -n "$BODY" ]; then
    # Check blank line between header and body
    SECOND_LINE=$(echo "$MESSAGE" | sed -n '2p')
    if [ -z "$SECOND_LINE" ]; then
        pass "Blank line between header and body"
    else
        fail "Missing blank line between header and body"
    fi

    # Check body line length
    LONG_LINES=$(echo "$BODY" | awk 'length > 72 {print NR": "$0}')
    if [ -z "$LONG_LINES" ]; then
        pass "All body lines within 72-char limit"
    else
        warn "Some body lines exceed 72 chars (soft limit)"
    fi
fi

# --- Summary ---

echo ""
echo "Results: ${PASS} passed, ${FAIL} failed, ${WARN} warnings"

if [ "$FAIL" -gt 0 ]; then
    exit 1
else
    exit 0
fi
