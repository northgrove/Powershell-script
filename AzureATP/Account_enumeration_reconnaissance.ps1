
# Script to try authenticating with random user with random password to get "ATP Account enumeration reconnaissance" alert triggered


    $DomainFQDN = "yourdomain.name"
    $domain = "yourdomain"
    $x = $null
    $validUser = "victim"
    $validuserpass = "Passord123"
    $tries = 1000

    do
    {
        write-host $x
        $username = $domain + "\" + $(-join ((48..57) + (97..122) | Get-Random -Count 10 | % {[char]$_}))
        $password = $(-join ((48..57) + (97..122) | Get-Random -Count 10 | % {[char]$_}))
        $DomainObj = "LDAP://" + $DomainFQDN
        $DomainBind = New-Object System.DirectoryServices.DirectoryEntry($DomainObj,$UserName,$Password)
        $DomainName = $DomainBind.distinguishedName
        write-host "user: " $username
        write-host "password: " $password
        write-host "Domain: " $DomainName
        $x += 1
    }
    until ($x -gt $tries)


    #Test with one valid user
    $DomainObj = "LDAP://" + $DomainFQDN
    $DomainBind = New-Object System.DirectoryServices.DirectoryEntry($DomainObj,"$domain\$validuser","$validuserpass")
    $DomainName = $DomainBind.distinguishedName

