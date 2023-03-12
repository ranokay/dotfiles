Import-Module -Name Terminal-Icons
Import-Module -Name z

$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
	Import-Module "$ChocolateyProfile"
}

function gs { git status $args }
function gcmt { git commit -m $args }
function gaa { git add . }
function gpull { git pull }
function gpush { git push }
function gcl { git clone $args }
function gup { git update-git-for-windows }
function pn {	pnpm $args }
function pni { pnpm install $args }
function pnu { pnpm uninstall $args }
function pnup { pnpm up }
function pnd { pnpm dev $args }
function c { clear }

Invoke-Expression (&starship init powershell)