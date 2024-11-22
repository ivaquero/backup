# Oxidizer
. $HOME\oxidizer\oxidizer.ps1

Import-Module scoop-completion

# #region mamba initialize
# # !! Contents within this block are managed by 'mamba shell init' !!
# $Env:MAMBA_ROOT_PREFIX = "$HOME\micromamba"
# $Env:MAMBA_EXE = "C:\Scoop\apps\micromamba\current\micromamba.exe"
# (& $Env:MAMBA_EXE 'shell' 'hook' -s 'powershell' -r $Env:MAMBA_ROOT_PREFIX) | Out-String | Invoke-Expression
# #endregion

#region conda initialize
# !! Contents within this block are managed by 'conda init' !!
If (Test-Path "C:\Scoop\apps\miniforge-cn\current\Scripts\conda.exe") {
    (& "C:\Scoop\apps\miniforge-cn\current\Scripts\conda.exe" "shell.powershell" "hook") | Out-String | ? { $_ } | Invoke-Expression
}
#endregion
