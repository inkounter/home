#!/bin/bash

PS1='\[\e[36m\](\@) \[\e[35m\][\h \W]\[\e[0m\]\$ '
PS3='\[\e]0;\u@\h:\w\a\][\u@\h \W$(__git_ps1 " (%s)")]\$ '

export VISUAL=vim
export EDITOR=vim

# allow everyone r/x permissions. only user has w permission
umask 022

bind -m vi-insert "\C-l":clear-screen
bind -m vi-command "\C-l":clear-screen
bind -m vi-insert "\C-p":

# disable empty tab auto-completion
shopt -s no_empty_cmd_completion

# when shell exits, append to ~/.bash_history instead of overwriting
shopt -s histappend

alias ls="ls --color=auto"

# fat fingers...
alias s="ls"

alias vims="vim -S"
alias vima="vim -c 'Vsp' -c 'Test'"

# repeat the last command
alias k="fc -s"

# kill the last ctrl+z'd process
alias kl="kill -9 %+"

# force UTF-8 encoding in tmux
alias tmux='tmux -u'

alias grep="grep --color=auto --exclude-dir=.git --exclude=Session.vim --exclude=.*.swp --exclude=changelog"

[ -f ~/.surroundingEnvironment ] && . ~/.surroundingEnvironment
