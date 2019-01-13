#!/bin/sh
PATCH_DIR=/tmp/health_patch
PATCH_TARGET=/usr/sony/bin/ui_menu
PATCH_WORKING="${PATCH_DIR}/ui_menu"

# Perform patching
mkdir -p "${PATCH_DIR}"
cp "${PATCH_TARGET}" "${PATCH_WORKING}"
echo -ne '\xb8\x0c\x00' | dd bs=1 of="${PATCH_WORKING}" seek=28084 conv=notrunc
echo -ne '\x06\x03' | dd bs=1 of="${PATCH_WORKING}" seek=28120 conv=notrunc
echo -ne '\x58\xbe' | dd bs=1 of="${PATCH_WORKING}" seek=28712 conv=notrunc
mount -o bind "${PATCH_WORKING}" "${PATCH_TARGET}"
