##########################################################
# common aliases
##########################################################

# shortcuts
function cat { bat $args }
function ls { lsd $args }
function ll { lsd -l $args }
function la { lsd -a $args }
function lla { lsd -la $args }
function e { echo $args }
function rr { rm -rf $args }
function c { clear }

# tools
function man { tldr $args }
function hf { hyperfine $args }

##########################################################
# powershell
##########################################################

function tt { hyperfine --warmup 3 --shell powershell '. $PROFILE' }

##########################################################
# startup & daily commands
##########################################################

# donwload path
$env:OX_DOWNLOAD = "$HOME\Desktop"


##########################################################
# Zoxide
##########################################################

$_ZO_DATA_DIR = "$env:LOCALAPPDATA\zoxide"

if (!(Test-Path -Path $_ZO_DATA_DIR)) {
    mkdir "$_ZO_DATA_DIR"
}

function zh { zoxide --help }
function zii { zoxide init $args }
function za { zoxide add $args }
function zrm { zoxide remove $args }
function zed { zoxide edit $args }
function zsc { zoxide query $args }

Invoke-Expression (& { $hook = if ($PSVersionTable.PSVersion.Major -ge 6) { 'pwd' } else { 'prompt' } (zoxide init powershell --hook $hook | Out-String) })

# starship
Invoke-Expression (&starship init powershell)
