clear
Start-Sleep 1
Write-Host " My execution policy was: (Next line is from Get-ExecutionPolicy)"
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
# $obj.SendKeys([char]173)
Start-Sleep 1
Start http://www.priceisrightfailhorn.com/
Start-Sleep 4
Write-Host " So what happened? "
Write-Host " My execution policy was "
Get-ExecutionPolicy
Start-Sleep 1
Write-Host " And I was able to "
Start-Sleep 1
Write-Host " Send keyboard commands "
Start-Sleep 1
Write-Host " To unmute and increase your volume "
Start-Sleep 1
Write-Host " And then open up a website of my choosing "
Start-Sleep 2
Write-Host " Should I be able to do this "
Start-Sleep 2
Write-Host " With that execution policy set? "
Start-Sleep 2
Write-Host " P.S. Normally disabled in this script, yet... "
Start-Sleep 2
Write-Host " If I can do this, I can clear the event logs for it. "
Start-Sleep 2
Write-Host " Stop ExcutionPolicy bypass through powershell "
# Remove comment octothorpe from below lines to attempt Log Clearing
# Write-Host " (Attempt to clear Security and Application Event Log) "
# Start-Sleep 1
# Get-EventLog -list
# Clear-EventLog -logname Application, Security -computername $env:COMPUTERNAME
