# General aliases
alias ls='ls -C --color=auto'
alias ll='ls -alF'

alias gupdate='git update-git-for-windows'

# Load aliases, if they exist
if [ -f ~/.aliases ]; then
	. ~/.aliases
fi

# Check if command exists before running
if command -v starship >/dev/null; then
	eval "$(starship init bash)"
fi

if command -v fnm >/dev/null; then
	eval "$(fnm env --use-on-cd)"
fi
