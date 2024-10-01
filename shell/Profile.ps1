# Oxidizer
. C:\Users\msain\oxidizer\oxidizer.ps1

#region mamba initialize
# !! Contents within this block are managed by 'mamba shell init' !!
$Env:MAMBA_ROOT_PREFIX = "C:\Users\msain\micromamba"
$Env:MAMBA_EXE = "C:\Scoop\apps\micromamba-cn\current\Library\bin\micromamba.exe"
(& $Env:MAMBA_EXE 'shell' 'hook' -s 'powershell' -p $Env:MAMBA_ROOT_PREFIX) | Out-String | Invoke-Expression
#endregion
Import-Module scoop-completion