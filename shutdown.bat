echo off
color 0a
cls
echo ##
echo ##
echo ## Starting kill tasks
timeout /t 25
taskkill /f /im teams.exe
taskkill /f /im chrome.exe
taskkill /f /im Joplin.exe
taskkill /f /im JoplinPortable-1.8.5.exe
taskkill /f /im OUTLOOK.exe
echo ##
echo ##
echo ## Killed tasks
timeout /t 20
cls
echo ## Cleaning System Junk, will need to confirm
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
cd c:\Windows\system32\
shutdown /s /t 07
REM /f: force deleting of read-only files
REM /s: Delete specified files from all subdirectories.
REM /q: Quiet mode, do not ask if ok to delete on global wildcard
REM %systemdrive%: drive upon which the system folder was placed
REM %windir%: a regular variable and is defined in the variable store as %SystemRoot%. 
REM %userprofile%: variable to find the directory structure owned by the user running the process