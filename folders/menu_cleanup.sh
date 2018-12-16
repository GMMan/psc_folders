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
umount /usr/sony/bin/ui_menu
rm -rf "${FOLDERS_GAADATA}" "${FOLDERS_PCSXDATA}" "${FOLDERS_RUN}" /tmp/health_patch

# Let's not shut down for now, there's an issue getting the USB to run again on resume

# # Wait a bit so initial script has time to exit and the drive unmount
# sleep 2

# # Tell power manager to turn off system
# echo off > /dev/shm/power/control

# Restart Weston, the UI seems to get stuck
systemctl restart weston
sleep 2
# Instead, just restart the sonyapp service
systemctl start sonyapp &
