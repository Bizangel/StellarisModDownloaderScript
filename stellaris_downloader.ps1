param(
    [switch]$f
)

$ForceDeleteConfirmation = $f
$modAppId = $args[0] # To download

$SteamCmdDownloadUrl = "https://steamcdn-a.akamaihd.net/client/installer/steamcmd.zip"
$SteamCmdZip = "steamcmd.zip"
$SteamCmdDir = "steamcmd"
$StellarisAppId = "281990"

$documentsPath = [Environment]::GetFolderPath('MyDocuments')
$modFolderLocation = "$documentsPath\Paradox Interactive\Stellaris\mod"

# Ensure that mod folder exists.
if (-not (Test-Path -Path $modFolderLocation -PathType Container)) {
  Write-Host "Stellaris Mod Path folder not found. Manually create mod folder or update script to point to right folder." -ForegroundColor Red
  exit
}

Write-Host "Found Stellaris mod folder at: $modFolderLocation " -ForegroundColor Green

if (-not $modAppId) {
    # The variable is null or not set
    Write-Host "No Mod ID given to download. Try again: stellaris_downloader.bat <app-id>" -ForegroundColor Red
    exit
}

if (-not [int]::TryParse($modAppId, [ref]$null)) {
    # The value is an integer
    Write-Host "Invalid mod ID given. Ensure it is an integer. Not an url. Example: 1623423360" -ForegroundColor Red
    exit
}

Write-Host "Attempting to download mod with id: $modAppId"

# ===================
# Downloading SteamCMD
# ===================

if (-not (Test-Path -Path $SteamCmdDir -PathType Container)) {
   Write-Host "Steam CMD not previously found. Downloading..." -ForegroundColor Yellow
  (New-Object System.Net.WebClient).DownloadFile($SteamCmdDownloadUrl, $SteamCmdZip)

  Write-Host "Downloaded SteamCMD"
  Write-Host "Extracting..."
  Expand-Archive -Path $SteamCmdZip -DestinationPath $SteamCmdDir

  Write-Host "Cleaning downloaded zip file..."
  Remove-Item -Path $SteamCmdZip
} else {
  Write-Host "Steam CMD found. Using existing installation..." -ForegroundColor Green
}

# ===================
# Downloading the mod
# ===================

$steamCmdPath = ".\$SteamCmdDir\steamcmd.exe"

$steamCmdArgs = "+login anonymous +workshop_download_item $StellarisAppId $modAppId validate +quit"
Start-Process -FilePath $steamCmdPath -ArgumentList $steamCmdArgs -Wait

# =====================================
# Checking if download was succesful
# =====================================

# Copying and Adding to Paradox Launcher
$downloadedModPath = "$SteamCmdDir\steamapps\workshop\content\$StellarisAppId\$modAppId"

if (-not (Test-Path -Path $downloadedModPath -PathType Container)) {
    Write-Host "Could not download mod with id $modAppId. Please check the ID or your internet connection." -ForegroundColor Red
    exit
}

# ===================
# Parsing the descriptor
# ===================

# Copying and Adding to Paradox Launcher
$descriptorPath = "$downloadedModPath\descriptor.mod"

# Read the contents of the file
$fileContent = Get-Content $descriptorPath -Raw
# Use regular expressions to find the name value
$match = [regex]::Match($fileContent, 'name="([^"]+)"')

# Check if a match is found
if ($match.Success) {
    # Get the name value from the match
    $name = $match.Groups[1].Value
    Write-Host "Successfully downloaded: $name"
    $mod_path_friendly_name = $name.ToLower() -replace ' ', '_' -replace '[^a-z0-9_]', ''
    $mod_path_name = $mod_path_friendly_name + "_" + $modAppId
}
else {
    Write-Host "Unable to properly parse descriptor.mod"
    exit
}

# ===================
# Copying the mod folder with descriptor to the Paradox mod folder.
# ===================

# Check if folder doesn't exist already
$targetModFolder = "${modFolderLocation}\${mod_path_name}"

if (Test-Path -Path $targetModFolder -PathType Container) {
    Write-Host "A mod with the same identifier $exampleDownload already exists." -ForegroundColor Yellow

    if (!$ForceDeleteConfirmation) {
        Write-Host "Do you want to delete the existing folder? (Y/N)" -ForegroundColor Yellow
        $confirmation = Read-Host

        if ($confirmation -eq "Y" -or $confirmation -eq "y") {
            Write-Host "Deleting. Overwriting."
            Remove-Item -Path $targetModFolder -Recurse -Force
        } else {
            Write-Host "Stopping." -ForegroundColor Red
            Write-Host "Cleaning up downloaded folder from steamCMD..." -ForegroundColor Red
            Remove-Item -Path $downloadedModPath -Recurse -Force
            exit
        }
    } else {
        Write-Host "Deleting due to -f parameter." -ForegroundColor Yellow
        Write-Host "Deleting. Overwriting." -ForegroundColor Yellow
        Remove-Item -Path $targetModFolder -Recurse -Force
    }
}


# Copy folder
Copy-Item -Path $downloadedModPath -Destination $targetModFolder -Recurse
Write-Host "Succesfully copied mod folder!"

# Copy descriptor
$descriptorTargetLocation = "${modFolderLocation}\${mod_path_name}.mod"
Copy-Item -Path $descriptorPath -Destination $descriptorTargetLocation

Write-Host "Copying And Updating Descriptor"
# Add to descriptor path= property specifying full path.
$absoluteModFolderPath = Convert-Path -Path $targetModFolder
$absoluteModFolderPath = $absoluteModFolderPath.Replace('\', '/') # Else stellaris mod manager won't like it.
$lineToAdd = 'path="{0}"' -f $absoluteModFolderPath

Add-Content -Path $descriptorTargetLocation -Value "`n$lineToAdd"

# ===================
# Cleaning Up.
# ===================

# Delete downloaded folder.
Write-Host "Cleaning up downloaded folder from steamCMD..."
Remove-Item -Path $downloadedModPath -Recurse -Force


Write-Host "Done. Successfully added: $name" -ForegroundColor Green