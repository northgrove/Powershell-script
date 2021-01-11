#Disclaimer: This script come as is, use at own risk
#Created by: Kjetil Nordlund @ Microsoft.com
#Date: last change 11.01.21
#Description: script to get raw data from Microsoft 365 Defender advanced hunting API and write it to a Log analytics workspace 
#Requirements: Need ".\Config.json" with Azure AD appid and app secret

# Getting config
$config = Get-Content .\Microsoft365Defender\config.json | ConvertFrom-Json

# Replace with your Workspace ID
$CustomerId = "d113b58f-342b-471d-ad0e-e41c4fc228b8"  

# Replace with your Primary Key
$SharedKey = get-content .\AzureLog_API\config

# Specify the name of the record type that you'll be creating
$LogType = "EmailEventsFromAPI"

# You can use an optional field to specify the timestamp from the data. If the time field is not specified, Azure Monitor assumes the time is the message ingestion time
$TimeStampField = "Timestamp"

#get date
$date = get-date -Format o

# Security graph API
#
# Autentisere mot Microsoft Graph og hente access token

$appID = $config.clientid 
$appSecret = $config.clientSecret 
$tenantid = $config.tenantid
$tokenAuthURI = "https://login.microsoftonline.com/msgrove.onmicrosoft.com/oauth2/token"

# requesten for Access Token
$requestBody = "grant_type=client_credentials" + 
    "&client_id=$appID" +
    "&client_secret=$appSecret" +
    "&resource=https://api.security.microsoft.com"

$tokenResponse = Invoke-RestMethod -Method Post -Uri $tokenAuthURI -body $requestBody -ContentType "application/x-www-form-urlencoded"
$accessToken = $tokenResponse.access_token

#write-host $config.clientid $config.clientSecret $config.tenantid
write-host $accessToken

# Signature
Function Build-Signature ($customerId, $sharedKey, $date, $contentLength, $method, $contentType, $resource)
{
    $xHeaders = "x-ms-date:" + $date
    $stringToHash = $method + "`n" + $contentLength + "`n" + $contentType + "`n" + $xHeaders + "`n" + $resource

    $bytesToHash = [Text.Encoding]::UTF8.GetBytes($stringToHash)
    $keyBytes = [Convert]::FromBase64String($sharedKey)

    $sha256 = New-Object System.Security.Cryptography.HMACSHA256
    $sha256.Key = $keyBytes
    $calculatedHash = $sha256.ComputeHash($bytesToHash)
    $encodedHash = [Convert]::ToBase64String($calculatedHash)
    $authorization = 'SharedKey {0}:{1}' -f $customerId,$encodedHash
    return $authorization
}


function Post-AdvancedQuery($accessToken)
{
    $query = 'EmailEvents | limit 2' # Paste your own query here

    $url = "https://api.security.microsoft.com/api/advancedhunting/run"
    $headers = @{ 
        'Content-Type' = 'application/json'
        Accept = 'application/json'
        Authorization = "Bearer $accessToken" 
    }
    $body = ConvertTo-Json -InputObject @{ 'Query' = $query }
    $webResponse = Invoke-WebRequest -Method Post -Uri $url -Headers $headers -Body $body -ErrorAction Stop
    $response =  $webResponse | ConvertFrom-Json
    $results = $response.Results
    $schema = $response.Schema

    return $results
}

$events = Post-AdvancedQuery -accessToken $accessToken


$events = $events | ConvertTo-Json

$events


# Create the function to create and post the request
Function Post-LogAnalyticsData($customerId, $sharedKey, $body, $logType)
{
    $method = "POST"
    $contentType = "application/json"
    $resource = "/api/logs"
    $rfc1123date = [DateTime]::UtcNow.ToString("r")
    $contentLength = $body.Length
    $signature = Build-Signature `
        -customerId $customerId `
        -sharedKey $sharedKey `
        -date $rfc1123date `
        -contentLength $contentLength `
        -method $method `
        -contentType $contentType `
        -resource $resource
    $uri = "https://" + $customerId + ".ods.opinsights.azure.com" + $resource + "?api-version=2016-04-01"

    $headers = @{
        "Authorization" = $signature;
        "Log-Type" = $logType;
        "x-ms-date" = $rfc1123date;
        "time-generated-field" = $TimeStampField;
    }

    $response = Invoke-WebRequest -Uri $uri -Method $method -ContentType $contentType -Headers $headers -Body $body -UseBasicParsing
    return $response.StatusCode

}

# Submit the data to the API endpoint
Post-LogAnalyticsData -customerId $customerId -sharedKey $sharedKey -body ([System.Text.Encoding]::UTF8.GetBytes($events)) -logType $logType