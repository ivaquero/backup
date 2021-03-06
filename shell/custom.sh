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

# default editor
export EDITOR=code
# terminal editor
export EDITOR_T=hx

##########################################################
# select ox-plugins
##########################################################

# toolchain specific (highly recommended)
# oxpg: ox-git
# oxpzj: ox-zellij
#
# language & software-specific
# oxpc: ox-conda
# oxpcc: ox-cpp
# oxpdk: ox-docker
# oxphx: ox-helix
# oxpjl: ox-julia
# oxplm: ox-lima
# oxpnj: ox-node
# oxpnv: ox-neovim
# oxprs: ox-rust
# oxptl: ox-texlive
# oxpvs: ox-vscode
#
# other-shortcuts
# oxpfm: ox-format
# oxpwt: ox-widgets
PLUGINS=(oxpg oxpzj oxpcc oxpc oxpjl oxprs oxptl oxpvs oxpfm oxpwt oxplm oxphx oxpnv)

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
INIT_OBJ=(brew conda julia vscode)

declare -a BACK_OBJ
BACK_OBJ=(brew conda julia vscode)

declare -a UP_OBJ
UP_OBJ=(brew conda julia vscode)

# backup file path
Oxide[bkb]=$BACKUP/install/Brewfile
# conda env stats with bkce, and should be consistent with Conda_Env
Oxide[bkceb]=$BACKUP/install/conda-base.txt
Oxide[bkcek]=$BACKUP/install/conda-kaggle.txt
Oxide[bkjl]=$BACKUP/install/julia.txt
Oxide[bktl]=$BACKUP/install/texlive.txt
Oxide[bkvsx]=$BACKUP/install/vscode-exts.txt
# Oxide[bknj]=$BACKUP/install/node.txt

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
EPF_OBJ=(ox al vs vsk vss_)

# files to be import from backup folder
# declare -a IPF_OBJ
# IPF_OBJ=(ox al vs vsk vss_)

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
Conda_Env[w]="weather"

alias ck="ceat k"
alias cw="ceat w"

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
# common aliases
##########################################################

alias wh="which"
alias e="echo"
alias ev="eval"
alias rr="rm -rf"
alias own="sudo chown -R $(whoami)"
alias c="clear"
alias ccc="local HISTSIZE=0 && history -p && reset"

# tools
alias ar="aria2c --dir $DOWNLOAD"
alias du="dust"
alias hf="hyperfine"
alias tk="tokei"

# runtime
alias ipy="ipython"

##########################################################
# shell
##########################################################

case $SHELL in
*zsh)
    # turn case sensitivity off
    zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

    # global
    alias -g w0="| rg '\s0\.\d+'"
    alias -g wl="| wc -l"

    # test
    alias tt="hyperfine --warmup 3 --shell zsh 'source ~/.zshrc'"
    ;;
*bash)
    # turn case sensitivity off
    if [ ! -a ~/.inputrc ]; then
        echo '$include /etc/inputrc' >~/.inputrc
    fi
    echo 'set completion-ignore-case On' >>~/.inputrc

    # test
    alias tt="hyperfine --warmup 3 --shell bash 'source ~/.bash_profile'"
    ;;
esac

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
