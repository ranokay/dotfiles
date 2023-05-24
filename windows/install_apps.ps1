# # Sourcing the config file to get the functions
# . .\config_shell.ps1

# RunAsAdmin

# if (UserConfirm "Do you want to install Visual Studio Code?") {
#     InstallWithWinget "Visual Studio Code" "Microsoft.VisualStudioCode"
# }

# if (UserConfirm "Do you want to install Brave Browser?") {
#     InstallWithWinget "Brave Browser" "BraveSoftware.BraveBrowser"
# }

# # Install Chocolatey if it's not already installed
# function InstallChoco ($command) {
# 	if (-not (Get-Command $command -ErrorAction SilentlyContinue)) {
# 		Write-Host "Installing $command" -ForegroundColor Green
# 		[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
# 		try {
# 			iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
# 		} catch {
# 			Write-Host "Failed to install $command. Error: $_" -ForegroundColor Red
# 		}
# 	}
# }

# # Software to be installed with Choco
# $chocoSoftwareList = "choco"
# if (UserConfirm "Do you want to install $chocoSoftwareList?") {
# 	InstallWithChoco $chocoSoftwareList
# }