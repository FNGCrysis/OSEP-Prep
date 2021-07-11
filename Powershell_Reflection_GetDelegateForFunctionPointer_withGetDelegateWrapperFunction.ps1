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

function GetDelegateType {

  Param (
  [Parameter(Position = 0, Mandatory = $True)] [Type[]] $func,
  [Parameter(Position = 1)] [Type] $delType = [Void]
  )
  $MyAssembly = New-Object System.Reflection.AssemblyName('ReflectedDelegate')
  $MyAssemblyBuilder = [AppDomain]::CurrentDomain.DefineDynamicAssembly($MyAssembly, [System.Reflection.Emit.AssemblyBuilderAccess]::Run)
  $MyModuleBuilder = $MyAssemblyBuilder.DefineDynamicModule('InMemoryModule', $false)
  $MyTypeBuilder = $MyModuleBuilder.DefineType('MyDelegateType', 'Class, Public, Sealed, AnsiClass, AutoClass', [System.MulticastDelegate])
  $MyConstructorBuilder = $MyTypeBuilder.DefineConstructor('RTSpecialName, HideBySig, Public', [System.Reflection.CallingConventions]::Standard, @($func))
  $MyConstructorBuilder.SetImplementationFlags('Runtime, Managed')
  $MyMethodBuilder = $MyTypeBuilder.DefineMethod('Invoke', 'Public, HideBySig, NewSlot, Virtual', $delType, @($func))
  $MyMethodBuilder.SetImplementationFlags('Runtime, Managed')
  return $MyTypeBuilder.CreateType()
  

}


$MessageBoxAddr = LookupFunc "user32.dll" "MessageBoxA"

$MessageBoxDelegate = GetDelegateType @([IntPtr], [String], [String], [Uint32]) ([int])

$MessageBoxA = [System.Runtime.InteropServices.Marshal]::GetDelegateForFunctionPointer($MessageBoxAddr, $MessageBoxDelegate)

$MessageBoxA.Invoke([IntPtr]::Zero, "stay pasty ;)", "totallyNotMalicious", 0)



