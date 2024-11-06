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
    echo -e "\033[34m[INFO]\033[0m Running Nix build to apply dependencies..."
    nix run nix-darwin -- switch --flake .#mbp
    echo -e "\033[32m[SUCCESS]\033[0m Nix dependencies updated and configuration applied."

# Command: Build the Darwin configuration (compiles without switching)
@build:
    {{check-nix-darwin}}
    echo -e "\033[34m[INFO]\033[0m Building Nix-Darwin configuration for 'mbp'..."
    darwin-rebuild build --flake .#mbp
    echo -e "\033[32m[SUCCESS]\033[0m Build completed successfully."

# Command: Apply the Darwin configuration (builds and switches)
@switch:
    {{check-nix-darwin}}
    echo -e "\033[34m[INFO]\033[0m Applying Nix-Darwin configuration for 'mbp'..."
    darwin-rebuild switch --flake .#mbp
    echo -e "\033[32m[SUCCESS]\033[0m Configuration applied successfully."

# Command: Clean of the Darwin switch (useful for previewing changes)
@check:
    {{check-nix-darwin}}
    echo -e "\033[34m[INFO]\033[0m Performing a check of the Nix-Darwin switch..."
    darwin-rebuild check --flake .#mbp
    echo -e "\033[32m[SUCCESS]\033[0m Check completed."

# Command: Clean up outdated generations (optional, for keeping the system lean)
@clean:
    {{check-nix-darwin}}
    echo -e "\033[34m[INFO]\033[0m Cleaning up old Nix generations..."
    nix-collect-garbage -d
    echo -e "\033[32m[SUCCESS]\033[0m Old generations cleaned up."
