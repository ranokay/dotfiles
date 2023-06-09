# Oh My Zsh + Starship + Nerd Fonts (wip)

This repository contains my personal dotfiles for both Linux and Windows command-line shells like bash, zsh, and PowerShell. Feel free to use them as a starting point for your own configuration.

## Installation

To install the dotfiles, clone this repository to your home directory and run the install script. The install script will create symbolic links from the dotfiles in this repository to your home directory. It will also prompt you to overwrite any existing dotfiles, so be careful. If you want to keep your existing dotfiles, you can copy the contents of the dotfiles in this repository into your existing dotfiles.

You'll need to install at least one of the [Nerd Fonts](https://www.nerdfonts.com/font-downloads) to use the icons in the prompt. I recommend using `Fira Code Nerd Font` or `Caskaydia Cove Nerd Font`.

### Linux

1. Clone the repository to your home directory and go to the linux directory:

   ```bash
   cd dotfiles/linux
   ```

2. Run the install script:

   First, make the install script executable:

   ```bash
   chmod +x install.sh
   ```

   Then, run the install script:

   ```bash
   ./install.sh
   ```

3. Restart your terminal.

   ```bash
    source ~/.bashrc
   ```

   or if you are using zsh

   ```bash
    source ~/.zshrc
   ```

This script will also install the following packages if they are not already installed:

- [Oh My Zsh](https://ohmyz.sh/)
- [Starship](https://starship.rs/)
- [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions)
- [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting)
- [exa](https://the.exa.website/) (You may need to introduce the sudo password to install this package.)

### Windows

1. Clone the repository to your home directory and move to the windows directory:

   ```powershell
   git clone https://github.com/ranokay/dotfiles.git
   cd dotfiles/windows
   ```

2. Run the install script:

   ```powershell
   .\install.ps1
   ```

   if you get an error about the execution policy, you can run the following command to allow the execution of scripts:

   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```

3. Restart your terminal:

   ```powershell
    . $PROFILE
   ```

This script will also install the following packages if they are not already installed:

- [Starship](https://starship.rs/)

## Configuration

### Linux

You can customize your dotfiles by editing the files in the ~/dotfiles directory. Here are some examples of what you can do:

- Add new aliases to `bash_aliases`, `zsh_aliases`.
- Set environment variables in `bash_env`, `zsh_env`.

After making changes to your dotfiles, you'll need to reload your shell to see the changes take effect. You can do this by typing `source ~/.bashrc`, `source ~/.zshrc`, or `. $PROFILE` depending on your shell.

### Windows

You can customize your dotfiles by editing the files in the ~/oxy-dotfiles directory. Here are some examples of what you can do:

- Add new aliases to `powershell_aliases`.
- Set environment variables in `powershell_env`.

After making changes to your dotfiles, you'll need to reload your shell to see the changes take effect. You can do this by typing `. $PROFILE` depending on your shell.

## Nix, Flakes and Home Manager

Cooming soon...

## Disclaimer

Use these dotfiles at your own risk. I am not responsible for any damage they may cause to your system.
