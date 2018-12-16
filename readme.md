Menu System for PlayStation Classic ui_menu
===========================================

**For developers only, do not install if you don't know what you're doing!**

Approach
--------
Through a combination of overmounting and symbolic linking, implement a menu
system.

The folder bootstrapper sets up the system. It creates the necessary folders for
`/gaadata` and `/data/AppData/sony/pcsx` overrides, along with a context folder
for the folder system itself. A custom system preferences file is then overmounted.
Then it launches the root folder. Folder loading is done by symlinking the
necessary files to the override folders, and overmounting the database directory
(it's hardcoded in the UI binary).

An intercept program is used to determine whether to load the emulator or another
folder. A cuefile name that starts with `FOLDER-` loads a new folder with the same
name as on the USB, and a cuefile named `FOLDEREXIT` will go back to the previous
folder level or exit the system. Everything else gets passed to PCSX.

More details on folder directory structure to come later, or you could read the
source.

Installation
------------
Copy everything to your lolhack USB drive. Provide your own copy of the lolhack
update package.

Note on BleemSync
-----------------
Although the menu says "BleemSync" games, this may not be actually compatible
with BleemSync. I manually generated my files instead of using BleemSync, so
the folder structure may not match up, so your games may not actually work.
