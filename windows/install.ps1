# Open as administrator
# Run: powershell -ExecutionPolicy Bypass -File install.ps1

# Check if running as administrator
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
		Write-Host "Please run as administrator" -ForegroundColor Red
		exit
}

# Check if .bashrc exists and remove it
if (Test-Path $HOME\.bashrc) {
		Write-Host "Removing .bashrc" -ForegroundColor Yellow
		Remove-Item $HOME\.bashrc
}

# Check if .bash_profile exists and remove it
if (Test-Path $HOME\.bash_profile) {
		Write-Host "Removing .bash_profile" -ForegroundColor Yellow
		Remove-Item $HOME\.bash_profile
}

# Check if .wslconfig exists and remove it
if (Test-Path $HOME\.wslconfig) {
		Write-Host "Removing .wslconfig" -ForegroundColor Yellow
		Remove-Item $HOME\.wslconfig
}

# Check if .gitconfig exists and remove it
if (Test-Path $HOME\.gitconfig) {
		Write-Host "Removing .gitconfig" -ForegroundColor Yellow
		Remove-Item $HOME\.gitconfig
}

# Install starship with winget if not installed
if (-not (Get-Command starship -ErrorAction SilentlyContinue)) {
		Write-Host "Installing starship" -ForegroundColor Green
		winget install --id Starship.Starship
}


# Check if .config\starship.toml exists and remove it
if (Test-Path $HOME\.config\starship.toml) {
		Write-Host "Removing .config\starship.toml" -ForegroundColor Yellow
		Remove-Item $HOME\.config\starship.toml
}

# Check if Microsoft.PowerShell_profile.ps1 exists and remove it
if (Test-Path $HOME\OneDrive\Documents\PowerShell\Microsoft.PowerShell_profile.ps1) {
		Write-Host "Removing Microsoft.PowerShell_profile.ps1" -ForegroundColor Yellow
		Remove-Item $HOME\OneDrive\Documents\PowerShell\Microsoft.PowerShell_profile.ps1
}

# Install Chocolatey if not installed
if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
		Write-Host "Installing Chocolatey" -ForegroundColor Green
		Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
}

# Install Terminal-Icons modeule if not installed
if (-not (Get-Module Terminal-Icons -ErrorAction SilentlyContinue)) {
		Write-Host "Installing Terminal-Icons" -ForegroundColor Green
		Install-Module -Name Terminal-Icons -Repository PSGallery
}

# Install z if not installed
if (-not (Get-Module z -ErrorAction SilentlyContinue)) {
		Write-Host "Installing z" -ForegroundColor Green
		Install-Module -Name z -Repository PSGallery
}

# Create simlinks
Write-Host "Creating simlinks" -ForegroundColor Green
New-Item -ItemType SymbolicLink -Path $HOME\.bashrc -Value $HOME\oxy-dotfiles\windows\.bashrc
New-Item -ItemType SymbolicLink -Path $HOME\.bash_profile -Value $HOME\oxy-dotfiles\windows\.bash_profile
New-Item -ItemType SymbolicLink -Path $HOME\.wslconfig -Value $HOME\oxy-dotfiles\windows\.wslconfig
New-Item -ItemType SymbolicLink -Path $HOME\.gitconfig -Value $HOME\oxy-dotfiles\.gitconfig
New-Item -ItemType SymbolicLink -Path $HOME\.config\starship.toml -Value $HOME\oxy-dotfiles\.config\starship.toml
New-Item -ItemType SymbolicLink -Path $HOME\OneDrive\Documents\PowerShell\Microsoft.PowerShell_profile.ps1 -Value $HOME\oxy-dotfiles\windows\PowerShell\Microsoft.PowerShell_profile.ps1
