echo off
color 0a
cls
echo ##
echo ##
echo ## Starting kill tasks
timeout /t 25
taskkill /f /im teams.exe
taskkill /f /im chrome.exe
echo ##
echo ##
echo ## Killed tasks
timeout /t 20
cls
echo ## Cleaning System Junk, Will need to confirm
timeout /t 20
del /f /s /q "C:\Users\Alex Minster\Downloads\*.ics"
rmdir /s %systemdrive%\$Recycle.bin
echo ##
echo ##
echo ## Deleted junk files
timeout /t 20
cls
echo ##
echo ##
echo ## Shutdown sequence initated
color 47
echo ## 
echo ## Kill this to cancel
echo ## 
echo ## Or hit a button/wait to shutdown
timeout /t 30
cls
shutdown /r /f /t 07
REM /f: force deleting of read-only files
REM /s: Delete specified files from all subdirectories.
REM /q: Quiet mode, do not ask if ok to delete on global wildcard
REM %systemdrive%: drive upon which the system folder was placed
REM %windir%: a regular variable and is defined in the variable store as %SystemRoot%. 
REM %userprofile%: variable to find the directory structure owned by the user running the process