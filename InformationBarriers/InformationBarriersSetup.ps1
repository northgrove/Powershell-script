#prerequisites: https://docs.microsoft.com/nb-no/microsoft-365/compliance/information-barriers-policies#prerequisites
#
#module requirements: Install-Module -Name Az
#module documentation: https://docs.microsoft.com/nb-no/powershell/azure/install-az-ps?view=azps-3.2.0&viewFallbackFrom=azps-2.3.2
#Disclaimer: This script come as is, use at own risk
#Created by: Kjetil Nordlund @ Microsoft.com
#Date: last change 19.12.19
#Description: script to implement Information Barriers in Office365/Teams

# Needed variables:
$XlsxConfigDoc = "InfoBarriers-PowerShellGenerator-clean.xlsx"
$domain = $null



if (!(get-module az)) {
    Install-Module -Name Az -AllowClobber -Scope CurrentUser
    import-module az
    }

#get credentials
$UserCredential = Get-Credential

#Login-AzAccount -credential $UserCredential

#Admin consent for information barriers in Microsoft Teams

#Only needed to run once. Uncomment below for first time run.
<## 

$appId="bcf62038-e005-436d-b970-2a472f8c1982" 
$sp=Get-AzADServicePrincipal -ServicePrincipalName $appId
if ($sp -eq $null) { New-AzADServicePrincipal -ApplicationId $appId }
Start-Process  "https://login.microsoftonline.com/common/adminconsent?client_id=$appId"

##>


#Connect to Office 365 Security & Compliance Center
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.compliance.protection.outlook.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection

Import-PSSession $Session -DisableNameChecking

#get default domain name
if ($domain -eq $null) {
    connect-azuread -credential $UserCredential
    $orgDetails = Get-AzureADTenantDetail
    $domain = ($orgDetails.VerifiedDomains | where _Default -EQ True).Name
}


# Create JSON from XLSX - organizationsegments
if (test-path $XlsxConfigDoc) {
    .\Convert-ExcelSheetToJson.ps1 -InputFile InformationBarriers\$XlsxConfigDoc -SheetName organizationsegments -OutputFileName .\InformationBarriers\segments.json
    # Create JSON from XLSX - policies
    .\Convert-ExcelSheetToJson.ps1 -InputFile InformationBarriers\$XlsxConfigDoc -SheetName policies -OutputFileName .\InformationBarriers\policies.json
} else {
    write-host "XLSX file dose not exist"
}

if (test-path segments.json) {
    $segments = get-content segments.json| convertfrom-json
} else {
    write-host "segments.json dose not exist"
}

if (test-path policies.json) {
    $policies = get-content policies.json | convertfrom-json
} else {
    write-host "policies.json dose not exist"
}



# Create Organization Segments
foreach ($segment in $segments)
{


    if ($segment.SegmentName -ne $null) {
        write-host $segment.SegmentName
        $filter = "$($segment.FilterAttribute)" + " " + "$($segment.FilterOperator)" + " " + "'$($segment.FilterAttributeValue)@$($domain)'"
        write-host $filter
        #New-OrganizationSegment -Name $segment.SegmentName -UserGroupFilter "$filter"

    }
}


# Create Block Policies
foreach ($policy in $policies)
{
    if ($policy.AssignedSegment -ne $null) {
        #write-host $policy.AssignedSegment
        #New-InformationBarrierPolicy -Name "$($policy.AssignedSegment)-block-$($policy.BlockedSegment)" -AssignedSegment "$($policy.AssignedSegment)" -SegmentsBlocked "$($policy.BlockedSegment)" -State Active


    }
    
}




#Connect to Exchange online
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection
Import-PSSession $Session -DisableNameChecking


#create mail flow rules
foreach ($EXOpolicy in $policies) {
    #write-host $EXOpolicy.AssignedSegment
    $fromGroupName = ($segments | where {$_.SegmentName -eq $EXOpolicy.AssignedSegment}).FilterAttributevalue
    $toGroupName = ($policies | where {$_.AssignedSegment -eq $EXOpolicy.AssignedSegment}).BlockedSegment
    New-TransportRule "Block from Administration to Students" -BetweenMemberOf1 $fromGroupName -BetweenMemberOf2 $toGroupName -RejectMessageReasonText "Du har ikke lov til å sende epost eller chatte med denne mottakeren. Hendelsen er logget." 
}




