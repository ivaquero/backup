# Oxidizer
. $HOME\oxidizer\oxidizer.ps1

Import-Module scoop-completion
Import-Module 'C:\Scoop\apps\vcpkg\current\scripts\posh-vcpkg'

# #region mamba initialize
# !! Contents within this block are managed by 'mamba shell init' !!
$Env:MAMBA_ROOT_PREFIX = "$HOME\micromamba"
$Env:MAMBA_EXE = "C:\Scoop\apps\micromamba\shims\micromamba.exe"
(& $Env:MAMBA_EXE 'shell' 'hook' -s 'powershell' -r $Env:MAMBA_ROOT_PREFIX) | Out-String | Invoke-Expression
# #endregion

$env:VCPKG_ROOT = "$HOME\vcpkg"
$env:PATH = "$env:VCPKG_ROOT;$env:PATH"
$env:VCPKG_FEATURE_FLAG = "-binarycaching"
