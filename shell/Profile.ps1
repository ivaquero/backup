$env:BASE = $env:HOME

if ( [string]::IsNullOrEmpty($env:OXIDIZER) ) { 
    $env:OXIDIZER = "$env:BASE/oxidizer"
}
. $env:OXIDIZER/oxidizer.ps1
