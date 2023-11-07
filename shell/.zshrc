#!/bin/zsh
# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/opt/homebrew/Caskroom/mambaforge-cn/base/bin/conda' 'shell.zsh' 'hook' 2>/dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/opt/homebrew/Caskroom/mambaforge-cn/base/etc/profile.d/conda.sh" ]; then
        . "/opt/homebrew/Caskroom/mambaforge-cn/base/etc/profile.d/conda.sh"
    else
        export PATH="/opt/homebrew/Caskroom/mambaforge-cn/base/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

# Oxidizer
export OXIDIZER=${HOME}/oxidizer
source ${OXIDIZER}/oxidizer.sh

export PATH="/opt/homebrew/bin:$PATH"
export PATH="/opt/homebrew/opt/curl/bin:$PATH"
export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"
export PATH="/Applications/MATLAB_R2022b.app/bin:$PATH"

# [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
