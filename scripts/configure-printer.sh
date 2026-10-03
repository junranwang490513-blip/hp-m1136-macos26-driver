#!/bin/sh
set -eu

BASE=/Library/Printers/hp-m1136
PPD="$BASE/ppd/HP-LaserJet_Pro_M1136_MFP.ppd"
QUEUE=HP_LaserJet_M1136
LOG=/var/log/hp-m1136-driver-install.log

if [ "$(id -u)" -ne 0 ]; then
    echo "Run with administrator privileges: sudo $0" >&2
    exit 1
fi

exec >>"$LOG" 2>&1
echo "[$(date)] Configuring HP LaserJet Professional M1136 MFP"

if [ "$(uname -m)" != "arm64" ]; then
    echo "This package requires an Apple Silicon Mac."
    exit 1
fi

if ! ioreg -p IOUSB -l -w 0 | grep -q 'HP LaserJet Professional M1136 MFP'; then
    echo "The M1136 is not currently visible over USB. Driver files remain installed."
    exit 2
fi

cupstestppd "$PPD" || true
launchctl kickstart -k system/org.cups.cupsd 2>/dev/null || true

DEVICE_URI=
ATTEMPT=0
while [ "$ATTEMPT" -lt 5 ] && [ -z "$DEVICE_URI" ]; do
    DEVICE_URI=$(/usr/libexec/cups/backend/usb 2>/dev/null | sed -nE '/M1136/s/^direct (usb:[^ ]+).*/\1/p' | head -1)
    [ -n "$DEVICE_URI" ] || sleep 1
    ATTEMPT=$((ATTEMPT + 1))
done

if [ -z "$DEVICE_URI" ]; then
    echo "The M1136 was visible in USB hardware, but CUPS did not return a USB URI."
    exit 3
fi

lpadmin -x "$QUEUE" 2>/dev/null || true
lpadmin -p "$QUEUE" -v "$DEVICE_URI" -P "$PPD" -E \
    -o printer-is-shared=false \
    -o printer-error-policy=retry-job \
    -o PageSize=A4 \
    -o Resolution=1200x600dpi
cupsenable "$QUEUE"
cupsaccept "$QUEUE"

echo "Queue configured: $QUEUE"
echo "Device URI: $DEVICE_URI"
exit 0
