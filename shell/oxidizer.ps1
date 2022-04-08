##########################################################
# Oxidizer configuration files
##########################################################

$global:Oxygen = @{}
$global:Oxygen.ox = "$env:OXIDIZER/oxidizer.ps1"
$global:Oxygen.oxc = "$env:OXIDIZER/default-custom.ps1"
$global:Oxygen.al = "$env:OXIDIZER/defaults/alacritty-win.yml"
$global:Oxygen.ar = "$env:OXIDIZER/defaults/aria2.conf"
# plugins
$global:Oxygen.pss = "$env:OXIDIZER/pwsh-plugins/pwsh-scoop.ps1"
$global:Oxygen.pscc = "$env:OXIDIZER/pwsh-plugins/pwsh-cpp.ps1"
$global:Oxygen.psc = "$env:OXIDIZER/pwsh-plugins/pwsh-conda.ps1"
$global:Oxygen.psdk = "$env:OXIDIZER/pwsh-plugins/pwsh-docker.ps1"
$global:Oxygen.psg = "$env:OXIDIZER/pwsh-plugins/pwsh-git.ps1"
$global:Oxygen.pshx = "$env:OXIDIZER/pwsh-plugins/pwsh-helix.ps1"
$global:Oxygen.psjl = "$env:OXIDIZER/pwsh-plugins/pwsh-julia.ps1"
$global:Oxygen.psn = "$env:OXIDIZER/pwsh-plugins/pwsh-node.ps1"
$global:Oxygen.pspd = "$env:OXIDIZER/pwsh-plugins/pwsh-pandoc.ps1"
$global:Oxygen.pspu = "$env:OXIDIZER/pwsh-plugins/pwsh-pueue.ps1"
$global:Oxygen.psrs = "$env:OXIDIZER/pwsh-plugins/pwsh-rust.ps1"
$global:Oxygen.pstl = "$env:OXIDIZER/pwsh-plugins/pwsh-texlive.ps1"
$global:Oxygen.psu = "$env:OXIDIZER/pwsh-plugins/pwsh-utils.ps1"
$global:Oxygen.psvi = "$env:OXIDIZER/pwsh-plugins/pwsh-vim.ps1"
$global:Oxygen.psvs = "$env:OXIDIZER/pwsh-plugins/pwsh-vscode.ps1"
$global:Oxygen.pswt = "$env:OXIDIZER/pwsh-plugins/pwsh-widgets.ps1"
$global:Oxygen.psw = "$env:OXIDIZER/pwsh-plugins/pwsh-windows.ps1"

##########################################################
# System configuration files
##########################################################

$global:Element = @{}
$global:Element.ox = "$env:OXIDIZER/oxidizer.ps1"
$global:Element.oxc = "$env:OXIDIZER/custom.ps1"
$global:Element.al = "$env:SCOOP/persist/alacritty/alacritty.yml"
$global:Element.ar = "$env:BASE/.aria2/aria2.conf"
$global:Element.ps = $PROFILE

. $global:Element.oxc

$global:Oxide = @{}
$global:Oxide.ps = "$env:BACKUP/shell/Profile.ps1"
$global:Oxide.ox = "$env:BACKUP/shell/oxidizer.ps1"
$global:Oxide.oxc = "$env:BACKUP/shell/custom.ps1"
$global:Oxide.al = "$env:BACKUP/alacritty.yml"
$global:Oxide.ar = "$env:BACKUP/aria2.conf"

##########################################################
# Aliases
##########################################################

function ls { 
    param ( $path ) 
    if ([string]::IsNullOrEmpty( $path )) { lsd } 
    else { lsd $path }
}
function ll {
    param ( $path ) 
    if ([string]::IsNullOrEmpty( $path )) { lsd -l } 
    else { lsd -l $path } 
}
function la {
    param ( $path ) 
    if ([string]::IsNullOrEmpty( $path )) { lsd -a } 
    else { lsd -a $path } 
}
function lla {
    param ( $path ) 
    if ([string]::IsNullOrEmpty( $path )) { lsd -la } 
    else { lsd -la $path } 
}
function lt {
    param ( $path ) 
    if ([string]::IsNullOrEmpty( $path )) { lsd --tree } 
    else { lsd --tree $path } 
}
function cat { bat $args }
function man { tldr $args }
function z. { z .. }
function z.. { z ../.. }
function zz { z - }

##########################################################
# PowerShell & Plugins
##########################################################

# import pwsh-windows
. $global:Oxygen.psw
# import pwsh-utils
. $global:Oxygen.psu
# import pueue
. $global:Oxygen.pspu

ForEach ($plugin in $global:PLUGINS) {
    . $global:Oxygen.$($plugin)
}

if ( !(Test-Path "$env:BACKUP/install") ) {
    New-Item -ItemType Directory -Force -Path "$env:BACKUP/install"
}

if ( !(Test-Path "$env:BACKUP/apps") ) {
    New-Item -ItemType Directory -Force -Path "$env:BACKUP/apps"
}

##########################################################
#  Oxidizer management
##########################################################

# initialize Oxidizer
# only install missing packages, no deletion
function init_all {
    ForEach ($obj in $global:INIT_OBJ) {
        Invoke-Expression init_$obj
    }
}

# update packages
function back_all {
    ForEach ($obj in $global:UP_OBJ) {
        Invoke-Expression up_$obj
    }
}

# backup packages lists
function back_all {
    ForEach ($obj in $global:BACK_OBJ) {
        Invoke-Expression back_$obj
    }
}

# export configurations
function epall {
    ForEach ($obj in $global:EPF_OBJ) {
        epf $obj
    }
}

# export configurations
function ipall {
    ForEach ($obj in $global:IPF_OBJ) {
        ipf $obj
    }
}

# initialize Oxidizer
function iiox {
    ForEach ($obj in $global:IIF_OBJ) {
        iif $obj
    }
}

# update Oxidizer
function upox {
    z $env:OXIDIZER
    git fetch origin master
    git reset --hard origin/master
}

if ($global:STARTUP) {
    Invoke-Expression (&starship init powershell | Out-String)
    Invoke-Expression (&zoxide init powershell --hook prompt | Out-String)
    startup
}

if (Get-Command code -errorAction SilentlyContinue) {
    $env:EDITOR = "code"
}

##########################################################
# Extras
##########################################################

Import-Module posh-git

Import-Module PSReadLine
Set-PSReadLineKeyHandler -Key Tab -Function Complete
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
Set-PSReadLineKeyHandler -Key "Ctrl+z" -Function Undo

if ( [Environment]::OSVersion.VersionString.Contains("Windows") ) { 
    Import-Module "$($(Get-Item $(Get-Command scoop.ps1).Path).Directory.Parent.FullName)\modules\scoop-completion" -ErrorAction SilentlyContinue
}
