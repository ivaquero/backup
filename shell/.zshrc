# >>> mamba initialize >>>
# !! Contents within this block are managed by 'mamba shell init' !!
export MAMBA_EXE='/opt/homebrew/opt/micromamba/bin/mamba'
export MAMBA_ROOT_PREFIX='~/mamba'
__mamba_setup="$("$MAMBA_EXE" shell hook --shell zsh --root-prefix "$MAMBA_ROOT_PREFIX" 2>/dev/null)"
if [ $? -eq 0 ]; then
    eval "$__mamba_setup"
else
    alias mamba="$MAMBA_EXE" # Fallback on help from mamba activate
fi
unset __mamba_setup
# <<< mamba initialize <<<
# Oxidizer

case $(uname -a) in
*Darwin* | *Ubuntu* | *Debian*)
    export HOMEBREW_NO_AUTO_UPDATE=1
    export HOMEBREW_NO_AUTOREMOVE=1
    export HOMEBREW_NO_ENV_HINTS=1
    export HOMEBREW_CLEANUP_MAX_AGE_DAYS="3"
    ;;
esac

export OXIDIZER=${HOME}/Documents/GitHub/oxidizer
source ${OXIDIZER}/oxidizer.sh
export GENVIRON=${HOME}/Documents/GitHub/genviron

if [[ "$(uname -sm)" == "Darwin arm64" ]]; then
    export PATH="/opt/homebrew/bin:$PATH"
    export CPATH="/opt/homebrew/include"
    export LIBRARY_PATH="/opt/homebrew/lib"
    export PATH="/opt/homebrew/opt/postgresql@17/bin:$PATH"
    export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"
    export PATH="/Applications/MATLAB_R2023b.app/bin:$PATH"
fi

export VCPKG_ROOT="$HOME/vcpkg"
export PATH=$PATH:$VCPKG_ROOT
export VCPKG_BINARY_SOURCES=clear
source "$HOME/vcpkg/scripts/vcpkg_completion.zsh"

if ! command -v podman >/dev/null 2>&1; then
    export DOCKER_HOST='unix:///var/folders/py/n14256yd5r5ddms88x9bvsv40000gn/T/podman/podman-machine-default-api.sock'
fi
