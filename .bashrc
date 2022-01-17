# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=
PS1='\[\033[00;92m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\] \[\033[38;5;207m\]\n\$\[\033[38;5;15m\] '
# User specific aliases and functions


# Replace any leading leading 0; with 1; for bold colors
# Replace any leading 0; with 4; to underline

# Regular Colors
#\[\033[0;30m\] Black
#\[\033[0;31m\] Red
#\[\033[0;32m\] Green
#\[\033[0;33m\] Yellow
#\[\033[0;34m\] Blue
#\[\033[0;35m\] Purple
#\[\033[0;36m\] Cyan
#\[\033[0;37m\] White   \[\e[0;37m\] \[\e[0;97m\]
# High Intensty
#\[\033[0;90m\] Black
#\[\033[0;91m\] Red
#\[\033[0;92m\] Green
#\[\033[0;93m\] Yellow
#\[\033[0;94m\] Blue
#\[\033[0;95m\] Purple
#\[\033[0;96m\] Cyan
#\[\033[0;97m\] White

#\a          an ASCII bell character (07)
#\d          the date in "Weekday Month Date" format (e.g., "Tue May 26")
#\D{format}  the format is passed to strftime(3) and the result
#            is inserted into the prompt string an empty format
#            results in a locale-specific time representation.
#            The braces are required
#\e          an ASCII escape character (033)
#\h          the hostname up to the first '.'
#\H          the hostname
#\j          the number of jobs currently managed by the shell
#\l          the basename of the shell's terminal device name
#\n          newline
#\r          carriage return
#\s          the name of the shell, the basename of $0 (the portion following
#            the final slash)
#\t          the current time in 24-hour HH:MM:SS format
#\T          the current time in 12-hour HH:MM:SS format
#\@          the current time in 12-hour am/pm format
#\A          the current time in 24-hour HH:MM format
#\u          the username of the current user
#\v          the version of bash (e.g., 2.00)
#\V          the release of bash, version + patch level (e.g., 2.00.0)
#\w          the current working directory, with $HOME abbreviated with a tilde
#\W          the basename of the current working directory, with $HOME
#            abbreviated with a tilde
#\!          the history number of this command
#\#          the command number of this command
#\$          if the effective UID is 0, a #, otherwise a $
#\nnn        the character corresponding to the octal number nnn
#\\          a backslash
#\[          begin a sequence of non-printing characters, which could be used
#            to embed a terminal control sequence into the prompt
#\]          end a sequence of non-printing characters

clear
