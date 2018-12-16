#!/bin/sh
PATCH_DIR=/tmp/health_patch
PATCH_BIN="${PATCH_DIR}/patch.bin"
PATCH_TARGET=/usr/sony/bin/ui_menu
PATCH_WORKING="${PATCH_DIR}/ui_menu"

# Perform patching
mkdir -p "${PATCH_DIR}"
cp "${PATCH_TARGET}" "${PATCH_WORKING}"
echo -n -e '\xb8\x0c\x00\x06\x03\x58\xbe' > "${PATCH_BIN}"
dd bs=1 if="${PATCH_BIN}" skip=0 of="${PATCH_WORKING}" seek=28084 count=3 conv=notrunc
dd bs=1 if="${PATCH_BIN}" skip=3 of="${PATCH_WORKING}" seek=28120 count=2 conv=notrunc
dd bs=1 if="${PATCH_BIN}" skip=5 of="${PATCH_WORKING}" seek=28712 count=2 conv=notrunc
rm "${PATCH_BIN}"
mount -o bind "${PATCH_WORKING}" "${PATCH_TARGET}"
