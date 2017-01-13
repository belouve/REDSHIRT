clear
Start-Sleep 1
Write-Host " My execution policy was: "
Get-ExecutionPolicy
$obj = new-object -com wscript.shell
# 175 is Volume UP, will unmute if muted.  (175 is volume down)
$obj.SendKeys([char]175)
Start-Sleep 3
Write-Host " My voice is my passport, verify me "
Write-Host "  LOL U LOSE"
$obj.SendKeys([char]175)
Start-Sleep 1
Write-Host " What, I exceeded restrictions? "
Write-Host "   LOL U LOSE"
$obj.SendKeys([char]175)
Start-Sleep 1
Write-Host " My voice is my passport, verify me "
Write-Host "    LOL U LOSE"
$obj.SendKeys([char]175)
Start-Sleep 1
Write-Host " My voice is my passport, verify me "
Write-Host "     LOL U LOSE"
$obj.SendKeys([char]175)
$obj.SendKeys([char]175)
Start-Sleep 1
Write-Host " I'm in your base, stealin' your flag "
Write-Host "      LOL U LOSE"
$obj.SendKeys([char]175)
$obj.SendKeys([char]175)
Start-Sleep 1
Write-Host " My voice is my passport, verify me "
Write-Host "       LOL U LOSE"
$obj.SendKeys([char]175)
$obj.SendKeys([char]175)
Start-Sleep 1
Write-Host " Wait for it... "
$obj.SendKeys([char]175)
$obj.SendKeys([char]175)
Start-Sleep 1
Write-Host "               ... "
Start-Sleep 3
# octothorpe the next SendKeys line to NOT have it muted
# 173 is Mute
$obj.SendKeys([char]173)
Start-Sleep 1
Start http://www.priceisrightfailhorn.com/
# Remove comment octothorpe from below lines to attempt Log Clearing
# Write-Host " (Attempt to clear Security and Application Event Log) "
# Start-Sleep 1
# Get-EventLog -list
# Clear-EventLog -logname Application, Security -computername $env:COMPUTERNAME
