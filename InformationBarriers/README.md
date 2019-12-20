# Information Barriers

## How to isolate teachers and student from each other in the same tenant

In Norway there are govermental reglements that restricts teachers or other employees to be able to contact students that they dont relay to. This has become an issue in environments where teachers and students are part of the same Office 365 tenant. This articel will describe a suggestion on how you can utilize Information Barriers and Data Loss Prevention rules to create segmentation between user groups to restrict collaboration within a tenant.

> ***The risk associated with the implementation of these rules must be assessed by the individual organization***


### Prerequesites

Please follow this article:
https://docs.microsoft.com/nb-no/microsoft-365/compliance/information-barriers-policies#prerequisites

### Create table to organise the different Organization Segments needed
See attached XLSX: 

|SegmentName | FilterAttribute | FilterOperator | FilterAttributeValue |
|------------|-----------------|----------------|----------------------|
|lerere-skole1| memberof|-eq| ib-lerere-skole1 |
|elever-skole1|	memberof|-eq|ib-elever-skole1| 
|Administrasjon| memberof|-eq|ib-administrasjon|
|lerere-skole2|	memberof|-eq|ib-lerere-skole2|
|elever-skole2|	memberof|-eq|ib-elever-skole2|

**SegmentName:** The *name* of the segment to be created  
**FilterAttribute:** The userobject attribute you want to filter users on to be included in the organisation segment  
**FilterOperator:** equal (-eq) or not equal (-neq)  
**FilterAttributeValue:** The value the attribute should have to be included  
  

| AssignedSegment | BlockedSegment |
|-----------------|----------------|
| administrasjon | elever-skole1|
|administrasjon|elever-skole2|
|elever-skole1|administrasjon|
|elever-skole2|administrasjon|
|lerere-skole2|elever-skole1|

**AssignedSegment:** Name of the segment to create a policy for  
**BlockedSegment:** Name of the segment that *AssignedSegment* should be blocked to contact  


### Run the Powershell script

> **module requirements:** Install-Module -Name Az  
> **module documentation:** https://docs.microsoft.com/nb-no/powershell/azure/install-az-ps?view=azps-3.2.0&viewFallbackFrom=azps-2.3.2  
> **Disclaimer:** This script come as is, use at own risk  
> **Created by:** Kjetil Nordlund @ Microsoft.com  
> **Date:** last change 19.12.19  
> **Description:** script to implement Information Barriers in Office365/Teams  


**Powershell script:** https://github.com/northgrove/Powershell-script/blob/master/InformationBarriers/InformationBarriersSetup.ps1


