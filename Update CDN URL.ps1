Function UpdateCDNURL {
$inputPC = cat env:\computername
$c2rConfig = "HKLM:\SOFTWARE\Microsoft\Office\ClickToRun\Configuration"
$c2rUpdate = "HKLM:\SOFTWARE\Microsoft\Office\ClickToRun\Updates"
$ofc16Common = "HKLM:\SOFTWARE\Policies\Microsoft\Office\16.0\Common\OfficeUpdate"
If (Test-Path "HKLM:\SOFTWARE\Microsoft\Office\ClickToRun\Configuration") {
If (!((Get-ItemPropertyValue "HKLM:\SOFTWARE\Microsoft\Office\ClickToRun\Configuration" -name 'CDNBaseUrl') -eq "http://officecdn.microsoft.com/pr/492350f6-3a01-4f97-b9c0-c7c6ddf67d60")) {
    Write-Output "Not the right URL. Setting to correct one.";
    Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Office\ClickToRun\Configuration" -name 'CDNBaseUrl' -Value "http://officecdn.microsoft.com/pr/492350f6-3a01-4f97-b9c0-c7c6ddf67d60";
	Sleep -m 500;
	$newCDN = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Office\ClickToRun\Configuration").CDNBaseUrl;
	Write-Output "CDNBaseUrl now: $newCDN"; "";
    $props = @("UpdateUrl","UpdateToVersion");
	foreach ($propo in $props) {
        If (!((Get-Item $c2rConfig).property -contains $propo)) {
            Write-Output "Property '$propo' cannot be found in $c2rConfig on $inputPC"; "";
        } Else {
			Remove-ItemProperty $c2rConfig -name $propo;
		}
        If (!((Get-Item $c2rUpdate).property -contains $propo)) {
            Write-Output "Property '$propo' cannot be found in $c2rUpdate on $inputPC"; "";
        } Else {
		    Write-Output "Removing property '$propo' from $c2rUpdate on $inputPC";
			Remove-ItemProperty $c2rUpdate -name $propo;			
			}
		}
        If (!(Test-Path $ofc16Common)) {
            Write-Output "Filepath $ofc16Common not found on $inputPC"
        } else {
            Write-Output "Removing $ofc16Common key from $inputPC"
            Remove-Item $ofc16Common -Recurse -Force #-Confirm
        } #end single-key verification + deletion
} else {
 Write-Output "$inputPC has the desired CDN URL. No further action is needed."
} #end If condition to update CDN key value
} Else {
    Write-Output "Office doesn't appear to be installed on $inputPC"
} # End If Test-path for ClicktoRun key exists
} # UpdateCDNURL
#test-cpjgl32

UpdateCDNURL
