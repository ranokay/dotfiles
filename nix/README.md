# Nix Configuration

A modern, modular Nix configuration supporting multiple machines (macOS and NixOS) with easy extensibility.

## 🚀 Quick Start for New Users

**New to this configuration?** Choose your installation method:

**Full Setup (Recommended):**

```bash
curl -fsSL https://raw.githubusercontent.com/ranokay/dotfiles/main/install.sh | bash
```

**Quick Bootstrap:**

```bash
curl -fsSL https://raw.githubusercontent.com/ranokay/dotfiles/main/bootstrap.sh | bash
```

📖 **See [INSTALL.md](../INSTALL.md) for detailed installation instructions**

## Features

- 🏗️ **Modular architecture** with profiles and host-specific configurations
- 🍎 **macOS support** via nix-darwin with sensible defaults
- 🐧 **NixOS support** ready for servers and desktops
- 🏠 **Home Manager integration** with profile-based user configurations
- 🚀 **Determinate Systems** integration for better performance
- 📦 **Easy package management** with organized profiles
- 🔧 **Development environments** with language-specific tooling
- 🛠️ **Simple management** with Just commands

## Structure

```
nix/
├── flake.nix              # Main flake configuration
├── Justfile               # Management commands
├── hosts/                 # Host-specific configurations
│   ├── mbp/              # MacBook Pro configuration
│   └── example-server/   # Example server configuration
├── profiles/             # Reusable system profiles
│   ├── base/             # Common settings for all systems
│   ├── darwin/           # macOS-specific settings
│   └── nixos/            # NixOS-specific settings
└── home/                 # Home Manager configurations
    ├── profiles/         # User environment profiles
    │   ├── base/         # Base user environment
    │   ├── darwin/       # macOS user settings
    │   ├── development/  # Development tools and aliases
    │   └── server/       # Server-focused minimal setup
    ├── core/             # Core program configurations
    ├── git.nix           # Git configuration
    ├── starship.nix      # Shell prompt configuration
    └── zsh.nix           # Zsh shell configuration
```

## Quick Start

### Prerequisites

1. Install Nix with flakes enabled:

   ```bash
   curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
   ```

2. Install Just (task runner):

   ```bash
   nix profile install nixpkgs#just
   ```

### Initial Setup

1. Clone your dotfiles and navigate to the nix directory:

   ```bash
   cd ~/dotfiles/nix
   ```

2. Check available commands:

   ```bash
   just
   ```

3. Build and apply the configuration:

   ```bash
   just rebuild
   ```

## Usage

### System Management

| Command | Description |
|---------|-------------|
| `just rebuild` | Build and switch to current system configuration |
| `just darwin` | Build and switch Darwin configuration |
| `just nixos` | Build and switch NixOS configuration |
| `just check` | Check flake for errors |
| `just fmt` | Format all Nix files |

### Flake Management

| Command | Description |
|---------|-------------|
| `just up` | Update all flake inputs |
| `just upp <input>` | Update specific input |
| `just info` | Show flake information |

### System Information

| Command | Description |
|---------|-------------|
| `just history` | List system generations |
| `just current` | Show current system path |
| `just store-size` | Show Nix store disk usage |

### Cleanup

| Command | Description |
|---------|-------------|
| `just clean` | Remove old generations |
| `just gc` | Garbage collect unused packages |
| `just optimize` | Optimize Nix store |

## Adding New Machines

### Method 1: Using the Helper Command

```bash
just new-host myserver
```

This will guide you through creating a new host configuration.

### Method 2: Manual Setup

1. Create a new host directory:

   ```bash
   mkdir -p hosts/myserver
   ```

2. Create the host configuration:

   ```nix
   # hosts/myserver/default.nix
   { lib, pkgs, username, email, hostname, ... }: {
     # Host-specific configuration here
     networking.hostName = hostname;

     # Add host-specific services, packages, etc.
   }
   ```

3. Add to `flake.nix`:

   ```nix
   # For Darwin systems
   darwinConfigurations = nixpkgs.lib.mkMerge [
     (mkSystem {
       hostname = "myserver";
       system = "aarch64-darwin";
       homeModules = [ ./home/profiles/development ];
     })
   ];

   # For NixOS systems
   nixosConfigurations = nixpkgs.lib.mkMerge [
     (mkSystem {
       hostname = "myserver";
       system = "x86_64-linux";
       homeModules = [ ./home/profiles/server ];
     })
   ];
   ```

## Profiles

### System Profiles

- **`profiles/base`**: Common settings for all systems (Nix config, users)
- **`profiles/darwin`**: macOS-specific settings (system defaults, Homebrew)
- **`profiles/nixos`**: NixOS-specific settings (services, hardware)

### Home Profiles

- **`home/profiles/base`**: Essential user environment (shell, git, basic tools)
- **`home/profiles/darwin`**: macOS user settings and aliases
- **`home/profiles/development`**: Development tools and environment
- **`home/profiles/server`**: Minimal server-focused setup

## Customization

### Adding System Packages

Add packages to the appropriate profile:

```nix
# profiles/darwin/default.nix
environment.systemPackages = with pkgs; [
  your-package-here
];
```

### Adding User Packages

Add packages to home profiles:

```nix
# home/profiles/development/default.nix
home.packages = with pkgs; [
  your-development-tool
];
```

### Adding Homebrew Casks (macOS only)

```nix
# profiles/darwin/homebrew.nix
homebrew.casks = [
  "your-app-here"
];
```

### Creating Custom Profiles

1. Create a new profile directory:

   ```bash
   mkdir -p profiles/gaming
   ```

2. Create the profile:

   ```nix
   # profiles/gaming/default.nix
   { pkgs, ... }: {
     # Gaming-specific configuration
     programs.steam.enable = true;

     environment.systemPackages = with pkgs; [
       discord
       obs-studio
     ];
   }
   ```

3. Import in your host configuration or add to `flake.nix`.

## Configuration Examples

### Example: Development MacBook

```nix
# In flake.nix
(mkSystem {
  hostname = "dev-mbp";
  system = "aarch64-darwin";
  homeModules = [
    ./home/profiles/development
    ./home/profiles/darwin
  ];
})
```

### Example: Production Server

```nix
# In flake.nix
(mkSystem {
  hostname = "prod-server";
  system = "x86_64-linux";
  homeModules = [
    ./home/profiles/server
  ];
})
```

## Best Practices

1. **Keep host configs minimal**: Put shared configuration in profiles
2. **Use profiles for grouping**: Create profiles for different use cases
3. **Version control everything**: All configuration is declarative and versioned
4. **Test before deploying**: Use `just check` and dry-run commands
5. **Regular updates**: Keep flake inputs updated with `just up`
6. **Clean up regularly**: Use `just gc` to free disk space

## Troubleshooting

### Common Issues

1. **Build failures**: Run `just check` to identify issues
2. **Permission errors**: Ensure proper sudo access for system operations
3. **Flake lock issues**: Try `just up` to update inputs
4. **Darwin rebuild fails**: Check TouchID is enabled for sudo

### Getting Help

1. Check the Nix manual: <https://nixos.org/manual/nix/stable/>
2. Darwin options: <https://daiderd.com/nix-darwin/manual/index.html>
3. Home Manager options: <https://nix-community.github.io/home-manager/options.html>

## Contributing

1. Keep the modular structure
2. Test configurations before committing
3. Document any new profiles or significant changes
4. Follow the existing naming conventions
