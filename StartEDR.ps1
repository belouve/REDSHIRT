$targets = Get-Content -Path C:\Projects\PowershellEDR\edr-target-list1.txt
ForEach ($target in $targets) {
  If((Get-Service -Name carbonblack -ComputerName $target -ErrorAction SilentlyContinue).Status -eq 'Stopped'){
    #The above makes it only apply if Stopped, and to silently continue on error
	#Then sets the service to Running
	Get-Service -Name carbonblack -ComputerName $target | Set-Service -Status Running
    #Let sleep to ensure started
        Start-sleep -Seconds 2
	#This is to give us some feedback, see when new one started
    Write-Host "Started EDR, status is:"	
    Get-Service -Name carbonblack -ComputerName $target
  }
}
#And to close it out to let us know
Write-Host "All done with list!"