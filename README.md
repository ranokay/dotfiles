# Highlights

- ❄️ Nix flakes handle upstream dependencies and track Nixpkgs unstable
- 🏠 [home-manager](https://github.com/nix-community/home-manager) manages
  dotfiles
- 🍎 [nix-darwin](https://github.com/LnL7/nix-darwin) manages MacBook
- 🤫 [sops-nix](https://github.com/Mic92/sops-nix) manages secrets
- 🌬️ Root on tmpfs aka
  [impermanence](https://grahamc.com/blog/erase-your-darlings/)
- 🔒 Automatic Let's Encrypt certificate registration and renewal
- 🧩 Tailscale, Nextcloud, among other nice
  self-hosted applications
- ⚡️ `justfile` contains useful aliases for many frequent and atrociously long
  `nix` commands
- 🤖 `flake.lock` updated daily via GitHub Action, servers are configured to
  automatically upgrade daily via
  [`modules/nixos/auto-update.nix`](https://github.com/ranokay/dotfiles/blob/main/modules/nixos/auto-update.nix)
- 🧱 Modular architecture promotes readability for me and copy-and-paste-ability
  for you
- 📦
  [Custom ready-made tarball and ISO](https://github.com/ranokay/dotfiles/releases)
  for installing NixOS

## Getting started

### macOS

On macOS, this script will install `nix` using the
[Determinate Systems Nix installer](https://zero-to-nix.com/start/install) and
prompt you to install my configuration.

> [!IMPORTANT]
> You'll need to run this script as sudo or have sudo permissions.

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/ranokay/dotfiles/main/install.sh)"
```

### NixOS (Linux)

> [!IMPORTANT]
> You'll need to run this script as sudo or have sudo permissions.
> [!WARNING]
> This script is primarily meant for my own use. Using it to install
> NixOS on your own hardware will fail. At minimum, you'll need to do the
> following before attemping installation:
>
> 1. Create a configuration for your own device in the `machines/` folder
> 1. Retool your own sops-nix secrets or remove them entirely if you don't use
>    sops-nix
> 1. Add an entry to flake.nix referencing the configuration created in step 1

On Linux, _running this script from the NixOS installation ISO_ will prepare
your system for NixOS by partitioning drives and mounting them.

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/ranokay/dotfiles/main/install.sh)"
```

> [!TIP]
> When installing NixOS onto a headless local server, place your own
> custom NixOS ISO file onto a USB drive with Ventoy.
> and you can enable connectivity by building your own custom ISO with your own
> personal SSH key.
> [The custom ISO released in this repo](https://github.com/ranokay/dotfiles/releases)
> is baked with my own key.

## Useful commands 🛠️

Install `just` to access the simple aliases below

### Locally deploy changes

```bash
just deploy macos
```

```bash
just deploy MACHINE
```

### Remote deployment

To remotely deploy `MACHINE`, which has an IP address of `10.0.10.2`

```bash
just deploy MACHINE 10.0.10.2
```

### Edit secrets

Make sure each machine's public key is listed as entry in `.sops.yaml`. To
modify `secrets/secrets.yaml`:

```bash
just secrets-edit
```

### Syncing sops keys for a new machine

```bash
just secrets-sync
```

## Important caveats

### Changing user passwords

To modify user password, first generate a hash

```bash
echo "password" | mkpasswd -m SHA-512 -s
```

Then run `just edit-secrets` to replace the existing decrypted hash with the one
that you just generated. If you use a password manager, sure to update the new
password as necessary.

### Changing SSH keys

Make sure you update the public key as it appears across the repository.

### Installation source

Make sure the Determinate Nix installer one-liner in `install.sh` is consistent
with how it appears on the official website.

## To-do

1. [Secure boot](https://github.com/nix-community/lanzaboote)
2. Binary caching
3. [Wireless remote unlocking](https://discourse.nixos.org/t/wireless-connection-within-initrd/38317/13)
