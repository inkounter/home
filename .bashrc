#!/bin/bash

PS1='\[\e]0;\u@\h:\w\a\]\[\033[36m\](\@) \[\033[35m\][\h \W]\[\033[0m\]\$ '
PS3='\[\e]0;\u@\h:\w\a\][\u@\h \W$(__git_ps1 " (%s)")]\$ '

# allow everyone r/x permissions. only user has w permission
umask 022

# disable empty tab auto-completion
shopt -s no_empty_cmd_completion

# when shell exits, append to ~/.bash_history instead of overwriting
shopt -s histappend

alias ls="ls --color=auto"

# fat fingers...
alias s="ls"

alias vims="vim -S"

# repeat the last command
alias k="fc -s"

# kill the last ctrl+z'd process
alias kl="kill -9 %+"

export GREP_OPTIONS+="--exclude-dir=.depend --exclude=Session.vim"

[ -f ~/.surroundingEnvironment ] && . ~/.surroundingEnvironment
