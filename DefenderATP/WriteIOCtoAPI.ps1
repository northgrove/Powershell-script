#Disclaimer: This script come as is, use at own risk
#Created by: Kjetil Nordlund @ Microsoft.com
#Date: last change 15.01.20
#Description: script to get IOC's from AilienVault and import to Microsoft Defender ATP
#Requirements: Need ".\Config.json" with Alienvault APIkey and Azure AD appid and app secret

# Getting config
$config = Get-Content .\DefenderATP\config.json | ConvertFrom-Json

# AilienVault API URL
$apiuri = "https://otx.alienvault.com/api/v1/indicators/export"

# getting indicators
$indicators = invoke-webrequest -URI $apiuri -UseBasicParsing -Headers @{"X-OTX-API-KEY"="$($config.avapikey)"} -UseDefaultCredentials
$data = $indicators.Content | ConvertFrom-Json


# Security graph API
#
# Autentisere mot Microsoft Graph og hente access token

$appID = $config.clientid 
$appSecret = $config.clientSecret 
$tenantid = $config.tenantid
$tokenAuthURI = "https://login.microsoftonline.com/$tenantid/oauth2/token"

# requesten for Access Token
$requestBody = "grant_type=client_credentials" + 
    "&client_id=$appID" +
    "&client_secret=$appSecret" +
    "&resource=https://graph.microsoft.com/"

$tokenResponse = Invoke-RestMethod -Method Post -Uri $tokenAuthURI -body $requestBody -ContentType "application/x-www-form-urlencoded"
$accessToken = $tokenResponse.access_token


$expirationdate = (get-date).AddDays(7)
$defenderURI = "https://graph.microsoft.com/beta/security/tiIndicators"
$ActionMetod = "POST"



foreach ($item in $data.results) {
    if ($item.type = "URL" -and $item.indicator -match "http") {
        $body = @{
                "action"="alert"
                "activityGroupNames"=''
                "confidence"="0"
                "description" = "OTX Threat Indicator - $($item.type)"
                "expirationDateTime"="$expirationdate"
                "externalId"="$($item.id)"
                "killChain"=""
                "malwareFamilyNames"=""
                "severity"=0
                "tags"=""
                "targetProduct"="Azure Sentinel"
                "threatType"="WatchList"
                "tlpLevel"="white"
                "url"="$($item.indicator)"
        }
        $jsonbody = $body | ConvertTo-Json

        Invoke-RestMethod -uri $defenderURI -Method $ActionMetod -body $jsonbody -Headers @{"Authorization" = "Bearer $accesstoken"} -ContentType "application/json" -ErrorAction stop
        
        write-host "wrote $($item.indicator)"
    }
}

