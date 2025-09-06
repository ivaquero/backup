##########################################################
# basic settings
##########################################################

export EDITOR='code'
# terminal editor
export EDITOR_T="vi"

##########################################################
# common aliases
##########################################################

# shortcuts
alias ..="cd .."
alias ...="cd ../.."
alias ~="cd ~"
alias zz="cd -"
alias cat="bat"
alias ls="lsd"
alias ll="ls -l"
alias la="ls -a"
alias lla="ls -la"
alias du="dust"
alias e="echo"
alias rr="rm -r"
alias c="clear"
# shellcheck disable=SC2139
alias own="sudo chown -R $(whoami)"

# tools
alias man="tldr"
alias hf="hyperfine"
alias ff="fastfetch"
alias g="git"
# alias npm="pnpm"
alias p="ipython"

# oxidizer
# export config
alias epf="oxf"
# import config
alias ipf="rdf"
# initialize config
alias iif="clzf"

# personal
alias -g wl="| wc -l"

# others
show_port() {
    lsof -i tcp:"$1"
}

alias yy="yt-dlp -N 50 --no-check-certificate"

oxp() {
    for img in $1*.png; do
        oxipng -o max "$img"
    done
}

oxpp() {
    for folder in *; do
        if [ -d "$folder" ]; then
            for img in "$folder"/$1*.png; do
                oxipng -o max "$img"
            done
        fi
    done
}

##########################################################
# brew
##########################################################

case $(uname -a) in
*Darwin* | *Ubuntu* | *Debian*)
    export HOMEBREW_NO_AUTO_UPDATE=1
    export HOMEBREW_NO_AUTOREMOVE=1
    export HOMEBREW_NO_ENV_HINTS=1
    export HOMEBREW_NO_VERIFY_ATTESTATIONS=1
    export HOMEBREW_CLEANUP_MAX_AGE_DAYS="3"
    ;;
esac
