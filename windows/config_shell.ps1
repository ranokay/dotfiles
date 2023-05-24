# Ensure the script is run as an Administrator
function RunAsAdmin {
	if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
		Write-Host "Please run as administrator" -ForegroundColor Red
		exit
	}
}

# Remove a file or directory if it exists
function RemoveItemIfExists ($path, $message) {
	if (Test-Path $path) {
		Write-Host $message -ForegroundColor Yellow
		try {
			Remove-Item $path -ErrorAction Stop
		} catch {
			Write-Host "Failed to remove $path. Error: $_" -ForegroundColor Red
		}
	}
}

# Backup a file or directory if it exists
function BackupItemIfExists ($path, $message) {
	if (Test-Path $path) {
		Write-Host $message -ForegroundColor Yellow
		try {
			$backupPath = $path + ".backup"
			Copy-Item $path $backupPath -ErrorAction Stop
		} catch {
			Write-Host "Failed to backup $path. Error: $_" -ForegroundColor Red
		}
	}
}

# Install a software using winget if it's not already installed
function InstallWithWinget ($command, $id) {
	if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
		Write-Host "winget command not found. Please install winget first" -ForegroundColor Red
		exit
	}
	if (-not (Get-Command $command -ErrorAction SilentlyContinue)) {
		Write-Host "Installing $command" -ForegroundColor Green
		try {
			winget install -e --id $id
		} catch {
			Write-Host "Failed to install $command. Error: $_" -ForegroundColor Red
		}
	}

	if (Get-Command $command -ErrorAction SilentlyContinue) {
		Write-Host "$command successfully installed." -ForegroundColor Green
	}
}

# Install a PowerShell module if it's not already installed
function InstallModule ($name) {
	if (-not (Get-Module $name -ErrorAction SilentlyContinue)) {
		Write-Host "Installing $name" -ForegroundColor Green
		try {
			Install-Module -Name $name -Repository PSGallery
			Import-Module $name -ErrorAction Stop
		} catch {
			Write-Host "Failed to install and import $name. Error: $_" -ForegroundColor Red
		}
	}

	if (Get-Module $name -ErrorAction SilentlyContinue) {
		Write-Host "$name successfully installed." -ForegroundColor Green
	}
}

# Create a directory if it doesn't exist
function CreateDirectoryIfNotExists ($path) {
	if (-not (Test-Path $path)) {
		try {
			New-Item -ItemType Directory -Path $path -Force
		} catch {
			Write-Host "Failed to create directory $path. Error: $_" -ForegroundColor Red
		}
	}
}

# Create a symbolic link
function CreateSymlink ($source, $destination) {
	try {
		New-Item -ItemType SymbolicLink -Path $destination -Value $source -Force
	} catch {
		Write-Host "Failed to create symbolic link from $source to $destination. Error: $_" -ForegroundColor Red
	}

	if (Test-Path $destination) {
		Write-Host "Successfully created symbolic link for $destination" -ForegroundColor Green
	}
}

# Display item selection menu and return selection
function ItemSelection ($array, $message) {
	if ($array.Count -eq 0) { return }
	while ($true) {
		Write-Host "`n$message" -ForegroundColor Yellow
		Write-Host "0. Cancel" -ForegroundColor Red
		Write-Host "$(if ($array.Count -gt 1) {"a. All"})" -ForegroundColor Green

		for ($i = 0; $i -lt $array.Count; $i++) {
			Write-Host ("$(($i + 1)). " + $array[$i]) -ForegroundColor Cyan
		}

		$selectionStrings = (Read-Host "Select one or more options (separated by space)") -split ' '

		if ($selectionStrings -contains "a") { return $array }
		elseif ($selectionStrings -contains "0") { break }
		else {
			$selectedItems = $selectionStrings | ForEach-Object {
				if ($_ -match '^\d+$' -and [int]$_ -le $array.Count -and [int]$_ -gt 0) { $array[[int]$_ - 1] }
			}

			if ($selectedItems -ne $null -and $selectedItems.Count -gt 0) { return $selectedItems }
			else { Write-Host "Invalid selection. Please try again." -ForegroundColor Yellow }
		}
	}
}


RunAsAdmin

# Determine the path for the Documents folder
$DOCUMENTS_PATH = "$HOME\OneDrive\Documents"
if (!(Test-Path $DOCUMENTS_PATH)) {
	$DOCUMENTS_PATH = "$HOME\Documents"
}

# Define the paths to check
$pathsToCheck = @("$HOME\.bashrc", "$HOME\.bash_profile", "$HOME\.wslconfig", "$HOME\.config\starship.toml", "$DOCUMENTS_PATH\PowerShell\Microsoft.PowerShell_profile.ps1", "$HOME\.aliases")

# Backup and remove files if they exist
$selectedPaths = ItemSelection $pathsToCheck "Which paths would you like to backup?"
foreach ($path in $selectedPaths) {
	BackupItemIfExists $path "Backing up $path"
	RemoveItemIfExists $path "Removing $path"
}

# Software to be installed with Winget
$softwareList = @(
	@{Name = "PowerShell 7"; Command = "pwsh"; ID = "Microsoft.PowerShell"},
	@{Name = "Git"; Command = "git"; ID = "Git.Git"},
	@{Name = "Fnm"; Command = "fnm"; ID = "Schniz.fnm"},
	@{Name = "Starship"; Command = "starship"; ID = "Starship.Starship"}
)

$selectedSoftware = ItemSelection ($softwareList | ForEach-Object {$_.Name}) "Which software would you like to install?"
foreach ($software in $softwareList) {
	if ($software.Name -in $selectedSoftware) {
	InstallWithWinget $software.Command $software.ID
	}
}

# Modules to be installed
$moduleList = @("Terminal-Icons", "z")
$selectedModules = ItemSelection $moduleList "Which modules would you like to install?"
foreach ($moduleName in $selectedModules) {
	InstallModule $moduleName
}

# Define current and common directories
$CURRENT_DIR = (Get-Location).Path
$COMMON_DIR = (Get-Item -Path $CURRENT_DIR\..\common).FullName

# Ensure the parent directory for the PowerShell profile exists
$POWERSHELL_PROFILE_DIRECTORY = "$DOCUMENTS_PATH\PowerShell"
CreateDirectoryIfNotExists $POWERSHELL_PROFILE_DIRECTORY

# Define the symlinks to create
$symlinks = @{
	"$HOME\.bashrc" = "$CURRENT_DIR\.bashrc"
	"$HOME\.bash_profile" = "$CURRENT_DIR\.bash_profile"
	"$HOME\.wslconfig" = "$CURRENT_DIR\.wslconfig"
	"$HOME\.config\starship.toml" = "$COMMON_DIR\.config\starship.toml"
	"$DOCUMENTS_PATH\PowerShell\Microsoft.PowerShell_profile.ps1" = "$CURRENT_DIR\PowerShell\Microsoft.PowerShell_profile.ps1"
	"$HOME\.aliases" = "$COMMON_DIR\.aliases"
}

# Ensure the .config directory exists
CreateDirectoryIfNotExists "$HOME\.config"

# Let the user choose to create symlinks
$selectedSymlinks = ItemSelection ($symlinks.Keys | ForEach-Object { Split-Path -Path $_ -Leaf }) "Which files would you like to create symlinks for?"
foreach ($source in $symlinks.Keys) {
	if ((Split-Path -Path $source -Leaf) -in $selectedSymlinks) {
		CreateSymlink $symlinks[$source] $source | Out-Null
	}
}
