Menu System for PlayStation Classic ui_menu
===========================================

Approach
--------
Through a combination of overmounting and symbolic linking, implement a menu
system.

When the system is first loaded from USB storage, it will copy all necessary
components to a temporary location (e.g. `/tmp/foldermenu`). It will then set
up a replacement `/gaadata` and `/data/AppData/sony/pcsx` directory for the UI
to read. It will first link the root level menu into those replacement
directories. When the player selects a title, the UI will launch an intercept
program that inspects the path. If the intercept program detects a special
CUE path (e.g. `FOLDER-*`), it will update the replacement directories with
data for that folder and relaunch the UI. Otherwise, it will launch the emulator
program.
