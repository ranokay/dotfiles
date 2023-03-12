# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell" # default theme

zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

ENABLE_CORRECTION="true" # correct mistyped commands

plugins=(git zsh-autosuggestions zsh-syntax-highlighting zsh-completions z zsh-interactive-cd)

source $ZSH/oh-my-zsh.sh # Load the oh-my-zsh's library.

alias ls="exa -abhl --icons --grid --color=always --group-directories-first"

eval "$(starship init zsh)" # starship prompt

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
