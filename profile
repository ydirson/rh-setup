# /etc/profile

# System wide environment and startup programs, for login setup
# Functions and aliases go in /etc/bashrc

pathmunge () {
	if ! echo $PATH | /bin/egrep -q "(^|:)$1($|:)" ; then
	   if [ "$2" = "after" ] ; then
	      PATH=$PATH:$1
	   else
	      PATH=$1:$PATH
	   fi
	fi
}

# ksh workaround
if [ -z "$EUID" -a -x /usr/bin/id ]; then 
	EUID=`id -u`
	UID=`id -ru`
fi

# Path manipulation
if [ "$EUID" = "0" ]; then
	pathmunge /sbin
	pathmunge /usr/sbin
	pathmunge /usr/local/sbin
else
	pathmunge /usr/local/sbin after
	pathmunge /usr/sbin after
	pathmunge /sbin after
fi

# No core files by default
ulimit -S -c 0 > /dev/null 2>&1

if [ -x /usr/bin/id ]; then
	USER="`id -un`"
	LOGNAME=$USER
	MAIL="/var/spool/mail/$USER"
fi

HOSTNAME=`/bin/hostname 2>/dev/null`
HISTSIZE=1000

export PATH USER LOGNAME MAIL HOSTNAME HISTSIZE INPUTRC

for i in /etc/profile.d/*.sh ; do
    if [ -r "$i" ]; then
        if [ "$PS1" ]; then
            . $i
        else
            . $i &>/dev/null
        fi
    fi
done

unset i
unset pathmunge
