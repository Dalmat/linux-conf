# ~/.bashrc: executed by bash(1) for non-login shells.
# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# don't put duplicate lines in the history. See bash(1) for more options
# ... or force ignoredups and ignorespace
HISTCONTROL=ignoredups:ignorespace
HISTIGNORE='&:ls'

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=4000
HISTFILESIZE=4000

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
    xterm) color_prompt=yes
          #PROMPT_COMMAND='printf "\033]0;%s@%s:%s\007" "${USER}" "${HOSTNAME%%.*}" "${PWD/#$HOME/~}"'
	;;
    screen*)
      if [ -e /etc/sysconfig/bash-prompt-screen ]; then
          PROMPT_COMMAND=/etc/sysconfig/bash-prompt-screen
      else
          PROMPT_COMMAND='printf "\033k%s@%s:%s\033\\" "${USER}" "${HOSTNAME%%.*}" "${PWD/#$HOME/~}"'
      fi
      ;;
    *)
      [ -e /etc/sysconfig/bash-prompt-default ] && PROMPT_COMMAND=/etc/sysconfig/bash-prompt-default
      ;;
 esac

  [ "$PS1" = "\\s-\\v\\\$ " ] && PS1="[\u@\h \W]\\$ "
  # You might want to have e.g. tty in prompt (e.g. more virtual machines)
  # and console windows
  # If you want to do so, just add e.g.
  # if [ "$PS1" ]; then
  #   PS1="[\u@\h:\l \W]\\$ "
  # fi
 

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
#unset color_promptt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac
#PS1='\u@\h:\w\$ '

if [ -f /usr/share/git/completion/git-prompt.sh ]; then
	source /usr/share/git/completion/git-prompt.sh
fi

GIT_PS1_SHOWDIRTYSTATE=1
GIT_PS1_SHOWSTASHSTATE=1
GIT_PS1_SHOWUNTRACKEDFILES=1
GIT_PS1_SHOWUPSTREAM=verbose
#GIT_PS1_SHOWUPSTREAM="verbose name"
GIT_PS1_SHOWCOLORHINTS=1
PROMPT_COMMAND='__git_ps1 "\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]" "\$(if [[ \$? -eq 0 ]]; then printf \"\[\033[01;30m\]\"; else printf \"\[\033[07;31m\]\"; fi)\\$\[\033[00m\] "'
#PROMPT_COMMAND='__git_ps1 "{{ virtualenv_ps1 }}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]" "\$(if [[ \$? -eq 0 ]]; then printf \"\[\033[1;30m\]\"; else printf \"\[\033[7;31m\]\"; fi)\\\$\[\033[00m\] "'

# enable color support of ls and also add handy aliases
eval `dircolors -b`
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
GREP_OPTIONS='--color'
LESS='-R'

alias cp='cp -i'
alias du='du -h'
alias df='df -h'
alias ll='ls -alhF'
alias rec='ls -lht | head'
alias grpe='grep'

alias er='vim ~/.bashrc'
alias re='source ~/.bashrc'

alias nyx-wake='wakeonlan 00:1F:D0:9A:A2:25'

alias co='hg commit -m'
alias hlog='hg log -l 4'

alias checkcd='find . -type f -exec md5sum {} \; > /dev/null'


alias maj='if [[ -f /usr/bin/apt ]]; then sudo apt update ; sudo apt upgrade; else sudo pacman -Syu; fi'
alias ai='sudo apt-get install'
alias listpkg='dpkg-query -Wf '"'"'${Installed-Size}\t${Package}\n\'"'"' | sort -n'
alias ys='yaourt -S --noconfirm'

alias loc='locate -A -i'
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

alias vi='vim'
alias view='vim -R'
alias squash='git rebase -i upstream/master'
alias ff='git pull --ff-only'
alias fu='git branch -u origin/master'
alias fr='git pull --rebase'
alias gitout='git log origin/master..HEAD'
alias gitin='git log HEAD..origin/master'
alias amend='git commit --amend --no-edit'
alias dssh='ssh -l dalmat'
alias mssh='ssh -l matthieu.dalstein -A'
alias er='vi ~/.bashrc'
alias ert='vi ~/.bashrc_local'
alias re='source ~/.bashrc'
alias df='df -h'
alias ll='ls -lh'
alias ls='ls --color=auto'
alias pk='pkgfile -s'
alias dal='ssh dalmat@dalmat.net'
alias wiki='cd /srv/usr/local/share/Wikipad/ && python2 WikidPad.py &'
alias ent='sudo nsenter -n -t'
alias mountvbox='mkdir /tmp/vbox && sudo mount -t vboxsf tmp /tmp/vbox'
alias comparedir='rsync --recursive --delete --links --verbose --dry-run'
alias comparedirchecksum='rsync --recursive --delete --links --checksum --verbose --dry-run'
alias l='locate'
alias dlaudio='youtube-dl -f 251'

function dlaudio
{
	youtube-dl -f 251 "$1" 
	output_file="test"
	ffmpeg -i "$output_file" -c:a copy "${output_file/webm/opus}"
	rm "$output_file"
}


function dockerlogs
{
	docker logs $2 $(docker ps | awk '/$1/ {print $1}')
}

function dockerexec
{
	docker exec -ti $(docker ps | awk '/$1/ {print $1}') bash
}

alias dockerrmi='for image in $(docker images | awk '/mdalstein/ || /root/ {print $3}'); do docker rmi $image; done'



function cp_progress()
{
	SIZE=`du -sb $1 | awk '{print $1}'`
	DEST=`basename $1`

	( cd $1 ; tar cf - . ) | pv -s $SIZE | ( mkdir $2/$DEST && cd $2/$DEST ; tar xf - )
}

function p()
{
 pacman -$@
}

function ffconcat()
{
	length=$(($#-1))
	output=${@: -1}
	array=("${@:1:$length}")
	for i in "${array[@]}"; do echo "$i"; done
	echo -n "" > liste
	for file in "${array[@]}"; do echo file \'$(realpath "$file")\' >> liste; done
	ffmpeg -safe 0 -f concat -i liste -c copy "$output"
	touch -r "${array[0]}" "$output"
	#cat liste
	rm liste
}

function shiftTimestamp()
{
	delta=$1
	shift
	exiftool -P -overwrite_original -AllDates+=$delta -DateTimeDigitized+=$delta -DateTime+=$delta "$@"
}

function updateDescription()
{
	title=$1
	description=$2
	exiftool -P *.[jJ][pP][gG] -overwrite_original -if '$Title eq '\'"$title"\' -ImageDescription=$description -Description=$description
}

function updateTimestamp()
{
	exiftool -progress -d '%Y:%m:%d %H:%M:%S' -if '$FileModifyDate ne $DateTimeOriginal' '-FileModifyDate<DateTimeOriginal' "$@"
}

function removeTimestamp()
{
	exiftool -r -overwrite_original  -allDates=  -if '$DateTimeOriginal eq "2002:01:01 00:00:00"' .
}

function pent()
{
 pid=$(pidof $1)
 
 sudo nsenter -n -t $pid
}

function denter()
{
  container=$(docker ps | awk ' {print $1 " " $2 " " $3}' | awk '/etcd/ {print $1}')
  echo "Entering container $container"
  docker exec -ti $container /bin/bash
}

alias wallpapersave='for size in 1680 1920 2560; do for i in $(find /usr/share/wallpapers -name $size*) ; do arr=(${i//\// }); echo  cp -n "$i" /mnt/ftp/Multi/wallpapers/${arr[1]}-${arr[4]}; done; done'
alias chr='mount -t proc proc /srv/proc/ && mount -t sysfs sys /srv/sys && mount -o bind /dev /srv/dev/ && chroot /srv/'

export GOPATH=~/code/go
export PATH=$PATH:~/code/tools:$GOPATH/bin:/snap/bin

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi

if [ -f ~/.bashrc_local ];then  
	. ~/.bashrc_local
fi

# vim:ts=4:sw=4
