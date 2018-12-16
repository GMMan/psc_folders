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

Folder Structure
----------------
Under the source directory on the USB (`/media/folders`), you can place any number of
folder directories. They do not have to be named in any particular way. Under each
folder directory is the content you want to be linked into the override `gaadata`
and `pcsxdata` directories. Note the same folders will be linked under both, and
only directories will be linked. You only have to provide the game directories
and the `databases` directory; the rest that the system needs will be linked for
you.

There are a few override options. If there is a `gaa_redirect` file present
under the folder directory, the contents of it will be used as the path to link
from. You can also specify a `data_redirect` file that will set the path to link
`pcsxdata` from. If a `gaa_redirect` file is present but not `data_redirect`,
both `gaadata` and `pcsxdata` overrides will link from the path in `gaa_redirect`.
Any additional directories you place under the folder directory will be linked
even when you're using `gaa_redirect` or `data_redirect`.

Database structure
------------------
In the `GAME` table, use `GAME_TITLE_STRING` for name and `PUBLISHER_NAME` for
subtitle. Set `RELEASE_YEAR` and `PLAYERS` to something sensible. For example,
if `RELEASE_YEAR` could be the number of items inside the folder.

In the `DISC` table, set `GAME_ID` to the corresponding entry from the `GAME`
table, and `DISC_NUMBER` to `1`. In `BASENAME`, concatenate `FOLDER-` and the
folder directory name that you want to link when you enter that folder. Use
`FOLDEREXIT` for returning to the previous folder level or exiting the folders
system if you're at the top level.

You only need a `.png` file with the same `BASENAME` for the UI to be able to
display the folder. `.cue`, `.lic`, and `pcsx.cfg` files are not necessary.

Installation
------------
Copy everything to your lolhack USB drive. Provide your own copy of the lolhack
update package.

Note on BleemSync
-----------------
Although the menu says "BleemSync" games, this may not be actually compatible
with BleemSync. I manually generated my files instead of using BleemSync, so
the folder structure may not match up, so your games may not actually work.

Credits
-------
Icons by [Esseti](https://www.deviantart.com/esseti/art/PlayStation3-XMB-Icons-79824699).
