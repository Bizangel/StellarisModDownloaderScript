@echo off

setlocal enabledelayedexpansion

rem Define color codes
set COLOR_RED=[31m
set COLOR_GREEN=[32m
set COLOR_YELLOW=[33m
set COLOR_BLUE=[34m
set COLOR_RESET=[0m

@REM Verify that all arguments are valid.
for %%A in (%*) do (
  call :IsInteger %%A result
  if "!result!"=="false" (
    echo Invalid ID given: %%A
    exit /b 0
  )
)

set failedCount=0
set succCount=0

set "failed="
set "successful="

@REM Fetch All for each id
for %%A in (%*) do (
  set "input=%%A"
  set "input=!input: =!"
  echo %COLOR_BLUE%====== Fetching ModId: !input! ===== %COLOR_RESET%


  PowerShell.exe -ExecutionPolicy Bypass -File .\stellaris_downloader.ps1 !input! -f

  if !errorlevel! equ 1 (
    set "failed=!failed! %%A"
    set /a failedCount+=1
  ) else (
    set "successful=!successful! %%A"
    set /a succCount+=1
  )


)
echo %COLOR_BLUE%=============== SUMMARY ==============%COLOR_RESET%

set /a total=failedCount+succCount
if "%failed%" neq "" (
  echo %COLOR_BLUE%Total Mods: %total%%COLOR_RESET%
  echo %COLOR_GREEN%Successful Downloads: %succCount%%COLOR_RESET%
  echo %COLOR_GREEN%Successfully downloaded: %successful%%COLOR_RESET%

  echo %COLOR_RED%Failed Downloads: %failedCount%%COLOR_RESET%
  echo %COLOR_RED%Failed to download: %failed%%COLOR_RESET%

  echo %COLOR_YELLOW%Please try again or download them individually with:%COLOR_RESET%
  echo %COLOR_YELLOW%.\stellaris_multiple_downloader.bat%failed% %COLOR_RESET%

) else (
  echo %COLOR_BLUE%Total Mods: %total%%COLOR_RESET%
  echo %COLOR_GREEN%Successfully downloaded all %succCount% mods!%COLOR_RESET%
)

endlocal && exit /b 0

REM Define the function to check if it's a valid ID (just integer)
:IsInteger

setlocal EnableDelayedExpansion

REM Check if the argument count is less than 1
if "%~1"=="" (
    echo No argument provided.
    exit /b
)

REM Set a variable to the command-line argument
set "input=%~1"

REM Remove leading and trailing spaces (optional)
set "input=%input: =%"

REM Validate if the input is an integer

set "isvalidinteger=true"
for /F "delims=0123456789" %%i in ("!input!") do set "isvalidinteger=false"

endlocal&set %~2=%isvalidinteger%

exit /b 0

