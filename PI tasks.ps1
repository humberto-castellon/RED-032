
Get-NetAdapter | Select-Object Name, InterfaceIndex
$ifindex = read-host "Escriba el indice de la interfaz que quiere configurar"
$IPaddress = Read-host "Escriba la direccion IP para el servidor"
[byte]$Prefix = Read-Host "Escriba la mascara de subred en notacion slash"
$gw = Read-Host "Escriba la puerta de enlace"
$dns1 = Read-Host "Escriba la direccion del servidor DNS primario"
$dns2 = Read-Host "Escriba la direccion del servidor DNS alternativo"
$servername = Read-Host "Escriba el nombre para el servidor"

Write-Information -MessageData "Consulte la zona horaria que necesita configurar en el servidor" -InformationAction Continue

[System.TimeZoneInfo]::GetSystemTimeZones() | Out-GridView

Start-Sleep -Seconds 30

$tzid = Read-Host "Escriba la zona horaria"



$IPInformation = @{
    InterfaceIndex = $ifindex;
    IPAddress      = $IPaddress;
    PrefixLength   = $Prefix;
    DefaultGateway = $gw;

}

#Configurar las propiedades del adaptador de red
New-NetIPAddress @IPInformation -Verbose

#Configurar las direcciones de servidores DNS para el equipo
Set-DnsClientServerAddress -InterfaceIndex $ifindex -ServerAddresses $dns1, $dns2 -Validate -Verbose

#Permitir el trafico ICMP y RDP a traves de la configuracion del firewall

Get-NetFirewallRule -DisplayName "File and Printer Sharing (Echo Request - ICMPv4-In)" | Set-NetFirewallRule -Enabled $true

Get-NetFirewallRule -DisplayName "Remote Desktop - User Mode (TCP-In)" | Set-NetFirewallRule -Enabled $true





#Configuracion de las actualizaciones de Windows

<# 
–2 = Notificarme antes de descargar.
– 3 = Descargar automaticamente y notificarme de la instalacion.
– 4 = Descargar automaticamente y programar la instalacion. 
– 5 = Actualizaciones son requeridas y los usuarios pueden configurarlas.

#>

Get-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU -Name AUOptions -Value 3

#Configurar la fecha y zona horaria

Get-TimeZone | Set-TimeZone -id $tzid

#Cambiar el nombre del equipo

Rename-Computer -NewName $servername -Verbose -Restart



