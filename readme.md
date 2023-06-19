
This script downloads a steam mod workshop file directly to the stellaris mod folder.

First clone/download this repo (or just download stellaris_downloader.bat and the stellaris_downloader.ps1, the bat is just a powershell wrapper).

Then to use:

```
stellaris_downloader.bat <workshop-id>
```

For example to download UI Overhaul Dynamic https://steamcommunity.com/sharedfiles/filedetails/?id=1623423360
(pretty popular and cool btw),

Copy it's ID from the url (1623423360)
and run:
```
stellaris_downloader.bat 1623423360
```

And that's it, it will attempt to auto-download steamcmd to fetch the files and automatically download the mod.

It is intended mainly for GOG installations where you downloading mods can be a bit of a hassle.

## Batch downloading

You can also download several mods at once using the helper `stellaris_multiple_downloader.bat` (It simply runs the previous script for each entry.)

Use it like so:

```
stellaris_multiple_downloader.bat <mod-id1> <mod-id2> <mod-id3> ...
```

Example:

```
stellaris_multiple_downloader.bat 2830996776 819148835 1878473679
```

Hope someone finds this useful. It was for me!