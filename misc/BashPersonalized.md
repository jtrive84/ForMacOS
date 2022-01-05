It is possible to customize the bash prompt to reflect information related to
the current computing environment, current dates/times or the working directory
to name a few. Here is a full list of Bash escape sequences:

```
\a     an ASCII bell character (07)
\d     the date  in  "Weekday  Month  Date"  format
       (e.g., "Tue May 26")
\e     an ASCII escape character (033)
\h     the hostname up to the first `.'
\H     the hostname
\j     the  number of jobs currently managed by the
       shell
\l     the basename of the shell's terminal  device
       name
\n     newline
\r     carriage return
\s     the  name  of  the shell, the basename of $0
       (the portion following the final slash)
\t     the current time in 24-hour HH:MM:SS format
\T     the current time in 12-hour HH:MM:SS format
\@     the current time in 12-hour am/pm format
\u     the username of the current user
\v     the version of bash (e.g., 2.00)
\V     the release of bash,  version  +  patchlevel
       (e.g., 2.00.0)
\w     the current working directory
\W     the  basename  of the current working directory
\!     the history number of this command
\#     the command number of this command
\$     if the effective UID is 0, a #, otherwise  a
       $
\nnn   the  character  corresponding  to  the octal
       number nnn
\\     a backslash
\[     begin a sequence of non-printing characters,
       which could be used to embed a terminal control 
       sequence into the prompt
\]     end a sequence of non-printing characters
```

The desired escape sequences are bound to the `PS1` variable in the `.bashrc`
file. On Linux systems, the `.bashrc` file should be available at the following 
location:

```
/home/CID/.bashrc
```

Note that in order to list configuration files (files with a leading ".") using 
the `ls` command from Bash, you need to include the `-a` flag:

```
$ pushd ~
$ ls -1a
.bash_history
.bash_logout
.bash_profile
.bashrc
<more files below>  
```    

If the `.bashrc` fiels doesn't exist, you can create it with `touch`:

```
$ pushd ~
$ touch .bashrc
```
Then edit the file with your preferred editor. 


On Windows via Cygwin, `.bashrc` is usually located in the home directory.
From ther Cygwin shell, run the following:

```
$ echo $HOME
/u
```

Therefore, I should find `.bashrc` at *U:/.bashrc*.


## Customizing the Prompt

Let's say you want to display the username and the current directory,
followed by `$`. It can be specified using  the `\u` and `\w` escape sequences 
as follows:

```
# Within .bashrc file
PS1='\u \w $ '
```

After saving the changes, exit the editor and source the .bashrc from the 
terminal, by running:

```bash
$ source /home/CID/.bashrc
```

Upon doing so, your prompt will now look like the following (but with your
CID):

![prompt0](/uploads/personal_snippet/39/2389f4fa2ff0e58ff19e46c1849686d7/prompt0.png)


To set the prompt to display username@hostname enclosed in brackets, 
followed by the current working directory in curly braces, but this time using 
`%` as the prompt instead of `$`, define `PS1` as follows:

```
PS1='[\u@\H] {\w} %'
```

Which results in the following:

![prompt1](/uploads/personal_snippet/39/022322aaf85f57279a72b9f83d6cc535/prompt1.png)


One of the problems with keeping the current working directory and the prompt
on the same line is that it takes up a lot of room. We can include a newline
character to display the current working directory, but place the prompt on
the next line down. For example, keeping the prompt spec as above but with the 
prompt character as `$` preceeded by the current date and time surrounded by 
`<>` on the next line, encode `PS1` as follows:

```
PS1='[\u@\H] {\w}\n<\d \t> $'
```

This results in:

![prompt2](/uploads/personal_snippet/39/f5a3015338d8a2cb30ea53dfe97d3b10/prompt2.png)

Notice that even though the path to the working directory as present in the 
image is long, by putting the prompt on the next line down we give outselves 
ample room for longer command sequences. 

## Coloring Prompt Components

It is possible to colorize prompt components using non-printable character
sequences. The eight basic high intensity colors are encoded as:

```
# High-intensity color specs #
black : '\e[0;90m'
red   : '\e[0;91m'
green : '\e[0;92m'
yellow: '\e[0;93m'
blue  : '\e[0;94m'
purple: '\e[0;95m'
cyan  : '\e[0;96m'
white : '\e[0;97m'
```

In addition, the same eight colors can used in a lower intensity representation
by substituting `9` with `3` in the sequences above:


```
# Standard-intensity color specs #
black : '\e[0;30m'
red   : '\e[0;31m'
green : '\e[0;32m'
yellow: '\e[0;33m'
blue  : '\e[0;34m'
purple: '\e[0;35m'
cyan  : '\e[0;36m'
white : '\e[0;37m'
```
Two important things to keep in mind: 

1. If the first character of your `PS1` specification is a color sequence, 
escape the first character with `\[`.      

2. To set the color of the text commands entered at the shell, place the 
color sequence immediately following the prompt character.      


In the remainder of this section, I'll present a number of examples
demonstrating how to colorize various components of the prompt. 


To start, we keep our most recent `PS1` definition, but this time we set the 
color of `$` to high-intensity red (`'\e[0;91m'`) and the text color as green:

```
PS1='[\u@\H] {\w}\n<\d \t> \e[0;91m$\e[0;92m '
```

Which results in:

![prompt3](/uploads/personal_snippet/39/ed45398355e45eb032f95c283b9af388/prompt3.png)


Next, let's change the username and hostname components to high-intensity cyan 
and the current working directory to purple, but making the `@` symbol
low-intensity white while keeping the prompt character red:

```
PS1='[\e[0;96m\u\e[0;37m@\e[0;96m\H] {\e[0;95m\w}\n<\d \t> \e[0;91m$\e[0;92m '
```

Resulting in:

![prompt4](/uploads/personal_snippet/39/28eba64d86af5ea16b8d8e34bf23c610/prompt4.png)

Notice that while this has the desired effect, we see it isn't exactly as
anticipated. Color sequences are greedy by nature, and will remain unchanged 
until explicitly switched by a different sequence. Because we set the terminal 
text color to green, the very first left bracket in the prompt is also green. 
Notice also that even though only the current working directory was supposed
to be colored purple, everything up to the red prompt color sequence 
gets colored purple as well. In order to prevent this, we need to include 
a color sequence for each component of the prompt. To demonstrate, we'll color 
the prompt using the following specification:     

- username and hostname components to high-intensity cyan                
- current working directory to purple        
- prompt red     
- text green       
- date and time white       
- all brackets (`[`, `]`, `{`, `}`, `<`, `>`) yellow       


```
PS1='\[\e[0;93m[\e[0;96m\u\e[0;37m@\e[0;96m\H\e[0;93m]{\e[0;95m\w\e[0;93m}\n\e[0;93m<\e[0;97m\d \t \e[0;93m> \e[0;91m$\e[0;92m'
```

Resulting in:

![prompt5](/uploads/personal_snippet/39/8441d3e66a09753e1d63ffb2067e55e1/prompt5.png)

Notice that the brackets are consistently yellow, and there is no "bleeding"
from colors unintentionally running into components. In the `PS1` specification, 
since the first character is a non-printable sequence, it is necessary to 
include `\[`. This is only required as the first character: It shouldn't be used
anywhere else within `PS1`. 

Using these options, it is possible to personalize your prompt to any
desired degree. 


## Additional Color Support

In addition to the eight basic colors, for terminals with xterm-256 support
which, in 2019 should be just about every terminal, any of the
256 colors presented in the following image can be used:


![Colors](/uploads/personal_snippet/39/8da792a09828445131fc472504baf8be/Colors.png)

To enable xterm-256 support, from Cygwin, right click on the upper left icon, 
select *Options > Terminal*, then in the *Type* dropdown, select "xterm-256color". 



Assume a basic `PS1` spec, given by:

```
PS1='\u \w $ '
```

Assume we're interested in setting our prompt to color 39, with everything
else colored as 200. The leading escape sequence is still required. We set
`PS1` as:

```
PS1='\[\033[38;5;200m\u \w \033[38;5;039m$ '
```

Resulting in:

![prompt6](/uploads/personal_snippet/39/c17e8a1fe6decdaf16ac81b0738b692f/prompt6.png)

The standard 256-color sequence is given by:

```
\033[38;5;NNNm
```

Where `NNN` represents a 3-digit numeric code from 0-255 inclusive. 
Note that for colors that correspond to single or double-digit numbers,
left pad with (a) leading zero(s). 
