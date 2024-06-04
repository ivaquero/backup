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
export OXIDIZER=${HOME}/Documents/GitHub/oxidizer
source ${OXIDIZER}/oxidizer.sh

if [[ "$(uname -sm)" = "Darwin arm64" ]]; then
    export PATH="/opt/homebrew/bin:$PATH"
    export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"
    export CPATH="/opt/homebrew/include"
    export LIBRARY_PATH="/opt/homebrew/lib"
    export CPPFLAGS="-I/opt/homebrew/opt/openblas/include"
    export LDFLAGS="-L/opt/homebrew/opt/openblas/lib"
    export PATH="/Applications/MATLAB_R2023b.app/bin:$PATH"
fi
