#module requirements: azureadpreview, psexcel, microsoftteams, plannermodule
#module documentation: https://docs.microsoft.com/en-us/powershell/module/sharepoint-pnp/?view=sharepoint-ps

#Disclaimer: This script come as is, use at own risk
#Created by: Kjetil Nordlund @ Microsoft.com
#Date: last change 19.11.19
#Description: This script are used to create a Planner plan out of correspondending excel task-plan


# Variables
$tasklist = ".\Aktivitetsliste Planner import.xlsx"
$teamsname = "Secure Productivity implementation"
$plannerlistname = "secure productivity implementation"


#installerer nødvendige moduler om de ikke finnes fra før
if (!(Get-Module -Name azureadpreview)) {
    Install-Module azureadpreview
    import-module azureadpreview
}
if (!(Get-Module -Name psexcel)) {
    install-module psexcel
    import-module psexcel
}
if (!(Get-Module -Name microsoftteams)) {
    install-module microsoftteams
    import-module microsoftteams
}
if (!(Get-Module -Name Plannermodule)) {
    Install-Module -Name PlannerModule
    import-module -Name plannermodule
}

## Leser aktivitetslista
$xlsimport = Import-XLSX $tasklist

#Ber om nødvendige credentials
$userCred = Get-Credential

$username = $userCred.UserName
$password = $userCred.Password

## Koble til
Connect-AzureAD -Credential $userCred
Connect-MicrosoftTeams -Credential $userCred
Connect-Planner -Credential $userCred


## Opprette team
if (Get-Team -DisplayName $teamsname) {
    $team = Get-Team -DisplayName $teamsname
    Write-host "Team eksisterer"
}
else {

    $team = New-Team -DisplayName $teamsname
    write-host "opprettet nytt team"
}

#### legger til medlemmer fra excel ark
$brukere = new-object System.Collections.ArrayList
foreach ($bruker in $xlsimport)
{
    $brukere.Add($bruker) | Out-Null

}
$unikebrukere = $brukere.ansvarlig | select -Unique

foreach ($unikbruker in $unikebrukere)
{
    Write-Host $unikbruker
    #$user = Get-AzureADUser - -SearchString $unikbruker | where Usertype -eq Member
    $eksisterendebrukere = Get-TeamUser -GroupId $team.GroupId
    if($eksisterendebrukere.User -notcontains $unikbruker) {
        Add-TeamUser -GroupId $team.GroupId -User $unikbruker -Role Member
    }

}



## Lag en ny Planner plan
if (Get-PlannerPlansList -GroupName @plannerlistname) {
    
    $plannerplan = Get-PlannerPlansList -GroupName $plannerlistname
    write-host "Planner Tavle finnes allerede"
}
else {

    $plannerplan = New-PlannerPlanToGroup -GroupID $team.GroupId -PlanName $plannerlistname
    write-host "opprettet ny planner tavle"

}



#### Hent ut oppgaver
$existingBuckets = Get-PlannerPlanBuckets -PlanID $plannerplan.id
$oppgaver = new-object System.Collections.ArrayList
foreach ($oppgave in $xlsimport)
{
    if ($oppgave.Kategori -ne $null) {
        $oppgaver.Add($oppgave) | Out-Null
        Write-Host $oppgave.Kategori
    }
    
}

#### Hent ut unike kategorier
$unikekategorier = $oppgaver.Kategori | Select-Object -Unique


#### Lag PLanner buckets
foreach ($unikkategori in $unikekategorier)
{
    if (!($existingBuckets.name -contains $unikkategori)) {
        New-PlannerBucket -PlanID $plannerplan.id -BucketName $unikkategori
        Write-host "Lagde bucket: " $unikkategori
    }
}

#### Opprett tasks
$existingBuckets = Get-PlannerPlanBuckets -PlanID $plannerplan.id
foreach ($oppgave in $oppgaver)
{
    $bucket = $existingBuckets | Where-Object name -eq $oppgave.Kategori
    $task = New-PlannerTask -PlanID $plannerplan.id -BucketID $bucket.id -TaskName $oppgave.Aktivitetsnavn
    $beskrivelse = $oppgave.beskrivelse + " " + $oppgave.Referanse
    Add-PlannerTaskDescription -TaskID $task.id -Description $beskrivelse
    
    if ($oppgave.Ansvarlig -like "*@*") {
        Invoke-AssignPlannerTask -TaskID $task.id -UserPrincipalNames $oppgave.Ansvarlig
    }
}




