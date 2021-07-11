

function LookupFunc($moduleName, $functionName) {

  $systemdll = [AppDomain]::CurrentDomain.GetAssemblies() | Where-Object { $_.GlobalAssemblyCache -And $_.Location.Split('\\')[-1].Equals('System.dll') }
  $unsafeObj = $systemdll.GetType('Microsoft.Win32.UnsafeNativeMethods')
  $GetModuleHandleArray = $unsafeObj.GetMethods() | ForEach-Object {If ($_.Name -eq "GetModuleHandle") {$_} } 
  $GetProcAddressArray = $unsafeObj.GetMethods() | ForEach-Object {If ($_.Name -eq "GetProcAddress") {$_}   }
  $GetModuleHandle = $GetModuleHandleArray[0]
  $GetProcAddress = $GetProcAddressArray[0]
  $moduleHandle = $GetModuleHandle.Invoke($null, @($moduleName ))
   
  return $GetProcAddress.Invoke($null, @($moduleHandle, $functionName) )
}

LookupFunc "user32.dll" "MessageBoxA"
