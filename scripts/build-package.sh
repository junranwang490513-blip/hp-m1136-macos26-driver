#!/bin/sh
# Rebuild the M1136 package from a self-contained hp-legacy-mac runtime archive.
# Requirements: macOS, Xcode command-line tools, Homebrew jbigkit, pkgbuild.
set -eu

ROOT=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
RUNTIME_ARCHIVE=${1:-"$ROOT/hp-legacy-mac-bundle-arm64.tar.gz"}
OUTPUT=${2:-"$ROOT/dist/HP-LaserJet-M1136-macOS26-arm64.pkg"}
FOO2ZJS_COMMIT=80499ed5bf6caa2963ad337e37cfda78a80aab1e
EXPECTED_RUNTIME_SHA256=60c133b5a53fcce4a4364e1da53d8815cf6b14549e4eba2e88f567fdb6ee950b

if [ "$(uname -s)" != Darwin ] || [ "$(uname -m)" != arm64 ]; then
    echo "Build requires Apple Silicon macOS." >&2
    exit 1
fi

if [ ! -f "$RUNTIME_ARCHIVE" ]; then
    echo "Missing runtime archive: $RUNTIME_ARCHIVE" >&2
    echo "Obtain it from the hp-legacy-mac release or build it from that project's source." >&2
    exit 1
fi

ACTUAL_SHA256=$(shasum -a 256 "$RUNTIME_ARCHIVE" | awk '{print $1}')
if [ "$ACTUAL_SHA256" != "$EXPECTED_RUNTIME_SHA256" ]; then
    echo "Runtime archive checksum mismatch." >&2
    exit 1
fi

BUILD_DIR=$(mktemp -d "${TMPDIR:-/tmp}/hp-m1136-build.XXXXXX")
trap 'rm -rf "$BUILD_DIR"' EXIT HUP INT TERM
mkdir -p "$BUILD_DIR/unpacked" "$BUILD_DIR/root/Library/Printers"
tar -xzf "$RUNTIME_ARCHIVE" -C "$BUILD_DIR/unpacked"
mv "$BUILD_DIR/unpacked/bundle" "$BUILD_DIR/root/Library/Printers/hp-m1136"

git clone --branch main-fixes https://github.com/OpenPrinting/foo2zjs.git "$BUILD_DIR/foo2zjs"
git -C "$BUILD_DIR/foo2zjs" checkout "$FOO2ZJS_COMMIT"
JBIG_PREFIX=$(brew --prefix jbigkit)
make -C "$BUILD_DIR/foo2zjs" foo2xqx \
    CFLAGS="-O2 -Wall -I$JBIG_PREFIX/include" \
    LDFLAGS="-L$JBIG_PREFIX/lib"
cp "$BUILD_DIR/foo2zjs/foo2xqx" "$BUILD_DIR/root/Library/Printers/hp-m1136/bin/foo2xqx"

cp "$ROOT/driver/HP-LaserJet_Pro_M1136_MFP.ppd" \
    "$BUILD_DIR/root/Library/Printers/hp-m1136/ppd/"
cp "$ROOT/driver/cups-filter" "$BUILD_DIR/root/Library/Printers/hp-m1136/"
cp "$ROOT/scripts/configure-printer.sh" "$BUILD_DIR/root/Library/Printers/hp-m1136/"
chmod 755 "$BUILD_DIR/root/Library/Printers/hp-m1136/cups-filter" \
    "$BUILD_DIR/root/Library/Printers/hp-m1136/configure-printer.sh" \
    "$BUILD_DIR/root/Library/Printers/hp-m1136/bin/foo2xqx"

pkgbuild --root "$BUILD_DIR/root" \
    --scripts "$ROOT/scripts" \
    --identifier com.local.hp.m1136.macos26 \
    --version 1.1.0 \
    --install-location / \
    "$OUTPUT"

shasum -a 256 "$OUTPUT"
