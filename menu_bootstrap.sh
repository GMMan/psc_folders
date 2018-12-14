#!/bin/bash

export FOLDERS_GAADATA=/tmp/folders_gaa
export FOLDERS_PCSXDATA=/tmp/folders_pcsx
export FOLDERS_SRC=/media/folders
export FOLDERS_RUN=/var/run/folders

# Shut down ui_menu
killall ui_menu
sleep 4

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
echo "sPcsxDataOriginPath=${FOLDERS_PCSXDATA}" >> /usr/sony/share/data/preferences/system.pre
echo "sPcsxExecPath=${FOLDERS_SRC}/menu_intercept.sh" >> /usr/sony/share/data/preferences/system.pre

# Set up runtime vars
mkdir -p "${FOLDERS_RUN}"
echo 0 > "${FOLDERS_RUN}/depth"

# Launch root menu
${FOLDERS_SRC}/menu_intercept.sh -cdfile /data/AppData/sony/title/FOLDER-menu_root.cue

# Wait for the boot animation...
sleep 15

# Wait for UI to exit
while [ $(ps | grep /usr/sony/bin/ui_menu | grep -v grep | wc -l) -ne 0 ]; do
    sleep 5
done

# Perform cleanup
rm -rf "${FOLDERS_GAADATA}" "${FOLDERS_PCSXDATA}" "${FOLDERS_RUN}"
umount /usr/sony/share/data/preferences

# Tell power manager to turn off system
echo off > /dev/shm/power/control
