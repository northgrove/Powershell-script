#Disclaimer: This script come as is, use at own risk
#Created by: Kjetil Nordlund @ Microsoft.com
#Date: last change 19.12.19
#Description: script to remove ALL infomration Barriers policies in the tenant

#get credentials
$UserCredential = Get-Credential


#Connect to Office 365 Security & Compliance Center
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.compliance.protection.outlook.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection

Import-PSSession $Session -DisableNameChecking

#remove information policies
$policies = Get-InformationBarrierPolicy
foreach ($policy in $policies)
{
    Set-InformationBarrierPolicy -Identity $policy.Identity -state inactive
    Remove-InformationBarrierPolicy -Identity $policy.identity 

}

#Remove all organizationsegments
Get-OrganizationSegment | Remove-OrganizationSegment
