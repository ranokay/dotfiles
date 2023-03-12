# Oxy Dotfiles (Still in development)

Dotfiles are hidden configuration files for command-line shells like bash, zsh, and PowerShell. They usually contain aliases, environment variables, and other custom settings that personalize your command-line experience.

This repository contains my personal dotfiles for both Linux and Windows. Feel free to use them as a starting point for your own configuration.

## Installation

To install the dotfiles, clone this repository to your home directory and run the install script. The install script will create symbolic links from the dotfiles in this repository to your home directory. It will also prompt you to overwrite any existing dotfiles, so be careful. If you want to keep your existing dotfiles, you can copy the contents of the dotfiles in this repository into your existing dotfiles.

This script will also install the following packages:

- [Oh My Zsh](

- [Nerd Fonts](https://www.nerdfonts.com/) (Cooming soon)

- [Chocolatey](https://chocolatey.org/) (Windows only)

- [Starship](https://starship.rs/) (Both Linux and Windows)

- [zsh-autosuggestions](

### Linux

1. Clone the repository to your home directory:

   ```bash
   git clone
   ```

2. Run the install script:

   ```bash
   ./install.sh
   ```

3. Restart your terminal.
   ```bash
    source ~/.bashrc
   ```

### Windows

1. Clone the repository to your home directory:

   ```powershell
   git clone
   ```

   2. Run the install script:

   ```powershell
   .\install.ps1
   ```

2. Restart your terminal:
   ```powershell
    . $PROFILE
   ```

## Configuration

### Linux

You can customize your dotfiles by editing the files in the ~/oxy-dotfiles directory. Here are some examples of what you can do:

- Add new aliases to `bash_aliases`, `zsh_aliases`, or `powershell_aliases`.
- Set environment variables in `bash_env`, `zsh_env`, or `powershell_env`.

After making changes to your dotfiles, you'll need to reload your shell to see the changes take effect. You can do this by typing `source ~/.bashrc`, `source ~/.zshrc`, or `. $PROFILE` depending on your shell.

### Windows

You can customize your dotfiles by editing the files in the ~/oxy-dotfiles directory. Here are some examples of what you can do:

- Add new aliases to `powershell_aliases`.
- Set environment variables in `powershell_env`.

After making changes to your dotfiles, you'll need to reload your shell to see the changes take effect. You can do this by typing `. $PROFILE` depending on your shell.

## Disclaimer

Use these dotfiles at your own risk. I am not responsible for any damage they may cause to your system.
