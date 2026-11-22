#!/usr/bin/env bash
#
# render-mermaid.sh - Convert Mermaid diagram code to ASCII using mermaid-ascii.
#
# Usage:
#   echo 'graph TD; A --> B' | ./render-mermaid.sh
#   ./render-mermaid.sh diagram.mmd
#   ./render-mermaid.sh - < diagram.mmd   (stdin)
#
# Output:
#   The rendered ASCII diagram is printed to stdout.
#   Diagnostics go to stderr; the script exits non-zero on failure.
#
# This wrapper exists so agents never have to hand-write or hand-align ASCII
# diagrams. They supply valid Mermaid and copy the script's output verbatim.

set -euo pipefail

# Make sure mermaid-ascii is findable even under a minimal shell PATH.
export PATH="$HOME/.local/bin:$PATH"

MERMAID_SRC=""

# A file argument that exists is used directly.
if [[ $# -ge 1 && "$1" != "-" && -f "$1" ]]; then
    MERMAID_SRC="$1"
else
    # Otherwise read Mermaid source from stdin into a temp file.
    TMPFILE="$(mktemp)"
    trap 'rm -f "$TMPFILE"' EXIT
    cat > "$TMPFILE"
    MERMAID_SRC="$TMPFILE"
fi

if [[ ! -s "$MERMAID_SRC" ]]; then
    echo "error: no mermaid input provided" >&2
    echo "usage: echo 'graph TD; A --> B' | $0" >&2
    echo "       $0 diagram.mmd" >&2
    exit 1
fi

if ! command -v mermaid-ascii >/dev/null 2>&1; then
    echo "error: mermaid-ascii is not on PATH (expected at ~/.local/bin/mermaid-ascii)" >&2
    exit 127
fi

mermaid-ascii -f "$MERMAID_SRC" --borderPadding 1
