# conventions
#
# uppercase for global variables
# lowercase for local variables
# titlecase for arrays

##########################################################
# basic settings
##########################################################

# donwload path: works for function `bdl()`
export DOWNLOAD=$HOME/Documents
# backup folder
export BACKUP=$DOWNLOAD/backup

##########################################################
# select zsh-plugins
##########################################################

# toolchain specific (highly recommended)
# zsg: zsh-git
# zszj: zsh-zellij
#
# language & software-specific
# zsc: zsh-conda
# zscc: zsh-cpp
# zsdk: zsh-docker
# zshx: zsh-helix
# zsjl: zsh-julia
# zslm: zsh-lima
# zsn: zsh-node
# zsrs: zsh-rust
# zstl: zsh-texlive
# zsvi: zsh-vim
# zsvs: zsh-vscode
#
# other-shortcuts
# zspd: zsh-pandoc
# zswt: zsh-widgets
PLUGINS=(zsg zszj zscc zsc zsjl zsn zsrs zstl zsvs zspd zswt zslm zshx)

##########################################################
# register proxy ports
##########################################################

declare -A Proxy
# c: clash, v: v2ray
Proxy[c]=7890
Proxy[v]=1080

##########################################################
# select software configuration objects
##########################################################

# options: brew, conda, julia, node, texlive, vscode
declare -a INIT_OBJ
INIT_OBJ=(brew conda julia node vscode)

declare -a BACK_OBJ
BACK_OBJ=(brew conda julia node vscode)

declare -a UP_OBJ
UP_OBJ=(brew conda julia node vscode)

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
declare -a EPF_OBJ
EPF_OBJ=(ox al zs vs vsk vss_)

# files to be import from backup folder
# declare -a IPF_OBJ
# IPF_OBJ=(ox al zs vs vsk vss_)

# file to be copied from oxidizer/defaults
declare -a IIF_OBJ
# al: alacritty
# ar: aria2
# pu: pueue
# pua: pueue_aliases
# zj: zellij
IIF_OBJ=(ar)
# IIF_OBJ=(ar zj)

##########################################################
# brew configurations
##########################################################

export HOMEBREW_NO_ENV_HINTS=1
export HOMEBREW_NO_AUTO_UPDATE=1
# export HOMEBREW_AUTO_UPDATE_SECS="86400"

# brew backup path
export HOMEBREW_BUNDLE_FILE=$BACKUP/install/Brewfile

# brew mirrors for faster download, use `bmr` to use
declare -A Brew_Mirror
Brew_Mirror[ts]="mirrors.tuna.tsinghua.edu.cn/git/homebrew"
Brew_Mirror[zk]="mirrors.ustc.edu.cn/git/homebrew"

# predefined brew services
# set the length of key <= 3
declare -A Brew_Service

Brew_Service[pu]="pueue"
Brew_Service[mys]="mysql"

##########################################################
# zellij configurations
##########################################################

export ZELLIJ_CONFIG_DIR=$HOME/.config/zellij

##########################################################
# register conda environments
##########################################################

# predefined conda environments
# set the length of key <= 3
declare -A Conda_Env
Conda_Env[k]="kaggle"

##########################################################
# rust configurations
##########################################################

# rust mirrors for faster download, use `rsmr` to use
declare -A Rust_Mirror
Rust_Mirror[ts]="mirrors.tuna.tsinghua.edu.cn"
Rust_Mirror[zk]="mirrors.ustc.edu.cn"

##########################################################
# lima configurations
##########################################################

# predefined lima instances
# set the length of key <= 3
declare -A Lima
Lima[ub]="ubuntu"
Lima[ar]="archlinux"

##########################################################
# zsh
##########################################################

alias tt="\time zsh -i -c exit"
alias ua="unalias"
alias uf="unfunction"
alias wh="which"
alias e="echo"
alias ev="eval"
alias rr="rm -rf"
alias own="sudo chown -R $(whoami)"
alias c="clear"
alias ccc="local HISTSIZE=0 && history -p && reset"

# tools
alias du="dust"
alias ar="aria2c --dir $DOWNLOAD"

# global
#
# w: wordcount, l: line, w:word
alias -g w0="| rg '\s0\.\d+'"
alias -g wl="| wc -l"

##########################################################
# jupyter
##########################################################

alias jn="jupyter notebook"
alias jnl="jupyter lab"
alias jnk="jupyter kernelspec"
alias jnkls="jupyter kernelspec list"
alias jnkus="jupyter kernelspec remove"

alias jb="jupyter-book"
alias jbcr="jupyter-book create"
alias jbcl="jupyter-book clean"
alias jbb="jupyter-book build"

ghp() {
    ghp-import -n -p -f $1/_build/html
}

##########################################################
# startup & daily commands
##########################################################

# default editor can be changed by function `ched()`
export EDITOR=code

export STARTUP=1

startup() {
    cd $HOME/Documents
}

upall() {
    conda deactivate && conda activate base

    pueue group add up
    pueue parallel 5 -g up
    pueue add -g up "bups"
    pueue add -g up "cup"
    pueue add -g up "cupk"
    pueue add -g up "jlup"
    pueue add -g up "tlup"

    sleep 3 && pueue status
}

clall() {
    pueue group add clean
    pueue parallel 5 -g clean
    pueue add -g clean "bcl"
    pueue add -g clean "ccl"
    pueue add -g clean "jlcl"

    sleep 3 && pueue status
}

##########################################################
# very personal
##########################################################

alias ck="ceat k"
