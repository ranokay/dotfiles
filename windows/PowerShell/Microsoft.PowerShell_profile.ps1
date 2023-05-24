if (Get-Module -ListAvailable -Name Terminal-Icons) {
	Import-Module -Name Terminal-Icons
}

if (Get-Module -ListAvailable -Name z) {
	Import-Module -Name z
}


$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
	Import-Module "$ChocolateyProfile"
}

function c { clear }
function h { history }
function e { exit }
function .. { cd .. }
function ... { cd ..\.. }
function .... { cd ..\..\.. }
function gs { git status $args }
function gcmt { git commit -m $args }
function gaa { git add . }
function gpull { git pull }
function gpush { git push }
function gcl { git clone $args }
function gup { git update-git-for-windows }
function pn {	pnpm $args }
function y { yarn $args }
function n { npm $args }
function d { docker $args }
function dc { docker-compose $args }

# Invoke starship prompt if available
if (Get-Command starship.exe -ErrorAction SilentlyContinue) {
	Invoke-Expression (&starship init powershell)
}

# Invoke fnm if available
if (Get-Command fnm.exe -ErrorAction SilentlyContinue) {
	Invoke-Expression (&fnm env --use-on-cd | Out-String)
}