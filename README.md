# Usage as a flake

[![FlakeHub](https://img.shields.io/endpoint?url=https://flakehub.com/f/ranokay/dotfiles/badge)](https://flakehub.com/flake/ranokay/dotfiles)

Add dotfiles to your `flake.nix`:

```nix
{
  inputs.dotfiles.url = "https://flakehub.com/f/ranokay/dotfiles/*.tar.gz";

  outputs = { self, dotfiles }: {
    # Use in your outputs
  };
}

```
