@echo off
setlocal EnableDelayedExpansion

rem | TortoiseSVN - Fix icon overlays
rem | =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
rem |
rem | Motivation: every few months, Dropbox/OneDrive/GDrive launch an update which breaks TSVN icon overlays [1].
rem | Fix: run through overlay identifiers and increase TSVN icons using the same hack everyone is using: prepend spaces before
rem |
rem | References:
rem | 1. FAQ · TortoiseSVN:
rem |    https://tortoisesvn.net/faq.html#ovlnotall
rem | 2. TortoiseSVN icons not showing up under Windows 7
rem |    http://stackoverflow.com/questions/1057734/tortoisesvn-icons-not-showing-up-under-windows-7
rem | 3. The overlays on Win10 don't always show, because there are too many other overlay handlers installed. [...]
rem |    https://sourceforge.net/p/tortoisesvn/code/26717/
rem |
rem | Changes:
rem | 2017-01-18 HelderMagalhaes First version.

rem | NOTE: reg always returns "full" paths; the remaining is kept as queried
rem | ("HKLM\SoFtWaRe" becomes "HKEY_LOCAL_MACHINE\SoFtWaRe")
set TARGET_KEY=HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\ShellIconOverlayIdentifiers

set RUN_COUNT=0
set ANY_CHANGES=

:Start
set FIRST_ENTRY=
set FIRST_ENTRY_NOT_TSVN=
set CHANGES_DONE=
for /F "tokens=*" %%i in ('reg query "%TARGET_KEY%"') do (
  set CURR_LINE=%%i
  set CURR_KEY=!CURR_LINE:%TARGET_KEY%\=!
  if not defined FIRST_ENTRY (
    set FIRST_ENTRY=!CURR_KEY!
    echo First entry: "!FIRST_ENTRY!"
  )
  if not defined FIRST_ENTRY_NOT_TSVN (
    if "!FIRST_ENTRY:Tortoise=!"=="!FIRST_ENTRY!" (
      set FIRST_ENTRY_NOT_TSVN=1
      echo First entry is *not* Tortoise SVN
    ) else (
      echo First entry is *already* Tortoise SVN
      goto Finish
    )
  )
  rem | check if name contains "Tortoise"
  if not "!CURR_KEY:Tortoise=!"=="!CURR_KEY!" (
    echo Detected TSVN entry: "!CURR_KEY!"

    if defined FIRST_ENTRY_NOT_TSVN (
      rem | add a leading space to TSVN entries to go up in the list
      set RENAMED_KEY= !CURR_KEY!
      echo Relocating to: "!RENAMED_KEY!"
      rem | moving into a key which will be positioned first in the list
      rem | (as there is no "reg move" operation, create a copy and then delete the original key)
      "%windir%\system32\reg.exe" copy "!CURR_LINE!" "%TARGET_KEY%\!RENAMED_KEY!" /s /f>nul 2>&1
      "%windir%\system32\reg.exe" delete "!CURR_LINE!" /f>nul 2>&1
      set CHANGES_DONE=1
    )
  )
)
rem | update runs counter
set /A RUN_COUNT+=1

if %RUN_COUNT% GTR 10 (
  rem | protect against forever loop in case some tricky key is using special characters - below ASCII 32
  rem | (causing our prefixed TSVN entries to *never* display first in list)
  echo Excessive operations detected.
)

rem | if changes were done, we need to run again to make sure TSVN entries are first in the list
rem | (i.e., we may need to prepend several spaces before being #1)
if defined CHANGES_DONE (
  set ANY_CHANGES=1
  goto Start
)

:Finish
if defined ANY_CHANGES (
  set USER_CONFIRM=y
  set /P USER_CONFIRM=Do you wish to restart Windows Explorer [!USER_CONFIRM!]? 
  if /I "!USER_CONFIRM!"=="y" (
    "%windir%\system32\taskkill.exe" /F /IM explorer.exe>nul 2>&1
    rem | hold a bit before restarting
    "%windir%\system32\ping.exe" -n 2 127.0.0.1>nul 2>&1
    start "" "%windir%\explorer.exe">nul 2>&1
  )
)

echo All done^^!
"%windir%\system32\ping.exe" -n 5 127.0.0.1>nul 2>&1
