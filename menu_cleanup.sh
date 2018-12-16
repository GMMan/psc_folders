#!/bin/bash
FOLDERS_RUN=/var/run/folders
FOLDERS_GAADATA=$(cat "${FOLDERS_RUN}/gaadata")
FOLDERS_PCSXDATA=$(cat "${FOLDERS_RUN}/pcsxdata")

# Shut down ui_menu
touch /data/power/prepare_suspend
sleep 1
rm /data/power/prepare_suspend

# Perform cleanup
umount /usr/sony/share/data/preferences
umount /gaadata/databases
rm -rf "${FOLDERS_GAADATA}" "${FOLDERS_PCSXDATA}" "${FOLDERS_RUN}"

# Tell power manager to turn off system
echo off > /dev/shm/power/control
