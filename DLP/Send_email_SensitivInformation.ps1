$userCred = Get-Credential

$smtp = "smtp.office365.com"
$smtPort = "587"
$to = "Egon Olsen <egon@northgrove.no>" 
$from = "Kjetil Nordlund <kjetil@northgrove.no>" 

$subject = "Eksempel mail med sensitivt innhold"

$body = "Hei <b>$to</b><br><br>" 
$body += "Dette er en hemmelig mail <br><br>" 

 

 
send-MailMessage -SmtpServer $smtp -Port $smtPort -UseSsl -To $to -From $from -Subject $subject -Body $body -BodyAsHtml -Credential $userCred -Encoding "UTF8"
