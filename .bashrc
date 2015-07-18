# ~/.bashrc: executed by bash(1) for non-login shells.
# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# don't put duplicate lines in the history. See bash(1) for more options
# ... or force ignoredups and ignorespace
HISTCONTROL=ignoredups:ignorespace

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# append to the history file, don't overwrite it
shopt -s histappend

set bell-style visible
set show-all-if-ambiguous on

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color) color_prompt=yes;;
    xterm) color_prompt=yes;;
esac

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_promptt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac
#PS1='\u@\h:\w\$ '

# enable color support of ls and also add handy aliases
eval `dircolors -b`
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

alias cp='cp -i'
alias du='du -h'
alias df='df -h'
alias ll='ls -alhF'
alias rec='ls -lht | head'

alias er='vim ~/.bashrc'
alias re='source ~/.bashrc'

alias nyx-wake='ssh athena sudo nyx-wake'

alias co='hg commit -m'
alias hlog='hg log -l 4'

alias checkcd='find . -type f -exec md5sum {} \; > /dev/null'


alias maj='sudo apt-get update && sudo apt-get upgrade'
alias apt='sudo apt-get'
alias ai='sudo apt-get install'
alias listpkg='dpkg-query -Wf '"'"'${Installed-Size}\t${Package}\n\'"'"' | sort -n'
alias ys='yaourt -S --noconfirm'

alias loc='locate -i'
alias v='vim -R'

alias tv='/usr/bin/vlc http://mafreebox.freebox.fr/freeboxtv/playlist.m3u'
alias ftpfree='lftp hd1.freebox.fr'


alias convert2ogg='for i in *.wav; do /usr/bin/oggenc -q 5 "$i" -o "${i%wav}ogg"; done'

alias camelCase="rename 's/\b(\w)/\u$1/g' *"
alias lowercase="rename 'y/A-Z/a-z/'"
alias ren="rename 's/\./ /g' * ; rename 's/ tar gz/.tar.gz/' *gz ; rename 's/ (.{3}|.{2})$/.\$1/' *; rename 's/(%20)+/ /g' * ; rename 's/é(%CC%81)+/ée/g' * ; rename 's/_+/ /g' * ; rename 's/^ //' *"

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'
alias taille='find /home -type f -printf "%s\t%p\n" |sort -rn |head -n20 |less'
alias cdd='/usr/lib/wcd/wcd.exec'
alias ccd='/usr/lib/wcd/wcd.exec'

function cp_progress()
{
	SIZE=`du -sb $1 | awk '{print $1}'`
	DEST=`basename $1`

	( cd $1 ; tar cf - . ) | pv -s $SIZE | ( mkdir $2/$DEST && cd $2/$DEST ; tar xf - )
}


export PATH=$PATH:~/code/tools

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi

if [ -f ~/.bashrc_local ];then  
	. ~/.bashrc_local
fi
