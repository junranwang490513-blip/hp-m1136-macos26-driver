#!/bin/sh
# Fail if repository text or expanded package paths contain common private identifiers.
set -eu

ROOT=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
PACKAGE="$ROOT/dist/HP-LaserJet-M1136-macOS26-arm64.pkg"
PATTERN='(/Users/|github_pat_|ghp_|BEGIN (RSA |EC |OPENSSH )?PRIVATE KEY|api[_ -]?key|access[_ -]?token|authorization:)'

if rg -n -uuu -i -g '!**/scripts/privacy-check.sh' "$PATTERN" "$ROOT"; then
    echo "Potential private data found in repository files." >&2
    exit 1
fi

CHECK_DIR=$(mktemp -d "${TMPDIR:-/tmp}/hp-m1136-privacy.XXXXXX")
trap 'rm -rf "$CHECK_DIR"' EXIT HUP INT TERM
pkgutil --expand-full "$PACKAGE" "$CHECK_DIR/expanded"

if rg -n -uuu -i "$PATTERN" "$CHECK_DIR/expanded"; then
    echo "Potential private data found in expanded package." >&2
    exit 1
fi

if find "$CHECK_DIR/expanded/Payload" -type f -perm +111 -print0 \
    | xargs -0 strings \
    | rg -n -i "$PATTERN"; then
    echo "Potential private data found in executable strings." >&2
    exit 1
fi

echo "Privacy scan passed. Review model-specific logs manually before publishing them."
