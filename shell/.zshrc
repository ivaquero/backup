if [[ -z $OXIDIZER ]]; then
    export OXIDIZER=$HOME/oxidizer
fi
source $OXIDIZER/oxidizer.sh

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('$APP/mambaforge/base/bin/conda' 'shell.zsh' 'hook' 2>/dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "$APP/mambaforge/base/etc/profile.d/conda.sh" ]; then
        . "$APP/mambaforge/base/etc/profile.d/conda.sh"
    else
        export PATH="$APP/mambaforge/base/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<
