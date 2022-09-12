clear-host
Echo "Keep alive with scroll lock"

$WShell = New-Object -com "WScript.shell"
while ($True)
{
  $WShell.sendkeys("{SCROLLLOCK}")
  start-sleep -Milliseconds 100
  $WShell.sendkeys("{SCROLLLOCK}")
  start-sleep -Seconds 240
}