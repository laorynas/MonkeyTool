### ZSH OPTIONS ###
autoload -U colors && colors

setopt nobeep

umask 022

## #VARIABLES ###
export EDITOR="vim"

### ALIASES ###
alias ls='ls -hF --color=auto'
alias l='ls -alF'
alias df='df -h'
alias vi="vim"
alias ..="cd .."
alias ...="cd ../.."

### HISTORY ###
setopt append_history
setopt hist_ignore_all_dups
setopt hist_ignore_space
setopt hist_verify

HISTFILE=~/.zshhistory
HISTSIZE=10000
SAVEHIST=10000

### PROMPT ###
export PS1="%B%{$bg[black]%}%{$fg[red]%}%n %{$fg[blue]%}%~%{$fg[white]%}%# %b"

### KEYBINDINGS ###
bindkey -e

bindkey "^[OH"  beginning-of-line       # Home
bindkey "^[OF"  end-of-line             # End 
bindkey "^[[3~" delete-char             # Del
bindkey "^[[2~" overwrite-mode          # Insert 
bindkey "^[[5~" history-search-backward # PgUp 
bindkey "^[[6~" history-search-forward  # PgDn

### COMPLETION ###
setopt complete_in_word
setopt NONOMATCH

autoload -U compinit && compinit

zstyle ':completion:*' glob 'yes'
zstyle ':completion:*' expand prefix suffix

zstyle ':completion:*:*:killall:*' menu yes select
zstyle ':completion:*:killall:*' force-list always

### FUNCTIONS ###
precmd(){
	rehash
}
