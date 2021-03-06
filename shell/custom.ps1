##########################################################
# basic settings
##########################################################

# donwload path: works for brew-aria2 function
$env:DOWNLOAD = "$env:HOME/Documents"
# backup folder
$env:BACKUP = "$env:DOWNLOAD/backup"

# default editor, can be changed by function `ched()`
$env:EDITOR = "code"
# terminal editor
$env:EDITOR_T = "vi"

##########################################################
# select ox-plugins
##########################################################

# toolchain specific (highly recommended)
# oxpg: ox-git
#
# language & software-specific
# oxpc: ox-conda
# oxpcc: ox-cpp
# oxpdk: ox-docker
# oxpjl: ox-julia
# oxpnj: ox-node
# oxpnv: ox-neovim
# oxprs: ox-rust
# oxptl: ox-texlive
# oxpvs: ox-vscode
#
# other-shortcuts
# oxpfm: ox-formats
# oxpwt: ox-widgets
$global:PLUGINS = @("oxpg", "oxpcc", "oxpc", "oxpjl", "oxpnj", "oxprs", "oxpdk", "oxpvs", "oxptl", "oxpfm", "oxpwt", "oxpnv")

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
$global:INIT_OBJ = @("conda", "texlive", "vscode")
$global:BACK_OBJ = @("conda", "texlive", "vscode")
$global:UP_OBJ = @("conda", "texlive", "vscode")

# backup file path
$global:Oxide.bks = "$env:BACKUP/install/Scoopfile.txt"
# conda env stats with bkce, and should be consistent with Conda_Env
$global:Oxide.bkceb = "$env:BACKUP/install/conda-base.txt"
$global:Oxide.bkjl = "$env:BACKUP/install/julia.txt"
$global:Oxide.bktl = "$env:BACKUP/install/texlive.txt"
$global:Oxide.bkvsx = "$env:BACKUP/install/vscode-exts.txt"
# $global:Oxide.bknj = "$env:BACKUP/install/node.txt"

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
$global:EPF_OBJ = @("ox", "al", "vs", "vsk", "vss_")

# files to be import from backup folder
# $global:IPF_OBJ = @("ox", "al", "vs", "vsk", "vss_")

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
function rr { del -Recurse $args }
function c { clear }
# tools
function ar { aria2c --dir $env:DOWNLOAD $args }
function hf { hyperfine $args }

##########################################################
# startup & daily commands
##########################################################

# default editor can be changed by function `ched`
# $env:EDITOR = "code"
$global:STARTUP = 1

function startup {
}
