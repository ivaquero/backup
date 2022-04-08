if [[ -z $OXIDIZER ]]; then
    export OXIDIZER=$HOME/oxidizer
fi

##########################################################
# Oxidizer configuration files
##########################################################

declare -A Oxygen
Oxygen[zs]=$OXIDIZER/.zshrc
Oxygen[al]=$OXIDIZER/defaults/alacritty.yml
Oxygen[ar]=$OXIDIZER/defaults/aria2.conf
# plugins
Oxygen[zsm]=$OXIDIZER/zsh-plugins/zsh-macos.sh
Oxygen[zsub]=$OXIDIZER/zsh-plugins/zsh-ubuntu.sh
Oxygen[zsb]=$OXIDIZER/zsh-plugins/zsh-brew.sh
Oxygen[zscc]=$OXIDIZER/zsh-plugins/zsh-cpp.sh
Oxygen[zsc]=$OXIDIZER/zsh-plugins/zsh-conda.sh
Oxygen[zsdk]=$OXIDIZER/zsh-plugins/zsh-docker.sh
Oxygen[zsg]=$OXIDIZER/zsh-plugins/zsh-git.sh
Oxygen[zshx]=$OXIDIZER/zsh-plugins/zsh-helix.sh
Oxygen[zsjl]=$OXIDIZER/zsh-plugins/zsh-julia.sh
Oxygen[zslm]=$OXIDIZER/zsh-plugins/zsh-lima.sh
Oxygen[zsn]=$OXIDIZER/zsh-plugins/zsh-node.sh
Oxygen[zspd]=$OXIDIZER/zsh-plugins/zsh-pandoc.sh
Oxygen[zspu]=$OXIDIZER/zsh-plugins/zsh-pueue.sh
Oxygen[zsrs]=$OXIDIZER/zsh-plugins/zsh-rust.sh
Oxygen[zstl]=$OXIDIZER/zsh-plugins/zsh-texlive.sh
Oxygen[zsu]=$OXIDIZER/zsh-plugins/zsh-utils.sh
Oxygen[zsvi]=$OXIDIZER/zsh-plugins/zsh-vim.sh
Oxygen[zsvs]=$OXIDIZER/zsh-plugins/zsh-vscode.sh
Oxygen[zswt]=$OXIDIZER/zsh-plugins/zsh-widgets.sh
Oxygen[zszj]=$OXIDIZER/zsh-plugins/zsh-zellij.sh

##########################################################
# System configuration files
##########################################################

declare -A Element
Element[ox]=$OXIDIZER/oxidizer.sh
Element[oxc]=$OXIDIZER/custom.sh
Element[al]=$HOME/.config/alacritty/alacritty.yml
Element[ar]=$HOME/.aria2/aria2.conf
Element[zs]=$HOME/.zshrc

source $Element[oxc]

declare -A Oxide

if [[ ! -d $BACKUP/oxidizer ]]; then
    mkdir -p $BACKUP/oxidizer
fi

Oxide[zs]=$BACKUP/shell/.zshrc
Oxide[ox]=$BACKUP/shell/oxidizer.sh
Oxide[oxc]=$BACKUP/shell/custom.sh
Oxide[al]=$BACKUP/alacritty.yml
Oxide[ar]=$BACKUP/aria2.conf

##########################################################
# Aliases
##########################################################

alias ls="lsd"
alias ll="ls -l"
alias la="ls -a"
alias lla="ls -la"
alias lt="ls --tree"
alias cat="bat"
alias man="tldr"
alias z.="z .."
alias z..="z ../.."
alias zz="z -"

##########################################################
# Zsh & Plugins
##########################################################

zmodload zsh/zprof
zmodload zsh/mathfunc

# turn case sensitivity off
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

declare -a PLUGINS

# import zsh-brew
source $Oxygen[zsb]
# import zsh-utils
source $Oxygen[zsu]
# import zsh-pueue
source $Oxygen[zspu]

case $(uname -a) in
*Darwin*)
    source $Oxygen[zsm]
    ;;
*Ubuntu* | *WSL*)
    source $Oxygen[zsub]
    ;;
esac

for plugin in $PLUGINS[@]; do
    source $Oxygen[$plugin]
done

if [[ ! -d $BACKUP/install ]]; then
    mkdir -p $BACKUP/install
fi

if [[ ! -d $BACKUP/apps ]]; then
    mkdir -p $BACKUP/apps
fi

##########################################################
#  Oxidizer management
##########################################################

# initialize Oxidizer
# only install missing packages, no deletion
init_all() {
    for obj in $INIT_OBJ[@]; do
        eval init_$obj
    done
}

# update all packages
up_all() {
    for obj in $UP_OBJ[@]; do
        eval up_$obj
    done
}

# backup package lists
back_all() {
    for obj in $BACK_OBJ[@]; do
        eval back_$obj
    done
}

# export configurations
epall() {
    for obj in $EPF_OBJ[@]; do
        epf $obj
    done
}

# import configurations
ipall() {
    for obj in $IPF_OBJ[@]; do
        ipf $obj
    done
}

# initialize Oxidizer
iiox() {
    for obj in $IIF_OBJ[@]; do
        iif $obj
    done
}

# update Oxidizer
upox() {
    z $OXIDIZER
    git fetch origin master
    git reset --hard origin/master
    z -
}

if [[ $STARTUP ]]; then
    eval "$(starship init zsh)"
    eval "$(zoxide init zsh)"
    startup
fi

if [[ -z $EDITOR ]]; then
    export EDITOR=code
fi
