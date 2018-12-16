#!/bin/bash
export FOLDERS_GAADATA=/tmp/folders_gaa
export FOLDERS_PCSXDATA=/tmp/folders_pcsx
export FOLDERS_SRC=/media/folders
export FOLDERS_RUN=/var/run/folders

# Wait for splash to finish
# 1. Make sure sonyapp is running
while [ $(ps | grep sonyapp | grep -v grep | wc -l) -eq 0 ]; do
    sleep 1
done
# 2. Wait until ui_menu is running
while [ $(ps | grep /usr/sony/bin/ui_menu | grep -v grep | wc -l) -eq 0 ]; do
    sleep 1
done

# Shut down ui_menu
touch /data/power/prepare_suspend
sleep 1
rm /data/power/prepare_suspend

# Create temp dir
rm -rf "${FOLDERS_GAADATA}" "${FOLDERS_PCSXDATA}"
mkdir -p "${FOLDERS_GAADATA}" "${FOLDERS_PCSXDATA}"

# Copy original prefs out first
cp /usr/sony/share/data/preferences/system.pre /tmp/system.pre
# Create override FS on system prefs dir
umount /usr/sony/share/data/preferences
mount -t tmpfs -o size=1M tmpfs /usr/sony/share/data/preferences
# Move system prefs to tmpfs and override origin paths
mv /tmp/system.pre /usr/sony/share/data/preferences/system.pre
echo "sPcsxGameImageOriginPath=${FOLDERS_GAADATA}/" >> /usr/sony/share/data/preferences/system.pre
echo "sPcsxDataOriginPath=${FOLDERS_PCSXDATA}/" >> /usr/sony/share/data/preferences/system.pre
echo "sPcsxExecPath=${FOLDERS_SRC}/menu_intercept.sh" >> /usr/sony/share/data/preferences/system.pre

# Set up runtime vars
mkdir -p "${FOLDERS_RUN}"
echo 0 > "${FOLDERS_RUN}/depth"

# Write vars to /var/run just to make sure they're available in the future
echo "${FOLDERS_GAADATA}" > "${FOLDERS_RUN}/gaadata"
echo "${FOLDERS_PCSXDATA}" > "${FOLDERS_RUN}/pcsxdata"
echo "${FOLDERS_SRC}" > "${FOLDERS_RUN}/src"

# Apply health patch
"${FOLDERS_SRC}/health_patch.sh"

# Launch root menu
${FOLDERS_SRC}/menu_intercept.sh -cdfile /data/AppData/sony/title/FOLDER-menu_root.cue

# Keep script running until poweroff so USB drive is not unmounted
while [ -d "${FOLDERS_RUN}" ]; do
    sleep 1
done
