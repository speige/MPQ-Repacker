X-deprotect (hereinafter referred to as "xdep") is a utility for repairing Warcraft3: RoC/TFT maps damaged by special utilities ("optimizers" or "protectors") in such a way that they work in the game, but cannot be opened in the editor.

It should be understood that in general it is impossible to get exactly the same version as the original "protected" map. But you can almost always get a version that works absolutely indistinguishable from the original, while being freely editable.

"Restoration" hereinafter refers to the process of obtaining such a map that can be opened and saved in the editor, while the functionality of which will remain completely identical to the original map.

xdep performs the bare minimum necessary for such a restore, and optionally some additional operations to make the map easier to understand.
(these operations, detailed below, may cause a crash on some maps, but since they are not necessary to restore the map, they can be disabled in the configuration)

xdep is intended not so much for thoughtlessly removing "protection" in 1 click (although such use is possible), but for automating many routine operations during "manual" restoration of a map. At any step, you can intervene in the automatic recovery process by editing files in the temporary folder.

On the resulting restored map, you can use utilities like Deprotect, Dewidgetizer to further restore, for example, GUI triggers or object data.
(due to the fact that these operations are quite complex, and at the same time are not necessary, this utility does not perform them)
Or just edit the map script through the editor, without performing the routine operations of unpacking/packing the war3map.j file from the map with all the glitches associated with it.

What exactly does xdep do in the minimum working configuration:
- unpacks all map files into a separate temporary folder;
- restores the list of files in the archive by scanning all files in search of possible names of other files;
- fixes the war3map.w3i file, which is deliberately corrupted by security utilities;
- deletes files (attributes), (listfile), (signature), transfers the map script to war3map.j;
- restores the list of imported files (war3map.imp);
- restores war3map.wtg, war3map.wct, war3mapUnits.doo files based on map script;
(the map script itself is included in one trigger and changed in such a way that the map is saved without errors in the editor)
- collects the resulting files into a new archive, adding a header to it from the original one.

The list of additional features:
- rename functions with "standard" names assigned by the editor to avoid name conflicts when saving (this option is necessary if "obfuscation" of function names was not used when protecting the map)
- substitution of the code of single-use functions at the place of their call: it is necessary to recognize the initialization section, to restore data about start locations, units, regions, etc. (usually this is already done by some optimization utilities)
- renaming global variables with obfuscated names to something like "udg_integers01"

- indentation in the script
- restoring start locations data to war3mapUnits.doo file based on initialization section
(if this option is disabled, war3mapUnits.doo is still created, but empty as it is needed by WorldEditor)

In the next versions, it is planned to bring the functionality closer to that with which the open version of Dota was obtained (http://dimon.xgm.ru/opendota/), namely:
- data recovery of regions, sounds, cameras, units in the editor format;
- splitting the script into separate triggers;
- renaming functions/variables/triggers/regions and other things according to user-defined lists of names;

The utility is a console one, all parameters, including the names of the input and output files, are described in the xdep.ini text file.
The configuration file is provided with more or less detailed comments on each option.
To start, just enter the path to the required map in the configuration and run xdep.exe.

To work with MPQ, the well-known SFmpq.dll library with a custom-written console archiver is used.
The listfile for the archiver is located in the file listfile.txt, includes lists of names from the standard War3 TFT archives, as well as from several maps on which testing was carried out.

Utility author: zibada aka DimonT, zibada@xgm.guru, ICQ 937160
Thanks for testing help goes to Sky.

XGM - Russian modmaker portal
http://xgm.guru/
