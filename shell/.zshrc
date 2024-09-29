# >>> mamba initialize >>>
# !! Contents within this block are managed by 'mamba init' !!
export MAMBA_EXE='/opt/homebrew/bin/micromamba'
export MAMBA_ROOT_PREFIX='/Users/integzz/micromamba'
__mamba_setup="$("$MAMBA_EXE" shell hook --shell zsh --root-prefix "$MAMBA_ROOT_PREFIX" 2>/dev/null)"
if [ $? -eq 0 ]; then
    eval "$__mamba_setup"
else
    alias micromamba="$MAMBA_EXE" # Fallback on help from mamba activate
fi
unset __mamba_setup
# <<< mamba initialize <<<

# Oxidizer
export OXIDIZER=${HOME}/Documents/GitHub/oxidizer
source ${OXIDIZER}/oxidizer.sh

if [[ "$(uname -sm)" = "Darwin arm64" ]]; then
    export PATH="/opt/homebrew/bin:$PATH"
    export CPATH="/opt/homebrew/include"
    export LIBRARY_PATH="/opt/homebrew/lib"
    export PATH="/opt/homebrew/opt/postgresql@16/bin:$PATH"
    export PATH="/Applications/MATLAB_R2023b.app/bin:$PATH"
fi
