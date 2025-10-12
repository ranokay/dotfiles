export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# Prioritize Homebrew binaries (including newer bash)
export PATH="/opt/homebrew/bin:$PATH"

alias c=cursor
alias c.='cursor .'
alias v=code
alias v.='code .'

# Aliases moves
alias .='cd ..'
alias ..='cd ../..'
alias ...='cd ../../..'
alias ....='cd ../../../..'

# Expo scripts
alias wb='bun web:build'
alias ws='bun web:serve'
alias eda='bun eas:dev:android'
alias edi='bun eas:dev:ios'
alias epa='bun eas:prod:android'
alias epi='bun eas:prod:ios'
alias lda='bun local:dev:android'
alias ldi='bun local:dev:ios'
alias lpa='bun local:prod:android'
alias lpi='bun local:prod:ios'

# EZA alias
alias ls='eza -l -a -h --icons=always --git --group-directories-first'

alias cat=bat

# bun completions
[ -s "/Users/ranokay/.bun/_bun" ] && source "/Users/ranokay/.bun/_bun"

export EZA_CONFIG_DIR="$HOME/.config/eza"

if [[ -n "$WARPIFY_SUBSHELL" ]]; then
  printf '\eP$f{"hook": "SourcedRcFileForWarp", "value": { "shell": "zsh", "uname": "'$(uname)'" }}\x9c'
fi

warpify() {
    local dir
    dir=$(mktemp -d) || { echo "Failed to create temp dir"; return 1; }
    (
        trap 'cd / && rm -rf "$dir"' EXIT
        cd "$dir" || exit
        WARPIFY_SUBSHELL=1 $SHELL --login
    )
}

# For z
source /opt/homebrew/etc/profile.d/z.sh

# Enable zsh-autosuggestions
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
