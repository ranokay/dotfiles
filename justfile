# Set shell for commands
set shell := ["bash", "-eu", "-o", "pipefail", "-c"]

# Check if Nix-Darwin is installed
check-nix-darwin := """
if ! command -v darwin-rebuild &>/dev/null; then
    echo "Nix-Darwin is not installed. Please install it first by running 'just nix-build'"
    exit 1
fi
"""

# Command: Rebuild using nix run to ensure dependencies are updated
@nix-build:
    nix run nix-darwin -- switch --flake .

# Command: Build the Darwin configuration (compiles without switching)
@build:
    {{check-nix-darwin}}
    darwin-rebuild build --flake .

# Command: Apply the Darwin configuration (builds and switches)
@switch:
    {{check-nix-darwin}}
    darwin-rebuild switch --flake .

# Command: Clean of the Darwin switch (useful for previewing changes)
@check:
    {{check-nix-darwin}}
    darwin-rebuild check --flake .

# Command: Clean up outdated generations (optional, for keeping the system lean)
@clean:
    {{check-nix-darwin}}
    nix-collect-garbage -d

# Command: Update the Nix-Darwin flake
@update:
    {{check-nix-darwin}}
    nix flake update
    echo -e "\033[32m[SUCCESS]\033[0m Flake updated successfully."
    darwin-rebuild switch --flake .

# Command: Update launchpad (from extras module using python)
@launchpad-build:
    defaults write com.apple.dock springboard-columns -int 9
    defaults write com.apple.dock springboard-rows -int 6
    python3 extras/launchpad/cli.py build extras/launchpad/config.yaml

# Command: Extract current launchpad layout to config file
@launchpad-extract:
    python3 extras/launchpad/cli.py extract extras/launchpad/output.yaml

# Command: Compare current launchpad layout with config file
@launchpad-compare:
    python3 extras/launchpad/cli.py compare extras/launchpad/output.yaml
