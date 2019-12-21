#prerequisites:
#module requirements: 
#module documentation: 
#Disclaimer: This script come as is, use at own risk
#Created by: Kjetil Nordlund @ Microsoft.com
#Date: last change 21.12.19
#Description: script to implement Exchange Online Mail Flow Rules to restrict sending email between to user groups in same tenant

# get exchange online user credential
$UserCredential = Get-Credential

#Connect to Exchange online
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection
Import-PSSession $Session -DisableNameChecking


#create mail flow rules

New-TransportRule "Block from Administration to Students" -BetweenMemberOf1 "IB-Administrasjon" -BetweenMemberOf2 "ib-elever-skole1","ib-elever-skole2" -RejectMessageReasonText "Messages sent between the Administration and Students are strictly prohibited."

