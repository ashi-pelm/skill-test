#!/usr/bin/env bash
# validate-skill.sh — Validate a skill package against best practices.
# Usage: bash scripts/validate-skill.sh <path-to-skill-directory>
#
# Checks frontmatter, body metrics, path conventions, and reference integrity.
# Exits 0 if all checks pass, 1 if any FAIL found, 2 if only WARNs.

set -euo pipefail

# --- Constants ---
MAX_NAME_LENGTH=64
MAX_DESC_LENGTH=1024
MAX_BODY_LINES=500
MIN_WORD_COUNT=1500
MAX_WORD_COUNT=3000

# --- Colors ---
RED='\033[0;31m'
YELLOW='\033[0;33m'
GREEN='\033[0;32m'
NC='\033[0m'

# --- Counters ---
PASS_COUNT=0
WARN_COUNT=0
FAIL_COUNT=0

# --- Functions ---
pass_check() {
    echo -e "${GREEN}PASS${NC} | $1"
    PASS_COUNT=$((PASS_COUNT + 1))
}

warn_check() {
    echo -e "${YELLOW}WARN${NC} | $1"
    WARN_COUNT=$((WARN_COUNT + 1))
}

fail_check() {
    echo -e "${RED}FAIL${NC} | $1"
    FAIL_COUNT=$((FAIL_COUNT + 1))
}

# --- Input validation ---
if [ $# -lt 1 ]; then
    echo "Usage: bash scripts/validate-skill.sh <path-to-skill-directory>"
    exit 1
fi

SKILL_DIR="$1"
SKILL_FILE="$SKILL_DIR/SKILL.md"

if [ ! -f "$SKILL_FILE" ]; then
    fail_check "SKILL.md not found at $SKILL_FILE"
    echo ""
    echo "Summary: 0 PASS, 0 WARN, 1 FAIL"
    exit 1
fi

echo "Validating skill at: $SKILL_DIR"
echo "============================================"

# --- Extract frontmatter ---
# Frontmatter is between the first two '---' lines
FRONTMATTER=$(awk '/^---$/{n++; next} n==1{print} n>=2{exit}' "$SKILL_FILE")

if [ -z "$FRONTMATTER" ]; then
    fail_check "No YAML frontmatter found (expected --- delimiters)"
    echo ""
    echo "Summary: $PASS_COUNT PASS, $WARN_COUNT WARN, $FAIL_COUNT FAIL"
    exit 1
fi

# --- Extract name ---
NAME=$(echo "$FRONTMATTER" | grep -E '^name:' | sed 's/^name:\s*//' | sed 's/^["'"'"']//;s/["'"'"']$//')

if [ -z "$NAME" ]; then
    fail_check "Frontmatter: 'name' field is missing"
else
    NAME_LENGTH=${#NAME}
    if [ "$NAME_LENGTH" -le "$MAX_NAME_LENGTH" ]; then
        pass_check "Name length: $NAME_LENGTH chars (max $MAX_NAME_LENGTH)"
    else
        fail_check "Name length: $NAME_LENGTH chars exceeds max $MAX_NAME_LENGTH"
    fi

    # Check that name matches the folder name
    FOLDER_NAME=$(basename "$(cd "$SKILL_DIR" && pwd)")
    if [ "$NAME" = "$FOLDER_NAME" ]; then
        pass_check "Name format: matches folder name ('$NAME')"
    else
        fail_check "Name format: name '$NAME' does not match folder name '$FOLDER_NAME'"
    fi
fi

# --- Extract description ---
# Handle multi-line description (may span multiple lines after 'description:')
DESC=$(echo "$FRONTMATTER" | awk '/^description:/{sub(/^description:\s*/, ""); p=1} p{print} /^[a-z]+:/ && !/^description:/{p=0}' | tr '\n' ' ' | sed 's/  */ /g;s/^ //;s/ $//')

if [ -z "$DESC" ]; then
    fail_check "Frontmatter: 'description' field is missing"
else
    DESC_LENGTH=${#DESC}
    if [ "$DESC_LENGTH" -le "$MAX_DESC_LENGTH" ]; then
        pass_check "Description length: $DESC_LENGTH chars (max $MAX_DESC_LENGTH)"
    else
        fail_check "Description length: $DESC_LENGTH chars exceeds max $MAX_DESC_LENGTH"
    fi

    # Check third-person (should not start sentences with "I " or "You ")
    if echo "$DESC" | grep -qiE '(^|\. )(I |You |Your )'; then
        warn_check "Description format: appears to use first/second person — use third person"
    else
        pass_check "Description format: third-person voice"
    fi

    # Check for trigger terms (should contain "use when" or "when the user")
    if echo "$DESC" | grep -qiE '(use when|when the user|when working|when .* asks|when .* wants|when .* mentions)'; then
        pass_check "Description triggers: WHEN clause detected"
    else
        warn_check "Description triggers: no WHEN clause found — add 'Use when...' trigger conditions"
    fi
fi

# --- Body metrics ---
# Body is everything after the second '---'
BODY=$(awk 'BEGIN{n=0} /^---$/{n++; next} n>=2{print}' "$SKILL_FILE")
BODY_LINES=$(echo "$BODY" | wc -l)
BODY_WORDS=$(echo "$BODY" | wc -w)

if [ "$BODY_LINES" -le "$MAX_BODY_LINES" ]; then
    pass_check "Body line count: $BODY_LINES lines (max $MAX_BODY_LINES)"
else
    fail_check "Body line count: $BODY_LINES lines exceeds max $MAX_BODY_LINES — split content into reference files"
fi

if [ "$BODY_WORDS" -ge "$MIN_WORD_COUNT" ] && [ "$BODY_WORDS" -le "$MAX_WORD_COUNT" ]; then
    pass_check "Body word count: $BODY_WORDS words (target $MIN_WORD_COUNT-$MAX_WORD_COUNT)"
elif [ "$BODY_WORDS" -lt "$MIN_WORD_COUNT" ]; then
    warn_check "Body word count: $BODY_WORDS words is below minimum $MIN_WORD_COUNT — consider adding detail"
else
    warn_check "Body word count: $BODY_WORDS words exceeds target $MAX_WORD_COUNT — consider moving content to references"
fi

# --- Path conventions ---
if grep -qE '\\\\' "$SKILL_FILE"; then
    fail_check "Path convention: Windows-style backslash paths found in SKILL.md"
else
    pass_check "Path convention: no backslash paths detected"
fi

# --- Reference integrity ---
# Find all markdown links in SKILL.md that point to local files (not URLs)
LINKS=$(grep -oE '\[([^]]*)\]\(([^)]+)\)' "$SKILL_FILE" | grep -oE '\(([^)]+)\)' | tr -d '()' | grep -vE '^https?://' | grep -vE '^#' || true)

if [ -n "$LINKS" ]; then
    BROKEN=0
    while IFS= read -r link; do
        TARGET="$SKILL_DIR/$link"
        if [ ! -e "$TARGET" ]; then
            fail_check "Broken reference: '$link' does not exist at $TARGET"
            BROKEN=$((BROKEN + 1))
        fi
    done <<< "$LINKS"

    if [ "$BROKEN" -eq 0 ]; then
        pass_check "Reference integrity: all local links resolve to existing files"
    fi
else
    pass_check "Reference integrity: no local file links to check (or all links are external/anchors)"
fi

# --- Reference depth check ---
# Check that reference files do not themselves link to other reference files
REF_DIR="$SKILL_DIR/references"
if [ -d "$REF_DIR" ]; then
    NESTED=0
    for ref_file in "$REF_DIR"/*.md; do
        [ -f "$ref_file" ] || continue
        # Strip fenced code blocks before checking for reference links.
        # This avoids false positives from example/template content inside ``` blocks.
        STRIPPED=$(awk '/^```/{skip=!skip; next} !skip{print}' "$ref_file")
        if echo "$STRIPPED" | grep -qoE '\[([^]]*)\]\(references/' 2>/dev/null; then
            fail_check "Nested reference: $(basename "$ref_file") links to another reference file — keep references one level deep"
            NESTED=$((NESTED + 1))
        fi
    done
    if [ "$NESTED" -eq 0 ]; then
        pass_check "Reference depth: no nested reference chains found"
    fi
fi

# --- Summary ---
echo ""
echo "============================================"
echo -e "Summary: ${GREEN}$PASS_COUNT PASS${NC}, ${YELLOW}$WARN_COUNT WARN${NC}, ${RED}$FAIL_COUNT FAIL${NC}"

if [ "$FAIL_COUNT" -gt 0 ]; then
    echo -e "${RED}Result: FAIL — fix blocking issues before shipping${NC}"
    exit 1
elif [ "$WARN_COUNT" -gt 0 ]; then
    echo -e "${YELLOW}Result: WARN — consider addressing advisory issues${NC}"
    exit 2
else
    echo -e "${GREEN}Result: PASS — skill meets all checks${NC}"
    exit 0
fi
