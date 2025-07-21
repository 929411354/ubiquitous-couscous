#!/bin/bash
set -e

PODFILE="${BITRISE_SOURCE_DIR}/ios/Podfile"
[ -f "$PODFILE" ] || exit 1
grep -q "target 'iOSApp'" "$PODFILE" || exit 1
