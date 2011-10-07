# If not running interactively, don't do anything
[[ -z "$PS1" || -z "$HOME" ]] && return

CONFIGS=$(dirname $(readlink ~/.bashrc))

export PATH=$HOME/bin:$CONFIGS/bin:$PATH
export EDITOR=vim
export PAGER=less
export LESSHISTFILE=-
export LANG=en_US.UTF-8
export LANGUAGE=en_US:en

# History control: do not write to disk, ignore all duplicates and commands starting with space
HISTFILE=
HISTCONTROL=ignoreboth
HISTSIZE=1000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# enable color support of ls
if [[ -x /usr/bin/dircolors ]]; then
  test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
  alias ls='ls --color=auto'
fi

alias l='ls -l'
alias ll='ls -l'
alias mv='mv -i'
alias rm='rm -i'
alias cp='cp -i'
alias df='df -h'
alias du='du -h'
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
alias bc='bc -q'
alias gdb='gdb --quiet'
alias ssh='ssh -AX'
alias R='R --no-save --no-restore --quiet'
alias cd3='cd ./$(scm-root.py)'

function up() {
  local CMD;
  local PREVHEAD;
  PREVHEAD="";
  if [[ -r .git/config ]] && grep svn-remote .git/config >/dev/null 2>&1; then
    PREVHEAD=`git rev-parse HEAD`
    CMD='git svn rebase --fetch-all'
  elif [[ -d .git ]]; then
    CMD='git pull'
  elif [[ -d .svn ]]; then
    CMD='svn update'
  else
    echo 'Not in a repository'
    return 1
  fi
  bash -x -c "$CMD"
}
export -f up

if [[ -f ~/.gdb_history ]]; then
  chmod 0600 ~/.gdb_history
fi

if [[ ! -d /cygdrive ]]; then
  #if [[ -f /etc/bash_completion ]]; then source /etc/bash_completion; fi
  source $CONFIGS/bash-completion-git
fi

# set variable identifying the chroot you work in (used in the prompt below)
if [[ -z "$debian_chroot" ]] && [[ -r /etc/debian_chroot ]]; then
  debian_chroot=$(cat /etc/debian_chroot)
fi

unset PS1

if [[ -f ~/.bashrc.local ]]; then
  source ~/.bashrc.local
fi


if [[ -z "$PS1" ]]; then
  if [[ "$TERM" != "dumb" ]]; then
    PS1='${debian_chroot:+($debian_chroot)}'
    #PS1+='\[\033[36m\]\A '  # time
    PS1+='\[\033[01;${PS1_COLORR:-32}m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]'  # user@host:workdir
    PS1+='\[\033[35m\]$(__git_ps1)\[\033[00m\]'  # git branch
    PS1+='\$ '
  else
    PS1='\u@\h:\w\$ '
  fi
fi

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac
