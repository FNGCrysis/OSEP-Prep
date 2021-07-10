
function LookupFunc($moduleName, $functionName) {

  $Assemblies = [AppDomain]::CurrentDomain.GetAssemblies() | Where-Object { $_.GlobalAssemblyCache -And $_.Location.Split('\\')[-1].Equals('System.dll') }
  $unsafeObj = $systemdll.GetType('Microsoft.Win32.UnsafeNativeMethods')
  $GetModuleHandleArray = $unsafeObj.GetMethods() | ForEach-Object {If ($_.Name -eq "GetModuleHandle") {$_} } 
  $GetProcAddressArray = $unsafeObj.GetMethods() | ForEach-Object {If ($_.Name -eq "GetProcAddress") {$_}   }
  $GetModuleHandle = $GetModuleHandleArray[0]
  $GetProcAddress = $GetProcAddressArray[0]
  $moduleHandle = $GetModuleHandle.Invoke($null, @($moduleName ))
   
  return $GetProcAddress.Invoke($null, @($moduleHandle, $functionName) )
}

$MessageBoxA = LookupFunc "user32.dll" "MessageBoxA"
$MyAssembly = New-Object System.Reflection.AssemblyName('ReflectedDelegate')
$Domain = [AppDomain]::CurrentDomain
$MyAssemblyBuilder = $Domain.DefineDynamicAssembly($MyAssembly, [System.Reflection.Emit.AssemblyBuilderAccess]::Run)
$MyModuleBuilder = $MyAssemblyBuilder.DefineDynamicModule('InMemoryModule', $false)
$MyTypeBuilder = $MyModuleBuilder.DefineType('MyDelegateType', 'Class, Public, Sealed, AnsiClass, AutoClass', [System.MulticastDelegate])
$MyConstructorBuilder = $MyTypeBuilder.DefineConstructor('RTSpecialName, HideBySig, Public', [System.Reflection.CallingConventions]::Standard, @([IntPtr], [String], [String], [int]))
$MyConstructorBuilder.SetImplementationFlags('Runtime, Managed')
$MyMethodBuilder = $MyTypeBuilder.DefineMethod('Invoke', 'Public, HideBySig, NewSlot, Virtual', [int], @([IntPtr], [String], [String], [int]))
$MyMethodBuilder.SetImplementationFlags('Runtime, Managed')
$MyDelegateType = $MyTypeBuilder.CreateType()

$MyFunction = [System.Runtime.InteropServices.Marshal]::GetDelegateForFunctionPointer($MessageBoxA, $MyDelegateType)
$MyFunction.Invoke([IntPtr]::Zero, "Hey Look a box!", "Box Titlez",0)
