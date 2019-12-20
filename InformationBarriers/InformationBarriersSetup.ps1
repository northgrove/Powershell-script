#prerequisites: https://docs.microsoft.com/nb-no/microsoft-365/compliance/information-barriers-policies#prerequisites
#
#module requirements: Install-Module -Name Az
#module documentation: https://docs.microsoft.com/nb-no/powershell/azure/install-az-ps?view=azps-3.2.0&viewFallbackFrom=azps-2.3.2
#Disclaimer: This script come as is, use at own risk
#Created by: Kjetil Nordlund @ Microsoft.com
#Date: last change 19.12.19
#Description: script to implement Information Barriers in Office365/Teams


if (!(get-module az)) {
    Install-Module -Name Az -AllowClobber -Scope CurrentUser
    import-module az
    }

#get credentials
$UserCredential = Get-Credential

#Login-AzAccount -credential $UserCredential

#Admin consent for information barriers in Microsoft Teams

<## #Only needed to run once. Uncomment for first time run.

$appId="bcf62038-e005-436d-b970-2a472f8c1982" 
$sp=Get-AzADServicePrincipal -ServicePrincipalName $appId
if ($sp -eq $null) { New-AzADServicePrincipal -ApplicationId $appId }
Start-Process  "https://login.microsoftonline.com/common/adminconsent?client_id=$appId"

##>


#Connect to Office 365 Security & Compliance Center
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.compliance.protection.outlook.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection

Import-PSSession $Session -DisableNameChecking

#get default domain name
$orgDetails = Get-AzureADTenantDetail
$domain = ($orgDetails.VerifiedDomains | where _Default -EQ True).Name


#Import Excel sheet with Information Barriers policies-
$xlsimport = Import-XLSX ".\InfoBarriers-PowerShellGenerator-clean.xlsx"

# Create Organization Segments
foreach ($segment in $xlsimport)
{


    if ($segment.SegmentName -ne $null) {
        write-host $segment.SegmentName
        $filter = "$($segment.FilterAttribute)" + " " + "$($segment.FilterOperator)" + " " + "'$($segment.FilterAttributeValue)@$($domain)'"
        write-host $filter
        New-OrganizationSegment -Name $segment.SegmentName -UserGroupFilter "$filter" -WhatIf

    }
}


# Create Block Policies
foreach ($policy in $xlsimport)
{
    if ($policy.AssignedSegment -ne $null) {
        write-host $policy.AssignedSegment
        New-InformationBarrierPolicy -Name "$($policy.AssignedSegment)-block-$($policy.BlockedSegment)" -AssignedSegment "$($policy.AssignedSegment)" -SegmentsBlocked "$($policy.BlockedSegment)" -State Active


    }
    
}