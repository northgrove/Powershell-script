# Information Barriers

## Hvordan isolere Ansatte i administrasjonen fra elever i samme Azure AD tenant?

Denne artikkelen vil beskrive hvordan Information Barriers og Data Loss Prevention regeler kan benyttes for å isolere to brukergrupper i Azure AD fra hverandre for å begrense kontakt mulighter og sammarbeid mellom disse brukergruppene.

> ***Nødvendige risikovurderinger knyttet til løsningen må hver enkelt organisasjon som ønsker å benytte dette stå for***

### Prerequesites

Følg denne artikkelen for å etablere nødvendige prerequesites: [Information Barriers prerequisites](https://docs.microsoft.com/nb-no/microsoft-365/compliance/information-barriers-policies#prerequisites)

### Create table to organise the different Organization Segments needed
### Lag oversikt over de forskjellige brukerindelingene som er nødvendig
Dette kan enten gjøres ved hjelpe av vedlagt Excel ark: [InfoBarriers-PowerShellGenerator-clean.xlsx](https://github.com/northgrove/Powershell-script/blob/master/InformationBarriers/InfoBarriers-PowerShellGenerator-clean.xlsx)
eller ved å editere segments.json og policies.json direkte. Avhengig av hva man finner enklest. Excelarket vil dog uansett bli konvertert til JSON.  

Eksempel tabell over organisasjonssegmenter:

|SegmentName | FilterAttribute | FilterOperator | FilterAttributeValue |
|------------|-----------------|----------------|----------------------|
|lerere-skole1| memberof|-eq| ib-lerere-skole1 |
|elever-skole1|	memberof|-eq|ib-elever-skole1| 
|Administrasjon| memberof|-eq|ib-administrasjon|
|lerere-skole2|	memberof|-eq|ib-lerere-skole2|
|elever-skole2|	memberof|-eq|ib-elever-skole2|

**SegmentName:** *navnet* på organisasjonssegmentet  
**FilterAttribute:** Attributtet på brukerobjetet som du ønsker å benytte for å filtrere brukere på, og inkludere de i organisasjonssegmentet (liste over mulige attributter: [Information Barriers attributes](https://docs.microsoft.com/en-us/microsoft-365/compliance/information-barriers-attributes#reference) )  
**FilterOperator:** er lik (-eq) eller er ikke lik (-neq)  
**FilterAttributeValue:** Verdien attributtet skal ha for å inkluderes  
  
### Lag en tabell for å defindere reglene som skal knyttes til de forskjellige organisasjonssegmentene
| AssignedSegment | BlockedSegment | AllowedSegment |
|-----------------|----------------|----------------|
| administrasjon | elever-skole1, elever-skole2||
|elever-skole1|administrasjon, lerere-skole2||
|elever-skole2|administrasjon, lerere-skole1||
|lerere-skole2|elever-skole1||
|lerere-skole1|elever-skole2||

**AssignedSegment:** Navnet på segmentet som policien lages for 
**BlockedSegment:** Navnet på segmentene som *AssignedSegment* skal blokkeres fra å kontakte  
**AllowedSegment:** Navnet på segmentene som *AssignedSegment* skal få lov til å kontakte (hvis det trengs)

## Exchange Online mail flow rules
Powershell scriptet wil også lage Exchange Online Mail Flow Rules for å blokkere definerte segmenter fra å kunne sende mail mellom hverandre. I henhold til policyen definert over.
Ved forsøk på sending av epost til en forbutt bruker vil senderen motta et svar om at mailen er blokkert og hendelsen logget.


## Kjør Powershell scriptet

> **module requirements:** Install-Module -Name Az  
> **module documentation:** https://docs.microsoft.com/nb-no/powershell/azure/install-az-ps?view=azps-3.2.0&viewFallbackFrom=azps-2.3.2  
> **Disclaimer:** This script come as is, use at own risk  
> **Created by:** Kjetil Nordlund @ Microsoft.com  
> **Date:** last change 19.12.19    
> **Description:** script to implement Information Barriers in Office365/Teams  
  
Clone dette github repo'et, editer excelarket med tilpassede segmenter og policyer (eller .json filene direkte - i så fall slett excel arket) og så kjør ***.\InformationBarriers\InformationBarriersSetup.ps1***.

<br /><br />
  
*****
# Use Microsoft Cloud App Security to detect and remove sharing of files
# Bruk av Microsoft Cloud App Security for å detektere og fjerne deling av filer
For å komplettere en issolering av brukergrupper kan Microsoft Cloud App Security benyttes for å detektere, alarmere og eventuelt fjerne deling av filer mellom brukergruppene. 


Eksempel policy i MCAS:  

> Type: File Policy  
> Policy name: IB-blokk deling fra administrasjon til elever  
> Policy Severity: Medium  
> Category: Sharing Control  
> Create a filter for the files this policy will act on: 
> + Files matching all of the following:
>   - Access Level - equals - public(internet), public, external, internal  
>   - Collaborators - groups - contains - ib-elever-skole1, ib-elever-skole2  
>
> Select user group: ib-administrasjon  (the group need to be synced to MCAS to apare in the list)  
> Alerts: Create Alert for each matching file  
> Governance Actions:
> + Microsoft OneDrive for business:
>   - Make private
> + Microsoft Sharepoint Online:
>   - Make private  


Example Policy View in MCAS:  
![MCAS Policy](https://github.com/northgrove/Powershell-script/blob/master/InformationBarriers/img/MCAS-policy.png)




