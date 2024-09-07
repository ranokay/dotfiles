default:
  just --list

deploy machine ip='':
  #!/usr/bin/env sh
  if [ {{machine}} = "macos" ]; then
    darwin-rebuild switch --flake .
  elif [ -z "{{ip}}" ]; then
    sudo nixos-rebuild switch --fast --flake ".#{{machine}}"
  else
    nixos-rebuild switch --fast --flake ".#{{machine}}" --use-remote-sudo --target-host "ranokay@{{ip}}" --build-host "ranokay@{{ip}}"
  fi

up:
  nix flake update

lint:
  statix check .

gc:
  sudo nix profile wipe-history --profile /nix/var/nix/profiles/system --older-than 7d && sudo nix store gc

repair:
  sudo nix-store --verify --check-contents --repair

secrets-edit:
  sops secrets/secrets.yaml

secrets-rotate:
  for file in secrets/*; do sops --rotate --in-place "$file"; done

secrets-sync:
  for file in secrets/*; do sops updatekeys "$file"; done

build-iso:
  nix build .#nixosConfigurations.iso1chng.config.system.build.isoImage