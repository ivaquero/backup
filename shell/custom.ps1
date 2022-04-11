##########################################################
# basic settings
##########################################################

# donwload path: works for brew-aria2 function
$env:DOWNLOAD = "$env:HOME/Documents"
# backup folder
$env:BACKUP = "$env:DOWNLOAD/backup"

##########################################################
# select pwsh-plugins
##########################################################

# toolchain specific (highly recommended)
# pss: pwsh-scoop
# psg: pwsh-git
#
# language & software-specific
# pscc: pwsh-cpp
# psc: pwsh-conda
# psdk: pwsh-docker
# psjl: pwsh-julia
# psn: pwsh-node
# psrs: pwsh-rust
# pstl: pwsh-texlive
# psvi: pwsh-vim
# psvs: pwsh-vscode
#
# other-shortcuts
# psfm: formats
# pswt: pwsh-widgets
$global:PLUGINS = @("psg", "pscc", "psc", "psjl", "psn", "psrs", "psdk", "psvs", "pstl", "psfm", "pswt")

##########################################################
# register proxy ports
##########################################################

$global:Proxy = @{}
# c: clash, v: v2ray
$global:Proxy.c = "7890"
$global:Proxy.v = "1080"

##########################################################
# select initial and backup configurations
##########################################################

# options: scoop, conda, julia, node, texlive, vscode
$global:INIT_OBJ = @("vscode")
$global:BACK_OBJ = @("vscode")
$global:UP_OBJ = @("vscode")

##########################################################
# select export and import configurations
##########################################################

# files to be exported to backup folder
# ox: custom.sh of Oxidizer
# rs: cargo's env
# pu: pueue's config.yml
# pua: pueue's aliases.yml
# jl: julia's startup.jl
# vs: vscode's settings.json
# vsk: vscode's keybindings.json
# vss_: vscode's snippets folder
$global:EPF_OBJ = @("ox", "al", "ps", "vs", "vsk", "vss_")

# files to be import from backup folder
# $global:IPF_OBJ = @("ox", "al", "ps", "vs", "vsk", "vss_")

# file to be copied from oxidizer/defaults
# al: alacritty
# ar: aria2
# pu: pueue
# pua: pueue_aliases
$global:IIF_OBJ = @("ar")
# $global:IIF_OBJ = @("ar","al")

##########################################################
# register conda environments
##########################################################

# predefined conda environments
# set the length of key < 3
$global:Conda_Env = @{}
$global:Conda_Env.k = "kaggle"

##########################################################
# rust configurations
##########################################################

# rust mirrors for faster download, use `rsmr` to use
# $global:Rust_Mirror = @{}
# $global:Rust_Mirror.ts = "mirrors.tuna.tsinghua.edu.cn"
# $global:Rust_Mirror.zk = "mirrors.ustc.edu.cn"

##########################################################
# powerShell
##########################################################

function wh { which $args }
function e { echo $args }
function rr { Remove-Item -Recurse $args }
function du { dust $args }
function c { clear }
# tools
function ar { aria2c --dir $env:DOWNLOAD $args }

##########################################################
# startup & daily commands
##########################################################

# default editor can be changed by function `ched`
# $env:EDITOR = "code"
$global:STARTUP = 1

function startup {
}
# $env:EDITOR = "code"
$global:STARTUP = 1

function startup {
}
