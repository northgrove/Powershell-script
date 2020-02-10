#Connect to Exchange Online
$UserCredential = Get-Credential
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection
Import-PSSession $Session -DisableNameChecking

 

#Set CustomAttribute1 value (modify this value as needed)
$CustomAttribute1 = "contoso.com"

 

#Create new Address Lists
New-AddressList -Name $CustomAttribute1 -RecipientFilter {((RecipientType -eq 'UserMailbox') -or (RecipientType -eq "MailUniversalDistributionGroup") -or (RecipientType -eq "DynamicDistributionGroup")) -and (CustomAttribute1 -eq $CustomAttribute1)}
New-AddressList -Name "$CustomAttribute1 Rooms" -RecipientFilter {(Alias -ne $null) -and (CustomAttribute1 -eq $CustomAttribute1) -and ((RecipientDisplayType -eq 'ConferenceRoomMailbox') -or (RecipientDisplayType -eq 'SyncedConferenceRoomMailbox'))}
#Create Global Address List
New-GlobalAddressList -Name "$CustomAttribute1 GAL" -RecipientFilter {(CustomAttribute1 -eq $CustomAttribute1)}
#Create Offline Address Book
New-OfflineAddressBook -Name "$CustomAttribute1 OAB" -AddressLists "$CustomAttribute1 GAL"
#Create Address Book Policy
New-AddressBookPolicy -Name "$CustomAttribute1 ABP" -AddressLists $CustomAttribute1 -OfflineAddressBook "\$CustomAttribute1 OAB"  -GlobalAddressList "\$CustomAttribute1 GAL" -RoomList "\$CustomAttribute1 Rooms"
#Assign Address Book Policy to Mailboxe's with CustomAttribute1 value equal to variable $CustomAttribute1
Get-Mailbox -resultsize unlimited | where {$_.CustomAttribute1 -eq "$CustomAttribute1"} | Set-Mailbox -AddressBookPolicy "$CustomAttribute1 ABP"
#List all Mailboxe's
Get-Mailbox -ResultSize unlimited | select name,addressbookpolicy,customattribute1

 

#Exit Exchange Online Session
Remove-PSSession $Session