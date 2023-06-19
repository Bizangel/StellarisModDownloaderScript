
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