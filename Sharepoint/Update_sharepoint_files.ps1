#module requirements: Install-Module SharePointPnPPowerShellOnline
#module documentation: https://docs.microsoft.com/en-us/powershell/module/sharepoint-pnp/?view=sharepoint-ps

#Disclaimer: This script come as is, use at own risk
#Created by: Kjetil Nordlund @ Microsoft.com
#Date: last change 15.09.19
#Description: Script to check timestamp on files in local directory with timestamp on files with same name in a sharepoint online library.
#Description: Upload file if timestamp missmatch.

# Some variables
$diretory = "c:\temp\spfiles\*"
$files = get-item $diretory
$splibrary = "https://msgrove.sharepoint.com/sites/demofiles/"
$credentials = Get-Credential

# connect to SP library
Connect-PnPOnline -Url $splibrary -CreateDrive -Credentials $credentials 

# list files on SP library after sucessfull connect
$SPfiles =  Get-PnPFolderItem -FolderSiteRelativeUrl "Shared Documents" -ItemType File


# the loop to check timestamp and upload files
foreach ($spfile in $spfiles)
{

    foreach ($file in $files)
    {
        
        if ($spfile.name -eq $file.Name) {
            write-host "File name match: " $file.Name
            Write-host "Date SPfile: " $spfile.TimeLastModified
            write-host "Date File: " $file.LastWriteTimeUtc
            if ($spfile.TimeLastModified -notlike $file.LastWriteTimeUtc) {
                Write-Output "Last modified time does not match"
                
                Add-PnPFile -Path $file -Folder "Shared Documents" -Values @{Modified=$file.LastWriteTimeUtc}

                }
            }
    
    }
    Write-host " "
}