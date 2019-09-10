$userCred = Get-Credential

$smtp = "smtp.gmail.com"
$smtpPort = "587"
$to = "Egon Olsen <egon@northgrove.no>" 
$from = "Kjetil Nordlund <kjetil.nordlund@gmail.com>" 

$subject = "Eksempel med user impersionating"

$body = "Hei <b>$to</b><br><br>" 
$body += "Sjekk ut disse linkene <br><br>" 
$body += "VG: https://www.vg.no <br>"
$body += "Microsoft: https://www.microsoft.com <br>" 
$body += " - Skru av, go modern: https://www.northgrove.no/bleeding-edge-sikkerhetstenking-skru-av-go-modern/"
 

 
send-MailMessage -SmtpServer $smtp -Port $smtpPort -UseSsl -To $to -From $from -Subject $subject -Body $body -BodyAsHtml -Credential $userCred -Encoding "UTF8"

