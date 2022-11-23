#Check SMRT values for all disks and send an email alert when surpassing threshold values for reallocated sectors or wear - BN 11/19/2022

Function Send-AlertEmail([string]$Subject, [string]$Body){
	
    #Addresses
    $alertRecipient = "user@homelab.lan"
    $alertSender = "Alerts - $env:computername <user@homelab.lan>"
    
    #Send-Mailmessage is minimal effort for smtp delivery- and often available for free. Alternatively use an http endpoint and invoke-webrequest
    Send-MailMessage -To $alertRecipient -From $alertSender -Subject $Subject -Body $Body -Credential $yourcredentials -SmtpServer "smtp.server.tld" -Port 888 -UseSsl
}



Get-Disk | foreach {
   ##Check reallocated sectors count for magnetic storage
	if( ($_ | Get-StorageReliabilityCounter | Select-Object -ExpandProperty "ReadErrorsCorrected") -gt 3){
	    Send-AlertEmail -Body "Drive error count has reached threshold: $($_.Model) , $($_.SerialNumber)" -Subject "Drive Error Alert on $env:computername"
	}

    ##Check wear metric for solid state disks
	if( ($_ | Get-StorageReliabilityCounter).Wear -gt 85){
	    Send-AlertEmail -Body "Drive wear has reached threshold: $($_.Model) , $($_.SerialNumber)" -Subject "Drive Wear Alert on $env:computername"
     
	}
}
