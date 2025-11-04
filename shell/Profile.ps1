# Oxidizer
. $HOME\oxidizer\oxidizer.ps1

if (Get-Command scoop -ErrorAction SilentlyContinue ) {
    Import-Module scoop-completion
    Invoke-Expression (&scoop-search --hook)
}

# #region mamba initialize
# !! Contents within this block are managed by 'mamba shell init' !!
$Env:MAMBA_ROOT_PREFIX = "$HOME\micromamba"
$Env:MAMBA_EXE = 'C:\Scoop\apps\micromamba\shims\micromamba.exe'
(& $Env:MAMBA_EXE 'shell' 'hook' -s 'powershell' -r $Env:MAMBA_ROOT_PREFIX) | Out-String | Invoke-Expression
# #endregion

##########################################################
# basic settings
##########################################################

# default editor, can be changed by function `ched()`
$env:EDITOR = 'code'
# terminal editor
$env:EDITOR_T = 'vi'

##########################################################
# common aliases
##########################################################

# shortcuts
function .. { cd .. }
function ... { cd ../.. }
function cat { bat $args }
function ls { lsd $args }
function ll { lsd -l $args }
function la { lsd -a $args }
function lla { lsd -la $args }
function e { echo $args }
function rr { rm -rf $args }
function c { clear }

# tools
Remove-Item alias:man -Force -ErrorAction SilentlyContinue
function man { tldr $args }
function g { git $args }
function hf { hyperfine $args }
function ff { fastfetch $args }

# oxidizer
# export config
function epf { oxf $args }
# import config
function ipf { rdf $args }
# initialize config
function iif { clzf $args }

##########################################################
# conda settings
##########################################################

function b { ceq; ceat b; clear }
function k { ceq; ceat k; clear }
function s { ceq; ceat s; clear }
function r { ceq; ceat r; clear }
function q { ceq }

##########################################################
# typst
##########################################################

$Global:OX_TYPST_PATH = @{
    dy = 'D:/GitHub/book-math/book-dynamics'
    la = 'D:/GitHub/book-math/book-linear-algebra'
    pr = 'D:/GitHub/book-math/book-probability'
    ct = 'D:/GitHub/book-engine/book-control'
    tk = 'D:/GitHub/book-engine/book-tracking'
    rd = 'D:/GitHub/book-engine/book-radar'
    lr = 'D:/GitHub/lang-romance'
    ls = 'D:/GitHub/lang-slavic'
    ns = 'D:/GitHub/notes'
}

function typbook() {
    echo "Compiling typst files in $Global:OX_TYPST_PATH[$args[0]]}"
    foreach ($file in "$Global:OX_TYPST_PATH[$args[0]]}/*.typ") {
        bname=$(basename "$file")
        typst compile --format pdf "$file" "$Global:OX_TYPST_PATH[$args[0]]}/articles/${bname%%.*}.pdf"
    }

    switch ($args.Count) {
        2 { pdfcpu merge "${OX_DOWNLOAD}"/a.pdf "$Global:OX_TYPST_PATH[$args[0]]}/articles/$args[1]"*.pdf }
        3 { pdfcpu merge "${OX_DOWNLOAD}"/a.pdf "$Global:OX_TYPST_PATH[$args[0]]}/articles/$args[1]"*.pdf "$Global:OX_TYPST_PATH[$args[0]]}/articles/$3"*.pdf }
        4 {
            pdfcpu merge "${OX_DOWNLOAD}"/a.pdf "$Global:OX_TYPST_PATH[$args[0]]}/articles/$args[1]"*.pdf "$Global:OX_TYPST_PATH[$args[0]]}/articles/$3"*.pdf "$Global:OX_TYPST_PATH[$args[0]]}/articles/$4"*.pdf
        }
        Default { pdfcpu merge "${OX_DOWNLOAD}"/a.pdf "$Global:OX_TYPST_PATH[$args[0]]}/articles/"*.pdf }
    }
}

##########################################################
# vcpkg
##########################################################

if (Get-Command vcpkg -ErrorAction SilentlyContinue ) {
    Import-Module 'C:\Scoop\apps\vcpkg\current\scripts\posh-vcpkg'
    $env:VCPKG_ROOT = "$HOME\vcpkg"
    $env:PATH = "$env:VCPKG_ROOT;$env:PATH"
    $env:VCPKG_FEATURE_FLAG = '-binarycaching'
}

##########################################################
# notes apps
##########################################################

$Global:OX_OXIDIAN = 'D:\GitHub\notes'
