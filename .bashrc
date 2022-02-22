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
    xterm-color|xterm)
		PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ ';;
	xterm*|rxvt*)
    	PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1" ;;
    screen*)
      if [ -e /etc/sysconfig/bash-prompt-screen ]; then
          PROMPT_COMMAND=/etc/sysconfig/bash-prompt-screen
      else
          PROMPT_COMMAND='printf "\033k%s@%s:%s\033\\" "${USER}" "${HOSTNAME%%.*}" "${PWD/#$HOME/~}"'
      fi
      ;;
    *)
      [ -e /etc/sysconfig/bash-prompt-default ] && PROMPT_COMMAND=/etc/sysconfig/bash-prompt-default
	  PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
      ;;
 esac

if [ -f /usr/share/git/completion/git-prompt.sh ]; then
	source /usr/share/git/completion/git-prompt.sh
else
	source /usr/lib/git-core/git-sh-prompt
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
alias ll='ls -lhF'
alias grep='grep --color=auto'
alias grpe='grep'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
GREP_OPTIONS='--color'
LESS='-R'

alias df='df -h'
alias f='LANG=US free -m'
alias cp='cp -i'
alias rec='ls -lht | head'

alias er='vi ~/.bashrc'
alias ert='vi ~/.bashrc_local'
alias re='source ~/.bashrc'

alias checkcd='find . -type f -exec md5sum {} \; > /dev/null'

alias maj='if [[ -f /usr/bin/apt ]]; then sudo apt update ; sudo apt upgrade; else sudo pacman -Syu; fi'
alias listpkg='dpkg-query -Wf '"'"'${Installed-Size}\t${Package}\n\'"'"' | sort -n'
alias ys='yaourt -S --noconfirm'
alias pk='pkgfile -s'
alias apt-add-key='apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys'

alias loc='locate -A -i'
alias l='locate'

alias tv='/usr/bin/vlc http://mafreebox.freebox.fr/freeboxtv/playlist.m3u'
alias ftpfree='lftp hd1.freebox.fr'
alias ebook='lftp ftp://inkrusted:2221 -e "cd Books"'

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

alias v='vim -R'
alias vi='vim'
alias view='vim -R'

alias co='hg commit -m'
alias hlog='hg log -l 4'
alias squash='git rebase -i upstream/master'
alias ff='git pull --ff-only'
alias fu='git branch -u origin/master'
alias fr='git pull --rebase'
alias gitout='git log origin/master..HEAD'
alias gitin='git log HEAD..origin/master'
alias amend='git commit --amend --no-edit'

alias dssh='ssh -l dalmat'
alias mssh='ssh -l matthieu.dalstein -A'
alias nyx-wake='wakeonlan 00:1F:D0:9A:A2:25'

alias wiki='cd /srv/usr/local/share/Wikipad/ && python2 WikidPad.py &'

alias ent='sudo nsenter -n -t'
alias mountvbox='mkdir /tmp/vbox && sudo mount -t vboxsf tmp /tmp/vbox'
alias start_archlinux='docker run -ti -v /dev:/dev -v /proc:/proc -v /sys:/sys -v $HOME:/home/dalmat -v /tmp:/tmp archlinux-dalmat bash'

alias checkcd='find . -type f -exec md5sum {} \; > /dev/null'
alias comparedir='rsync --recursive --delete --links --verbose --dry-run'
alias comparedirchecksum='rsync --recursive --delete --links --checksum --verbose --dry-run'

function dlaudio
{
	youtube-dl -f 251 "$1"
	local output_file=$(youtube-dl --get-filename "$1")
	ffmpeg -i "$output_file" -c:a copy "${output_file/webm/opus}"
	touch -r "$output_file" "${output_file/webm/opus}"
	rm "$output_file"
}

alias dvgrab-auto='dvgrab --autosplit --timestamp --format raw capture'

function freedl
{
	ffmpeg -i "rtsp://mafreebox.freebox.fr/fbxtv_pub/stream?namespace=1&service=$1" -c:v copy -c:a copy /srv/$1-$(date +%F_%T).ts
}

alias printfirstandlastline="awk 'NR==1; END{print}'"

# If there are multiple matches for completion, Tab should cycle through them
bind 'TAB':menu-complete

# Display a list of the matching files
bind "set show-all-if-ambiguous on"

# Perform partial completion on the first Tab press,
# only start cycling full results on the second Tab press
bind "set menu-complete-display-prefix on"

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
	local SIZE=`du -sb $1 | awk '{print $1}'`
	local DEST=`basename $1`

	( cd $1 ; tar cf - . ) | pv -s $SIZE | ( mkdir $2/$DEST && cd $2/$DEST ; tar xf - )
}

function p()
{
 pacman -$@
}

function ffconcat()
{
	local length=$(($#-1))
	local output=${@: -1}
	local array=("${@:1:$length}")
	for i in "${array[@]}"; do echo "$i"; done
	echo -n "" > liste
	for file in "${array[@]}"; do echo file \'$(realpath "$file")\' >> liste; done
	ffmpeg -safe 0 -f concat -i liste -c copy "$output"
	touch -r "${array[0]}" "$output"
	#cat liste
	rm liste
}

function convertVideoAudioToOpus()
{
	ffmpeg -i "$1" -map 0 -c copy -c:a libopus -b:a 220k -af "channelmap=channel_layout=5.1" "$1_converted.mkv"
	touch -r "$1" "$1_converted.mkv"
}

function shiftTimestamp()
{
	local delta=$1
	shift
	exiftool -P -overwrite_original -AllDates+=$delta -DateTimeDigitized+=$delta -DateTime+=$delta "$@"
}

function updateDescription()
{
	local title=$1
	local description=$2
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
 local pid=$(pidof $1)

 sudo nsenter -n -t $pid
}

function denter()
{
	local container=$(docker ps | awk ' {print $1 " " $2 " " $3}' | awk '/etcd/ {print $1}')
	echo "Entering container $container"
	docker exec -ti $container /bin/bash
}

alias wallpapersave='for size in 1680 1920 2560; do for i in $(find /usr/share/wallpapers -name $size*) ; do arr=(${i//\// }); echo  cp -n "$i" /mnt/ftp/Multi/wallpapers/${arr[1]}-${arr[4]}; done; done'
alias chr='mount -t proc proc /srv/proc/ && mount -t sysfs sys /srv/sys && mount -o bind /dev /srv/dev/ && chroot /srv/'

export GOPATH=~/code/go
export PATH=$PATH:~/code/tools:$GOPATH/bin:~/.local/bin:/snap/bin
export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"

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
