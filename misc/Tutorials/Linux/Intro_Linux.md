
## Introduction to Linux
###### Author: James Triveri


In this article, I briefly cover the origins and history of the Linux operating system, along with a number of introductory examples of working from the Linux terminal. In order to follow along, you should have the ability to access the analytics environment from the shell via ssh whether it be using Git Bash, PuTTy or the Windows Terminal (each of these require submitting a ticket; as of Windows 10, there is no Windows-native application which allows connecting to a remote server via ssh).



#### Linux Origins


UNIX (the forerunner of Linux) was created at Bell Labs in 1969-70 by Ken Thompson and Dennis Ritchie. It was born out of the Multics project, and was the first operating system written in C, offering a level of portability previously unavailable in operating systems. 


![drkt](https://git.guidehome.com/projects/AC/repos/tutorials/browse/Supporting/drkt.jpg)  


Unlike Windows, Linux is distributed in many different flavors, referred to as distributions:



![familytree](https://git.guidehome.com/projects/AC/repos/tutorials/browse/Supporting/familytree.png)


#### Overview

* The primary means of interacting with Linux systems is the shell interface, the most common shell is Bash, the *Bourne again shell*, the predecessor of the Bourne shell.
<br>

* The shell takes commands from the keyboard and passes them along to the operating system for execution.
<br>

* *Everything is a file*. System resources, network interfaces, process monitoring utilities, etc. can all be read from and written to just like a file.      
<br>     

* *Do one thing and do it well*: Large Linux programs are typically a composition of smaller applications that handle specific tasks (`grep`, `find`, `cut`, `ps`, `sort`, etc...).

  <br>

* Linux Development Guidelines:
      - *Small is beautiful*               
      - *Make each program do one thing well*            
      - *Build a prototype as soon as possible*        
      - *Choose portability over efficiency*      
      - *Store data in flat text files*       
      - *Use software leverage to your advantage*      
      - *Use shell scripts to increase leverage and portability*        
      - *Avoid captive user interfaces*    
      - *Make every program a filter*      


<br>

> *A lot of the low-level system calls have stood the test of time, as they exist unchanged after decades of use...* 
> -Bill Coughran Bell Labs/Google Researcher

<br>


### 0. Bash Preliminaries


> In the examples that follow, `$` represents the command prompt. Any lines starting with `$` represent valid input which can be entered and executed in the shell. Lines immediately following these commands not starting with `$` represent shell output, or the response of the previously executed command. These lines should not be executed.      

<br>
I assume that you have shell access to the analytics environment. that the `LinuxDemo` repository has been cloned and a copy is available on the local client. If ssh authentication to BitBucket has been properly configured, this should be as easy as:

```sh
$ cd /SAS/misc/jtrive
$ git clone git@.../LinuxDemo.git
```
<br>


#### Navigating within the terminal

A few useful keyboard shortcuts for getting around the termminal:

- `CTRL + A`: Go to beginning of line            
- `CTRL + E`: Go to end of line         
- `CTRL + L`: Clear screen         
- `ALT + B`: Move cursor back one word         
- `ALT + F`: Move cursor forward one word             
- `CTRL + U`: Cut all text before the cursor         
- `CTRL + K`: Cut all text after cursor    
- `CTRL + Insert`: Copy text from the terminal     
- `SHIFT + Insert`: Paste text from clipboard      
- `CTRL + Z`: Suspend currently running process      
- `CTRL + C`: Terminate currently running process
- `CTRL + D`; Exit terminal      
<br>



#### Simple commands

Obtain the user id of the currently logged-in user (your user id):

```sh
$ whoami
cac9159
```

Get hostname:

```sh
$ hostname
lrau1p11.cna.com
```

Display a calendar with the current date highlighted:

```sh
$ cal
 September 2020
Su Mo Tu We Th Fr Sa
 1  2  3  4  5  6  7
 8  9 10 11 12 13 14
15 16 17 18 19 20 21
22 23 24 25 26 27 28
29 30
```

Display the current date and time:

```sh
$ date
Sun Sep 22 18:43:55 CDT 2020
```

Determine which Linux distribution is running on remotehost:      

```sh
$ cat /etc/system-release
Red Hat Enterprise Linux Server release 6.10 (Santiago)
```

`cat` reads content from a file-like object (*In Linux, everything is a file*) and writes it to standard output.Technically, `cat` "concatenates" standard input (text stream, file content) to standard output.


Determine the number of available CPUs:

```sh
$ nproc
12
```

Obtain more detailed processor/CPU information:

```sh
$ lscpu
Architecture:          x86_64
CPU op-mode(s):        32-bit, 64-bit
Byte Order:            Little Endian
CPU(s):                12
On-line CPU(s) list:   0-11
Thread(s) per core:    1
Core(s) per socket:    10
Socket(s):             4
NUMA node(s):          4
Vendor ID:             GenuineIntel
CPU family:            6
Model:                 47
Model name:            Intel(R) Xeon(R) CPU E7- 4850  @ 2.00GHz
Stepping:              2
CPU MHz:               1995.103
BogoMIPS:              3989.89
Virtualization:        VT-x
L1d cache:             32K
L1i cache:             32K
L2 cache:              256K
L3 cache:              24576K
NUMA node0 CPU(s):     0-9
NUMA node1 CPU(s):     10-19
NUMA node2 CPU(s):     20-29
NUMA node3 CPU(s):     30-39
```

Determine the total and available memory:

```sh
$ free
             total       used       free     shared    buffers     cached
Mem:     545760840  255659752  290101088       4920     366776    1454836
-/+ buffers/cache:  253838140  291922700
Swap:      8388604    8249264     139340
```

#### Navigating the filesystem

Typically after logging in, you'll be placed into your home directory, which will be something like `/home/<ID>`.It is always possible to determine the current working directory using the `pwd` command (**p**rint **w**orking **d**irectory):

```sh
$ pwd
/home/i103455
```

The Bash shell defines shortcuts for commonly used commands. A few of them are:

- `~`: The logged in user's home directory          
- `.`: The current directory        
- `..`: The parent of the current directory     

<br>


To switch to a different directory, use *cd /path*. For example, to switch to */reserving/range/misc*, run:

```sh
$ cd /reserving/range/misc
$ pwd 
/reserving/range/misc
```

If I want to navigate to */reserving/range*, since it is the parent of the current working directory, I can use the `..` shortcut:

```sh
$ pwd
/reserving/range/misc
$ cd ..
$ pwd
/reserving/range
```

From any location on the filesystem, running `cd ~` returns the user to their home directory:

```sh
$ pwd 
/reserving/range
$ cd ~
$ pwd
/home/i103455
```

Tab completion is useful when switching between directories. If you enter `cd` followed by the first few characters of a directory path, hit Tab after each new character, and as soon as enough characters have been entered to uniquely identify the next path component, the shell will fill in the remaining characters. 

We can list the contents of a particular folder using `ls -l`. The `-l` option is a command line flag which modifies the default output format of to include additional information. We next run `ls` with and without the `-l` flag to show the difference:


```sh
$ pwd
/home/i103455
$ ls
2019_Q3_Selected_DEV_Data_v10.csv  Computer_Vision  ImageMagick.tar.gz  proxyd     Repos
anaconda3                          Datasets         local               proxysttr  Source
approxc.cpp                        Dev              LTC                 PyPI       Temp
CALC2019                           html             Projects            rand.py    Utils
```

The contents are listed, but doesn't indicate what each item is. Notice how the output is changed when`-l` is included:

```sh
$ ls -l
total 21936
-rw-r-----   1 cac9159 pmltmodu  8192000 Jun 24 09:23 2019_Q2_Selected_DEV_Data_v10.csv
drwxr-xr-x 313 cac9159 pmltmodu    16384 Aug  6 14:06 anaconda3
-rw-r--r--   1 cac9159 pmltmodu     1742 Sep 22 14:45 approxc.cpp
drwxr-xr-x   5 cac9159 pmltmodu    16384 Sep 19 09:17 CALC2019
drwxr-xr-x   2 cac9159 pmltmodu    16384 Aug 28 16:05 Computer_Vision
drwxr-xr-x   2 cac9159 pmltmodu    16384 Sep 22 13:58 Datasets
drwxr-x---   7 cac9159 pmltmodu    16384 May 24 11:39 Dev
drwxr-xr-x   5 cac9159 pmltmodu    16384 Jun 17 08:47 html
-rw-r--r--   1 cac9159 pmltmodu 13740926 Sep 22 14:43 ImageMagick.tar.gz
drwx------  16 cac9159 pmltmodu    16384 Aug 23 12:02 local
drwxr-xr-x   7 cac9159 pmltmodu    16384 Aug 16 08:17 LTC
drwxr-xr-x   4 cac9159 pmltmodu    16384 Nov  2  2018 Projects
-rwxr--r--   1 cac9159 pmltmodu      143 Aug 26 09:24 proxyd
-rwxr--r--   1 cac9159 pmltmodu       47 Aug 26 09:24 proxysttr
drwx-w----   2 cac9159 pmltmodu    16384 Jun 27  2018 PyPI
-rw-r--r--   1 cac9159 pmltmodu      225 Sep 22 15:01 rand.py
drwxr-xr-x  11 cac9159 pmltmodu    16384 Aug  5 16:23 Repos
drwxr-xr-x   2 cac9159 pmltmodu    16384 Mar 25 16:01 Source
drwxr-x---   3 cac9159 pmltmodu    16384 Aug 23 11:49 Temp
drwxr-xr-x   2 cac9159 pmltmodu    16384 Nov  2  2018 Utils
```

The line `total 21936` roughly equates to the total disk allocation for all files in the directory in blocks. 1 block = 1024 bytes.            

Rows with leftmost character=`d` represent directories. To list directories only, run:

```sh
$ ls -ld */
drwxr-xr-x 313 cac9159 pmltmodu 16384 Aug  6 14:06 anaconda3/
drwxr-xr-x   5 cac9159 pmltmodu 16384 Sep 19 09:17 CALC2019/
drwxr-xr-x   2 cac9159 pmltmodu 16384 Aug 28 16:05 Computer_Vision/
drwxr-xr-x   2 cac9159 pmltmodu 16384 Sep 22 13:58 Datasets/
drwxr-x---   7 cac9159 pmltmodu 16384 May 24 11:39 Dev/
drwxr-xr-x   5 cac9159 pmltmodu 16384 Jun 17 08:47 html/
drwx------  16 cac9159 pmltmodu 16384 Aug 23 12:02 local/
drwxr-xr-x   7 cac9159 pmltmodu 16384 Aug 16 08:17 LTC/
drwxr-xr-x   4 cac9159 pmltmodu 16384 Nov  2  2018 Projects/
drwx-w----   2 cac9159 pmltmodu 16384 Jun 27  2018 PyPI/
drwxr-xr-x  11 cac9159 pmltmodu 16384 Aug  5 16:23 Repos/
drwxr-xr-x   2 cac9159 pmltmodu 16384 Mar 25 16:01 Source/
drwxr-x---   3 cac9159 pmltmodu 16384 Aug 23 11:49 Temp/
drwxr-xr-x   2 cac9159 pmltmodu 16384 Nov  2  2018 Utils/
```
<br>


New directories are created using `mkdir`. Let's create a new folder in your local copy of the *LinuxDemo* repository named *Session*:

```sh
$ cd /home/i103455/LinuxDemo
$ mkdir Session
```
<br>

Files are copied from one location to another using `cp`. To copy the *contacts1.txt* file under *LinuxDemo/DataFiles* to the newly created *Session* directory, run:

```sh
$ pwd
/home/i103455/LinuxDemo
$ cp DataFiles/contacts1.txt Session
```
<br>

Since we're not changing the name of the copied file, we only need to specify the path to the destination directory. If we'd prefer to change the name at the destination to *contactsCopy.txt*, include the new name along with the destination directory:

```sh
$ cp DataFiles/contacts1.txt Session/contactsCopy.txt
```

Listing the contents of *Session* yields:

```sh
$ ls -l ./Session
total 32
-rwxr-xr-x 1 cac9159 pmltmodu 1886 Sep 23 08:41 contacts1.txt
-rwxr-xr-x 1 cac9159 pmltmodu 1886 Sep 23 08:44 contactsCopy.txt
```
<br>

Although not relevant for this session, the command used to create new empty files is `touch`. Enter `touch` followed by a filename to create an empty file with that name in the current working directory by default, or the location specified.      



#### A brief aside on Linux file permissions

On Windows, the type of a particular file is determined by it's extension, with executables typically designated with `.exe` or `.bat`. On Linux, there is a notion of an executable file which is independent of the file name. A file is deemed executable or not based on the file's permission.        

Notice the 10 leftmost characters for each row of `ls -l`'s output. This represents the file's permissions, and can be decoded as follows:

```sh
- rwx rw- r--
|  |   |   |    
|  |   |   |---> Read, write and execute permissions for all other users
|  |   |          
|  |   |-------> Read, write and execute permissions for members of the       
|  |             group owning the file
|  |
|  |-----------> Read, write and execute permissions for the owner of       
|                the file
|           
|--------------> File type: "-" means a file. "d" means a directory    
```

`r`, `w`, and `x` are interpeted as follows:      
- `r`: read a file or list a directory's contents       
- `w`: write to a file or directory       
- `x`: execute a file or recurse a directory tree 

Take note of the permission of the `rand.py` file in the top-level of the *LinuxDemo* directory:

```sh
$ cd /LinuxDemo
$ ls -l rand.py
-rw-r--r-- 1 cac9159 pmltmodu 225 Sep 22 15:01 rand.py
```

Notice that the execute bit is switched off for owner (the fourth position). Attempting to execute this file results in the following error message:

```bash
$ ./rand.py
-bash: ./rand.py: Permission denied
```
<br>

Users can grant themselves execute permission on by running the following:

```sh
$ chmod u+x rand.py
```

This grants the user (`u`) execute permission (`x`). Now, if I run `ls -l` in the current working directory, the owner execute bit has been switched on:

```bash
$ ls -l rand.py
-rwxr--r-- 1 cac9159 pmltmodu 225 Sep 22 15:01 rand.py
```
Now the script can be executed, resulting in:

```sh
$ ./rand.py 
0.7640548021149717
0.7983703742897071
0.47849214280578334
0.8986326153078964
0.05104912092550762
0.08228338184856032
0.49640891633553796
0.18007616900626944
0.8226615683918113
0.2019871328424585
```

<br>

In addition to symbolic file permissions described above, each file system object has an associated 3-digit octal permission specification. This conveys the same information as the symbolic notation, but in a more concise notation. The octal representation of a filesystem permission can be obtained by running the following:

```sh
$ stat --format %a <filename>
```

To determine the octal permission associated with `rand.py`, run:

```sh
$ stat --format %a rand.py
744
```

If the current working directory is the same as the directory in which the target file resides, then the filename can be given without the absolute path. But if the file resides in a directory different directory, you need
to provide the full path to the file system object. This is the case for all Bash utilities that take a file as an argument. 

A convenient utility to help translate octal permission codes into actual permissions can be found [here](http://permissions-calculator.org/).


#### Getting Help

Almost every Bash utility can be called with the inclusion of `-h` or `--help`. This usually provides basic information about the application, and lists common flags that can be used to alter the default behavior. The `free` command gives information related to available system memory. To see additional options that can be called with free, run the following:

```sh
$ free --help
free: invalid option -- '-'
usage: free [-b|-k|-m|-g|-h] [-l] [-o] [-t] [-s delay] [-c count] [-V]
  -b,-k,-m,-g show output in bytes, KB, MB, or GB
  -h human readable output (automatic unit scaling)
  -l show detailed low and high memory statistics
  -o use old format (no -/+buffers/cache line)
  -t display total for RAM + swap
  -s update every [delay] seconds
  -c update [count] times
  -a show available memory if exported by kernel (>80 characters per line)
  -V display version information and exit
```

From the third line, it is possible to alter the displayed units of available memory for greater interpretability (adding `-g` for Gigabytes):

```sh
$ free -g
            total       used       free     shared    buffers     cached
Mem:          520        249        270          0          0          1
-/+ buffers/cache:       247        272
Swap:           7          7          0
```

In this view, total memory = 520GB, available memory = 270GB, etc.         

Some command line utilities have many options, which wouldn't fit within the current screen. In order to page through the results, we will pass the help output to the `less` command (the `|` is the *pipe operator*, covered in detail 
later) which results in paginating the results:

```sh
$ ls --help
Usage: ls [OPTION]... [FILE]...
List information about the FILEs (the current directory by default).
Sort entries alphabetically if none of -cftuvSUX nor --sort.

Mandatory arguments to long options are mandatory for short options too.
  -a, --all                  do not ignore entries starting with .
  -A, --almost-all           do not list implied . and ..
      --author               with -l, print the author of each file
  -b, --escape               print octal escapes for nongraphic characters
      --block-size=SIZE      use SIZE-byte blocks.  See SIZE format below
  -B, --ignore-backups       do not list implied entries ending with ~
  -c                         with -lt: sort by, and show, ctime (time of last
                               modification of file status information)
                               with -l: show ctime and sort by name
                               otherwise: sort by ctime
  -C                         list entries by columns
      --color[=WHEN]         colorize the output.  WHEN defaults to `always'
                               or can be `never' or `auto'.  More info below
  -d, --directory            list directory entries instead of contents,
                               and do not dereference symbolic links
  -D, --dired                generate output designed for Emacs' dired mode
  -f                         do not sort, enable -aU, disable -ls --color
  -F, --classify             append indicator (one of */=>@|) to entries
      --file-type            likewise, except do not append `*'
      --format=WORD          across -x, commas -m, horizontal -x, long -l,
                               single-column -1, verbose -l, vertical -C
      --full-time            like -l --time-style=full-iso
  -g                         like -l, but do not list owner
      --group-directories-first
                             group directories before files.
                               augment with a --sort option, but any
                               use of --sort=none (-U) disables grouping
  -G, --no-group             in a long listing, don't print group names
  -h, --human-readable       with -l, print sizes in human readable format
                               (e.g., 1K 234M 2G)
      --si                   likewise, but use powers of 1000 not 1024
  -H, --dereference-command-line
                             follow symbolic links listed on the command line
      --dereference-command-line-symlink-to-dir
                             follow each command line symbolic link
                             that points to a directory
      --hide=PATTERN         do not list implied entries matching shell PATTERN
                               (overridden by -a or -A)
      --indicator-style=WORD  append indicator with style WORD to entry names:
                               none (default), slash (-p),
                               file-type (--file-type), classify (-F)
  -i, --inode                print the index number of each file
  -I, --ignore=PATTERN       do not list implied entries matching shell PATTERN
:
```


Notice the `:` at the end: This indicates that additional text can be read. Continue using either Page Up/Down or the Up/Down arrow keys. To exit, press `q`. 

Greater detail about a command can be obtained by accessing the Linux man pages. For `ls`, simply enter and execute `man ls`:

```sh
$ man ls
```

To exit a man page, simply press `q`. 


#### Environment & Shell Variables

Upon initialization, the Bash sheel defines a number of *environment variables*, which dictates the shell dimensions, terminal details and the language to use among other things. We can generate a list of all shell environment variables
by running `printenv`:

```sh
$ printenv
CPLUS_INCLUDE_PATH=:/SAS/misc/jtrive/local/include
HOSTNAME=lrau1p11.cna.com
TERM=xterm-256color
SHELL=/bin/bash
HISTSIZE=10000
SSH_CLIENT=10.192.18.97 62953 2245
QTDIR=/usr/lib64/qt-3.3
QTINC=/usr/lib64/qt-3.3/include
SSH_TTY=/dev/pts/8
SVN_EDITOR=/usr/bin/vim
USER=cac9159
LIBPATH=/csapps/oracle/product/11.2.0.3/odbc/lib:
MAIL=/var/spool/mail/cac9159
PATH=/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:/home/i103455/bin
C_INCLUDE_PATH=:/SAS/misc/jtrive/local/include
PWD=/home/cac9159
JAVA_HOME=/SAS/misc/jtrive/local/jdk1.8.0_211
EDITOR=/usr/bin/vim
LANG=en_US.UTF-8
PYTHONSTARTUP=/home/cac9159/.pythonstartup
MODULEPATH=/usr/share/Modules/modulefiles:/etc/modulefiles
LOADEDMODULES=
HISTCONTROL=ignoreboth
NEXT_RECURSION_LVL=1
SHLVL=1
HOME=/home/cac9159
TMP=/SAS/misc/tmp
LOGNAME=cac9159
QTLIB=/usr/lib64/qt-3.3/lib
ODBCHOME=/csapps/oracle/product/11.2.0.3/odbc
SSH_CONNECTION=10.192.18.97 62953 10.12.32.147 2245
MODULESHOME=/usr/share/Modules
LESSOPEN=||/usr/bin/lesspipe.sh %s
PROMPT_COMMAND=history -a; history -c; history -r;
SHLIB_PATH=/csapps/oracle/product/11.2.0.3/odbc/lib:
ORACLE_HOME=/csapps/oracle/product/11.2.0.3/
HISTTIMEFORMAT=%F %T #
G_BROKEN_FILENAMES=1
HISTFILE=/var/log/hist/cac9159/sh_history.lrau1p11.fr.cac9159.to.cac9159
```
<br>

To print the value associated with a shell variable, we use the `echo` command plus the name of the variable prefixed with `$`. For example, to print the value bound to the `SHELL` variable, run:

```sh
$ echo $SHELL
/bin/bash
```

It possible to set user defined environment variables with `=`. Never include space on either side of `=`. For example, to create a variable named `myshell` with the same value associated with `SHELL`, run:

```sh
$ myshell=$SHELL
$ echo $myshell
/bin/bash
```

User defined environment variables only last the duration of the session in which they are defined. Once the session terminates, so will `myshell`. 

In practice, you may see shell variables surrounded by curly braces. This notation is equivalent to the dollar-sign-only notation. There is no difference in interpretation:

```sh
$ myshell=$SHELL
$ echo $myshell
/bin/bash
$ echo ${myshell}
/bin/bash
```

To define variables that contain whitespace, it is necessary to surround the r.h.s. of the expression in quotes:

```sh
$ str="wont you step into the freezer..."
$ echo $str
wont you step into the freezer...
```


##### Quoting behavior in Bash

Within the context of the Bash shell, single and double quotes have different meanings. Surrounding a variable in sigle quotes preserves the literal value of each character within the quotes. Enclosing characters in double quotes preserves 
the literal value of all characters within the quotes with the exception of `$`-prefixed shell variables.     
To demonstrate, we first use double quotes, which will expand `USER`, `HOSTNAME` and `SECONDS` as intended:

```sh
$ echo "$USER has been logged into $HOSTNAME for $SECONDS seconds."
i103455 has been logged into lrau1p11.cna.com for 8029 seconds.
```

Running the same command surrounded by single quotes yields:

```sh
$ echo '$USER has been logged into $HOSTNAME for $SECONDS seconds.'
$USER has been logged into $HOSTNAME for $SECONDS seconds.
```

Using single quotes treats our variables as `$`-prefixed character strings, and does not expand the values.  



##### Checkpoint 1

> Take a look at the help print out for the `cal` command: Is there an option print all 12 months of the year simultaneously?


<br>

#### Standard Streams

In Linux each process has three i/o channels (default configurations provided):

- **stdin** (#0: standard input) - typically the keyboard      

- **stdout** (#1: standard output) - typically the monitor or a file  

- **stderr** (#2: standard error)  - typically the monitor or a file      



A diagram representing the relationship between stdin, stdout and stderr:


```
                     0 - stdin    ------------
                    /------------ | keyboard |       
                   /              ------------
                  /
-----------      /
| process | <---/
----------- \       1 - stdout       
    |        \------------------> -----------
    |                             | monitor |
    |---------------------------> -----------  
                    2 - stderr
```


##### Output redirection

It is possible to redirect the output stream of a command to a file instead of the terminal output buffer. We demonstrate two redirection operators:

- `>`: Write stream to the specified file, overwriting existing content.         
- `>>`: Write stream to specified file, appending after existing content.  

<br>

##### Redirection examples


We can  display the Python help menu by running:

```
$ python3 --help
usage: python3 [option] ... [-c cmd | -m mod | file | -] [arg] ...
Options and arguments (and corresponding environment variables):
-b     : issue warnings about str(bytes_instance), str(bytearray_instance)
         and comparing bytes/bytearray with str. (-bb: issue errors)
-B     : don't write .pyc files on import; also PYTHONDONTWRITEBYTECODE=x
-c cmd : program passed in as string (terminates option list)
-d     : debug output from parser; also PYTHONDEBUG=x
-E     : ignore PYTHON* environment variables (such as PYTHONPATH)
-h     : print this help message and exit (also --help)
-i     : inspect interactively after running script; forces a prompt even
         if stdin does not appear to be a terminal; also PYTHONINSPECT=x
-I     : isolate Python from the user's environment (implies -E and -s)
-m mod : run library module as a script (terminates option list)
-O     : remove assert and __debug__-dependent statements; add .opt-1 before
         .pyc extension; also PYTHONOPTIMIZE=x
-OO    : do -O changes and also discard docstrings; add .opt-2 before
         .pyc extension
-q     : don't print version and copyright messages on interactive startup
-s     : don't add user site directory to sys.path; also PYTHONNOUSERSITE
-S     : don't imply 'import site' on initialization
-u     : force the stdout and stderr streams to be unbuffered;
         this option has no effect on stdin; also PYTHONUNBUFFERED=x
-v     : verbose (trace import statements); also PYTHONVERBOSE=x
         can be supplied multiple times to increase verbosity
-V     : print the Python version number and exit (also --version)
         when given twice, print more information about the build
-W arg : warning control; arg is action:message:category:module:lineno
         also PYTHONWARNINGS=arg
-x     : skip first line of source, allowing use of non-Unix forms of #!cmd
-X opt : set implementation-specific option
--check-hash-based-pycs always|default|never:
    control how Python invalidates hash-based .pyc files
file   : program read from script file
-      : program read from stdin (default; interactive mode if a tty)
arg ...: arguments passed to program in sys.argv[1:]

Other environment variables:
PYTHONSTARTUP: file executed on interactive startup (no default)
PYTHONPATH   : ':'-separated list of directories prefixed to the
               default module search path.  The result is sys.path.
PYTHONHOME   : alternate <prefix> directory (or <prefix>:<exec_prefix>).
               The default module search path uses <prefix>/lib/pythonX.X.
PYTHONCASEOK : ignore case in 'import' statements (Windows).
PYTHONIOENCODING: Encoding[:errors] used for stdin/stdout/stderr.
PYTHONFAULTHANDLER: dump the Python traceback on fatal errors.
PYTHONHASHSEED: if this variable is set to 'random', a random value is used
   to seed the hashes of str, bytes and datetime objects.  It can also be
   set to an integer in the range [0,4294967295] to get hash values with a
   predictable seed.
PYTHONMALLOC: set the Python memory allocators and/or install debug hooks
   on Python memory allocators. Use PYTHONMALLOC=debug to install debug
   hooks.
PYTHONCOERCECLOCALE: if this variable is set to 0, it disables the locale
   coercion behavior. Use PYTHONCOERCECLOCALE=warn to request display of
   locale coercion and locale compatibility warnings on stderr.
PYTHONBREAKPOINT: if this variable is set to 0, it disables the default
   debugger. It can be set to the callable of your debugger of choice.
PYTHONDEVMODE: enable the development mode.
```

Alternatively, we can redirect the Python help menu content to file:

```sh
$ python3 --help > pyhelp.txt
```

Nothing will be printed to the screen, but a file will be created in your current working directory identified as *pyhelp.txt*. You can display the contents with `cat`:

```
$ cat pyhelp.txt
usage: python3 [option] ... [-c cmd | -m mod | file | -] [arg] ...
Options and arguments (and corresponding environment variables):
-b     : issue warnings about str(bytes_instance), str(bytearray_instance)
         and comparing bytes/bytearray with str. (-bb: issue errors)
-B     : don't write .pyc files on import; also PYTHONDONTWRITEBYTECODE=x
-c cmd : program passed in as string (terminates option list)
-d     : debug output from parser; also PYTHONDEBUG=x
-E     : ignore PYTHON* environment variables (such as PYTHONPATH)
-h     : print this help message and exit (also --help)
-i     : inspect interactively after running script; forces a prompt even
         if stdin does not appear to be a terminal; also PYTHONINSPECT=x
-I     : isolate Python from the user's environment (implies -E and -s)
-m mod : run library module as a script (terminates option list)
-O     : remove assert and __debug__-dependent statements; add .opt-1 before
         .pyc extension; also PYTHONOPTIMIZE=x
-OO    : do -O changes and also discard docstrings; add .opt-2 before
         .pyc extension
-q     : don't print version and copyright messages on interactive startup
-s     : don't add user site directory to sys.path; also PYTHONNOUSERSITE
-S     : don't imply 'import site' on initialization
-u     : force the stdout and stderr streams to be unbuffered;
         this option has no effect on stdin; also PYTHONUNBUFFERED=x
-v     : verbose (trace import statements); also PYTHONVERBOSE=x
         can be supplied multiple times to increase verbosity
-V     : print the Python version number and exit (also --version)
         when given twice, print more information about the build
-W arg : warning control; arg is action:message:category:module:lineno
         also PYTHONWARNINGS=arg
-x     : skip first line of source, allowing use of non-Unix forms of #!cmd
-X opt : set implementation-specific option
--check-hash-based-pycs always|default|never:
    control how Python invalidates hash-based .pyc files
file   : program read from script file
-      : program read from stdin (default; interactive mode if a tty)
arg ...: arguments passed to program in sys.argv[1:]

Other environment variables:
PYTHONSTARTUP: file executed on interactive startup (no default)
PYTHONPATH   : ':'-separated list of directories prefixed to the
               default module search path.  The result is sys.path.
PYTHONHOME   : alternate <prefix> directory (or <prefix>:<exec_prefix>).
               The default module search path uses <prefix>/lib/pythonX.X.
PYTHONCASEOK : ignore case in 'import' statements (Windows).
PYTHONIOENCODING: Encoding[:errors] used for stdin/stdout/stderr.
PYTHONFAULTHANDLER: dump the Python traceback on fatal errors.
PYTHONHASHSEED: if this variable is set to 'random', a random value is used
   to seed the hashes of str, bytes and datetime objects.  It can also be
   set to an integer in the range [0,4294967295] to get hash values with a
   predictable seed.
PYTHONMALLOC: set the Python memory allocators and/or install debug hooks
   on Python memory allocators. Use PYTHONMALLOC=debug to install debug
   hooks.
PYTHONCOERCECLOCALE: if this variable is set to 0, it disables the locale
   coercion behavior. Use PYTHONCOERCECLOCALE=warn to request display of
   locale coercion and locale compatibility warnings on stderr.
PYTHONBREAKPOINT: if this variable is set to 0, it disables the default
   debugger. It can be set to the callable of your debugger of choice.
PYTHONDEVMODE: enable the development mode.
```
<br>

Let's append the current date and time to *pyhelp.txt*. Since we want to append and not overwrite, we use `>>`:

```sh
$ echo $(date) >> pyhelp.txt
```

<br>

Instead of using `cat`, if we only want to view the first or last n lines of a file, we can use `head` or `tail`. To verify that the date and time were successfully appended to *pyhelp.txt*, run:

```sh
$ tail pyhelp.txt -n 5
locale coercion and locale compatibility warnings on stderr.
PYTHONBREAKPOINT: if this variable is set to 0, it disables the default
   debugger. It can be set to the callable of your debugger of choice.
PYTHONDEVMODE: enable the development mode.
Sun Sep 22 18:52:20 CDT 2019
```

Similarly with `head`:

```sh
$ head pyhelp.txt -n 10
usage: python3 [option] ... [-c cmd | -m mod | file | -] [arg] ...
Options and arguments (and corresponding environment variables):
-b     : issue warnings about str(bytes_instance), str(bytearray_instance)
         and comparing bytes/bytearray with str. (-bb: issue errors)
-B     : don't write .pyc files on import; also PYTHONDONTWRITEBYTECODE=x
-c cmd : program passed in as string (terminates option list)
-d     : debug output from parser; also PYTHONDEBUG=x
-E     : ignore PYTHON* environment variables (such as PYTHONPATH)
-h     : print this help message and exit (also --help)
-i     : inspect interactively after running script; forces a prompt even
```
<br>

The `-n` modifier specifies the number of lines written to stdout, and we see that the date and time was correctly appended. 


##### The pipe operator

The pipe operator  (`|`) is one of the most powerful features of Bash. It takes the output from the first command and passes it along as the input into a second command. You can combine an arbitrary number of commands together using 
a sequence of pipes. To demonstrate, refer to *Gettysburg.txt* in the *DataFiles* directory of the 
*LinuxDemo* repository, which is the text of the Gettysburg Address. The `wc` command (**w**ord **c**ount) returns the number of characters, words, lines or bytes in a given file. To obtain character, word and line count summaries for the Gettysburg Address, first read the contents of the file into the shell with `cat`, then pipe the result into `wc` to obtain character, word and line count summaries:

```sh
$ cd LinuxDemo/DataFiles
$ cat Gettysburg.txt | wc -c
1512
$ cat DOI.txt | wc -w
278
$ cat DOI.txt | wc -l
21
```

The pipe operator has many uses, and is one of the primary building blocks used to develop more complex, targeted applications.

It is possible to redirect content to file while simultaneously writing the output to the terminal. The `tee` command 
facilitates this behavior. It functions as follows:

```
-------------       -------------       ------------
|  command  | ----> |    tee    | ----> |  stdout  |
-------------       -------------       ------------
                          |
                          |
                          v
                    -------------
                    |   file    |
                    -------------      
```

For example, we can generate a continuous stream of random text via:

```sh
$ cat /dev/urandom | hexdump -C | grep "00 ff a"
```

To write the stream to a file named *randstream.txt* within the *LinuxDemo/Session* directory while also printing to content the terminal, use `tee` as follows:

```sh
$ cat /dev/urandom | hexdump -C | grep "00 ff a" 2>&1 | tee Session/randstream.txt
```




 
#### Regular Expressions


> *Some people, when confronted with a problem, think "I know, I'll use regular 
> expressions." Now they have two problems...*


*Regular expressions* are sequences of characters that define a search pattern. 


- In Excel, the functions `MID`, `MATCH`, `LEFT`, `RIGHT` are examples of regular expression utilities.    
- In SQL, `LIKE` is an example of a regular expression.     
- Online passwords are almost always validated against a regular expression pattern:

```sh
Your password has to be at least 6 characters long must contain at least one
lower case letter, one upper case letter, one digit and one of these special 
characters ~!@#$%^&\*()_+*.
```


grep (**g**lobally search a **r**egular **e**xpression and **p**rint) is a command line utility used for matching patterns in files. It can be used to match string literals or complex regular expression patterns.

* grep wildcard behavior: 

    - `.`: Matches any character        
     
    - `.*`: Match any character 0 or more times      
    
    - `.+`: Match any character 1 or more times	    
   



The following characters have special meaning within the context of regular expression patterns: 

```
. ^ $ * + ? { } [ ] \ | ( )`.
```


* To supress the special meaning and match the character literal, it must be escaped using a backslash, i.e. `\(`.       

* grep uses `\b` to match word boundaries. This makes it easy to match the beginning or end of a string.      

<br>

#### Checkpoint 2


> Refer to *words.txt* under the *LinuxDemo/DataFiles*. The file contains 479k words/expressions, 1-per-line. Determine how many words/expressions are contained in *words.txt*. Instead of printing the number to the terminal, redirect the result to a file identified as *numwords.txt* to the *LinuxDemo/Session* directory you created previously. 

<br>



Thus far, anytime we've needed to process the contents of a file, we'd first `cat` the file contents, then pipe the text stream into some other command. grep can process files directly, so it isn't necessary to first invoke `cat`. In what follows, I demonstrate a few examples using grep and the *words.txt* file introduced in the previous checkpoint.  

> NOTE: All grep invocations that follow include the `-E` flag, which puts grep into *extended regular expression mode*, which facilitates the matching of string literals as well as special characters representing more general patterns. `grep -E` is equivalent to `egrep`.

<br>

#### grep Examples

Referring to *words.txt*, match all words beginning with `a`:

```sh
$ cd LinuxDemo/DataFiles
$ grep -E "^a.*" words.txt
```
In regular expressions, `^` specifies to match only at the beginning of the string. If we omitted `^` in the previous regular expression pattern, any word containing `a` would be matched. Analagously, `$` indicates matches should be limited to those words ending with a particular character. 


To count the number of words beginning with `a`, pipe the output from grep into `wc`:

```sh 
$ grep -E "^a.*" words.txt | wc -l
24370
```

Determine how many words end with `"a"`:

```sh
$ grep -E ".*a$" words.txt | wc -l
21996
```

Determine the number of words that begin **and** end with `"a"`:

```sh
$ grep -E "^a.*a$" words.txt | wc -l
1236
```


Determine the number of words that start with **or** end with `"a"`:

```sh
$ grep -E "^a.*|.*a$" words.txt | wc -l
45129
```

<br>

For the next set of examples, I introduce additional useful commands `cut`, `sort`, `uniq` and `column`.        

Refer to *Claims.csv* in the *DataFiles* directory. It contains the following:

```sh
$ cd LinuxDemo/DataFiles
$ cat Claims.csv
POL_NBR,CLAIM_NBR,DATE,COVERAGE,PERIL,PAID_LOSS
1074791123,E279125111,201107,BLD,WTHR,723
1075057421,E284425321,201202,BLD,FIRE,23857
2084331344,E247837611,201803,CONT,FIRE,0
2084600815,E227172511,200912,PROP,GL,15000
2084601446,E226938811,201703,PROP,GL,997
2084665809,E222760211,201809,PROP,GL,0
2090807281,2R81103011,202002,CONT,WTHR,1450
2091086944,E245369911,201611,BLD,WTHR,42750
2097695314,E255945212,201905,CONT,FIRE,5000
```

We want to extract the unique combinations of *COVERAGE* and *PERIL*, then sort the results alphabetically. Create a copy of *Claims.csv* excluding the header and save it to the *Session* directory as *Claims2.csv*:     

```sh
$ cat Claims.csv | tail -n +2 > Claims2.csv
```

With the header excluded, we construct a pipeline that produces a list of the unique combinations of *COVERAGE* and *PERIL*:

```sh
$ cd Session
$ cat Claims2.csv | cut --delimiter=, --fields=4,5 | sort | uniq
BLD,FIRE
BLD,WTHR
CONT,FIRE
CONT,WTHR
PROP,GL
```

We can add a final command to "pretty print" the resulting list of unique coverage/peril combinations:

```sh
$ cat Claims2.csv | cut --delimiter=, --fields=4,5 | sort | uniq | column -t -s ","
BLD   FIRE
BLD   WTHR
CONT  FIRE
CONT  WTHR
PROP  GL
```

The pipeline deconstructed:  

- Read the contents of of *Claims2.csv*.    

- Specify the delimiter, and extract fields at position 4 & 5 (1-based indexing).        

- Sort the results alphabetically.       

- Keep only unique records.          

- Pretty print the remaining rows (`-t`), specifying the delimiter (`-s ","`).            

<br>


grep can be used to search a directory tree for a pattern recursively. When printing the results, it is useful to include the filename and line number on which the match occurs.      

Refer to the *Source* directory located at *DataFiles/Source* in the *LinuxDemo* repository. The directory contains two files from the Python standard library.       

Within Python, functions are declared as `def funcname(args)`. Every function declaration (not including lambda expressions) starts with `def`. We can recursively search the *Source* directory, identifying all function declarations, printing the match, filename and line number within the given file:

```sh
$ grep -EHnr "def.+\(" DataFiles/Source/* --colour=always
DataFiles/Source/csv.py:43:    def __init__(self):
DataFiles/Source/csv.py:48:    def _validate(self):
DataFiles/Source/csv.py:82:    def __init__(self, f, fieldnames=None, restkey=None, restval=None,
DataFiles/Source/csv.py:91:    def __iter__(self):
DataFiles/Source/csv.py:95:    def fieldnames(self):
DataFiles/Source/csv.py:105:    def fieldnames(self, value):
DataFiles/Source/csv.py:108:    def __next__(self):
DataFiles/Source/csv.py:132:    def __init__(self, f, fieldnames, restval="", extrasaction="raise",
DataFiles/Source/csv.py:142:    def writeheader(self):
DataFiles/Source/csv.py:146:    def _dict_to_list(self, rowdict):
DataFiles/Source/csv.py:154:    def writerow(self, rowdict):
DataFiles/Source/csv.py:157:    def writerows(self, rowdicts):
DataFiles/Source/csv.py:171:    def __init__(self):
DataFiles/Source/csv.py:176:    def sniff(self, sample, delimiters=None):
DataFiles/Source/csv.py:205:    def _guess_quote_and_delimiter(self, data, delimiters):
DataFiles/Source/csv.py:281:    def _guess_delimiter(self, data, delimiters):
DataFiles/Source/csv.py:384:    def has_header(self, sample):
DataFiles/Source/subprocess.py:67:    def __init__(self, returncode, cmd, output=None, stderr=None):
DataFiles/Source/subprocess.py:73:    def __str__(self):
DataFiles/Source/subprocess.py:86:    def stdout(self):
DataFiles/Source/subprocess.py:91:    def stdout(self, value):
DataFiles/Source/subprocess.py:104:    def __init__(self, cmd, timeout, output=None, stderr=None):
DataFiles/Source/subprocess.py:110:    def __str__(self):
DataFiles/Source/subprocess.py:115:    def stdout(self):
DataFiles/Source/subprocess.py:119:    def stdout(self, value):
DataFiles/Source/subprocess.py:130:        def __init__(self, *, dwFlags=0, hStdInput=None, hStdOutput=None,
DataFiles/Source/subprocess.py:139:        def _copy(self):
DataFiles/Source/subprocess.py:202:        def Close(self, CloseHandle=_winapi.CloseHandle):
DataFiles/Source/subprocess.py:207:        def Detach(self):
DataFiles/Source/subprocess.py:213:        def __repr__(self):
DataFiles/Source/subprocess.py:226:def _cleanup():
DataFiles/Source/subprocess.py:246:def _optim_args_from_interpreter_flags():
DataFiles/Source/subprocess.py:256:def _args_from_interpreter_flags():
DataFiles/Source/subprocess.py:315:def call(*popenargs, timeout=None, **kwargs):
DataFiles/Source/subprocess.py:332:def check_call(*popenargs, **kwargs):
DataFiles/Source/subprocess.py:351:def check_output(*popenargs, timeout=None, **kwargs):
DataFiles/Source/subprocess.py:409:    def __init__(self, args, returncode, stdout=None, stderr=None):
DataFiles/Source/subprocess.py:415:    def __repr__(self):
DataFiles/Source/subprocess.py:424:    def check_returncode(self):
DataFiles/Source/subprocess.py:431:def run(*popenargs,
DataFiles/Source/subprocess.py:491:def list2cmdline(seq):
DataFiles/Source/subprocess.py:564:def getstatusoutput(cmd):
DataFiles/Source/subprocess.py:595:def getoutput(cmd):
DataFiles/Source/subprocess.py:656:    def __init__(self, args, bufsize=-1, executable=None,
DataFiles/Source/subprocess.py:806:    def universal_newlines(self):
DataFiles/Source/subprocess.py:812:    def universal_newlines(self, universal_newlines):
DataFiles/Source/subprocess.py:815:    def _translate_newlines(self, data, encoding, errors):
DataFiles/Source/subprocess.py:819:    def __enter__(self):
DataFiles/Source/subprocess.py:822:    def __exit__(self, exc_type, value, traceback):
DataFiles/Source/subprocess.py:850:    def __del__(self, _maxsize=sys.maxsize, _warn=warnings.warn):
DataFiles/Source/subprocess.py:865:    def _get_devnull(self):
DataFiles/Source/subprocess.py:870:    def _stdin_write(self, input):
DataFiles/Source/subprocess.py:895:    def communicate(self, input=None, timeout=None):
DataFiles/Source/subprocess.py:963:    def poll(self):
DataFiles/Source/subprocess.py:969:    def _remaining_time(self, endtime):
DataFiles/Source/subprocess.py:977:    def _check_timeout(self, endtime, orig_timeout):
DataFiles/Source/subprocess.py:985:    def wait(self, timeout=None):
DataFiles/Source/subprocess.py:1013:        def _get_handles(self, stdin, stdout, stderr):
DataFiles/Source/subprocess.py:1085:        def _make_inheritable(self, handle):
DataFiles/Source/subprocess.py:1094:        def _filter_handle_list(self, handle_list):
DataFiles/Source/subprocess.py:1107:        def _execute_child(self, args, executable, preexec_fn, close_fds,
DataFiles/Source/subprocess.py:1204:        def _internal_poll(self, _deadstate=None,
DataFiles/Source/subprocess.py:1221:        def _wait(self, timeout):
DataFiles/Source/subprocess.py:1237:        def _readerthread(self, fh, buffer):
DataFiles/Source/subprocess.py:1242:        def _communicate(self, input, endtime, orig_timeout):
DataFiles/Source/subprocess.py:1294:        def send_signal(self, sig):
DataFiles/Source/subprocess.py:1308:        def terminate(self):
DataFiles/Source/subprocess.py:1329:        def _get_handles(self, stdin, stdout, stderr):
DataFiles/Source/subprocess.py:1383:        def _execute_child(self, args, executable, preexec_fn, close_fds,
DataFiles/Source/subprocess.py:1526:        def _handle_exitstatus(self, sts, _WIFSIGNALED=os.WIFSIGNALED,
DataFiles/Source/subprocess.py:1544:        def _internal_poll(self, _deadstate=None, _waitpid=os.waitpid,
DataFiles/Source/subprocess.py:1579:        def _try_wait(self, wait_flags):
DataFiles/Source/subprocess.py:1592:        def _wait(self, timeout):
DataFiles/Source/subprocess.py:1633:        def _communicate(self, input, endtime, orig_timeout):
DataFiles/Source/subprocess.py:1730:        def _save_input(self, input):
DataFiles/Source/subprocess.py:1742:        def send_signal(self, sig):
DataFiles/Source/subprocess.py:1748:        def terminate(self):
DataFiles/Source/subprocess.py:1753:        def kill(self):
```

The pipeline deconstructed:

* `grep -EHnr`:
    - `E`: Extended regular expression.    
    - `H`: Print filename for each match.       
    - `n`: Print line number for each match.        
    - `r`: Search target director recursively.             

* `"def.+\("`: The regular expression pattern. grep searches for `"def"`, 
followed by 1 or more characters, followed by an open paren. Notice that
we need to escape the paren since it is has special meaning within the context
of regular expressions. By escaping it with `\(`, it removes the 
special behavior is negated, and instead searches for a literal match.        

* `DataFiles/Source/*`: The directory to search through recursively.             



<br>

Web scraping consists of nothing more than applying regular expressions to a web page's underlying html:

[A Python PDF Harvester in Fewer Than 25 LOC](http://www.jtrive.com/a-python-pdf-harvester-in-fewer-than-25-loc.html)         


A regular expression to match all links to PDF documents within a webpage could be something like:

```sh
(?=href=).*(https?://\S+.pdf).*?>
```

Pythex can be used as a sandbox to test regular expressions: [pythex](https://pythex.org/). A snippet of html with embedded PDF links (search for the `href` tags):

```html
</li>
<a rel="nofollow" class="external text" href="http://www.rasch.org/memo1963.pdf">
"The Poisson Process as a Model for a Diversity of Behavioural Phenomena"</a>
</li>
</span>,
  <a rel="nofollow" class href="https://arxiv.org/pdf/1612.01907.pdf">
        <i>KFAS: Exponential family state space models in R</i>
  </a> <span class="cs1-format">(PDF)</span>, 
  <a href="/wiki/ArXiv" title="ArXiv">arXiv</a>:
        <span class="cs1-lock-free" title="Freely accessible">
  <a rel="nofollow" class="external text" href="//arxiv.org/abs/1612.01907">1612.01907</a>
</span>
```

<br>



##### Basic regular expression symbols AND DESCRIPTIONS

- `\d`:	digit        
- `\D`:	non-digit        
- `\s`:	whitespace: `[ \t\n\r\f\v]`     
- `\S`:	non-whitespace      
- `\w`:	alphanumeric: `[0-9a-zA-Z_]`     
- `\W`:	non-alphanumeric          
- `\`:	escape special characters     
- `.`:	matches any character       
- `^`:	matches beginning of string  
- `$`:	matches end of string       
- `[5b-d]`:	matches any chars `5`, `b`, `c` or `d`       
- `[^a-c6]`: matches any char except `a`, `b`, `c` or `6`      
- `R|S`: matches either regex `R` or regex `S`       
- `*`:	0 or more (append ? for non-greedy)   
- `+`:	1 or more (append ? for non-greedy)    
- `?`:	0 or 1 (append ? for non-greedy)    
- `{m}`:	exactly mm occurrences    
- `{m, n}`:	from m to n. m defaults to 0, n to infinity
- `{m, n}?`:	from m to n, as few as possible      


<br>


#### Difference between `grep` and `find`

- `grep` attempts to match a pre-specified pattern against the content of files.     

- `find` attempts to match a pre-specified pattern against file/directory names themselves.       


**`find` example #1**:

To list all the directories in the CALC2019 repository, run:

```sh
$ cd LinuxDemo
$ find . -type d 
```

As before, `.` represents the current working directory.       
     
We usually wish to exclude the `.git` directory and its contents from searches when using find. To do so, include `-not -iwholename` along with the pattern to exclude:

```sh
$ find . -type d -not -iwholename '*.git*'
```


By default, find will recurse infinitely. We can limit how deep it traverses with the `-maxdepth` flag:

```sh
$ find . -maxdepth 1 -type d -not -iwholename '*.git*'
```


We can change `-type d` to `-type f` to match files:

```sh
find . -type f -not -iwholename '*.git*'
```


find can also search based on a pattern, similar to grep. To match all files in the CALC2019 folder having a `.py` extension, run:

```sh
$ find . -name "*.py" -type f 
```
<br>

Replacing `-name` with `-iname` performs a case-insensitive search.     

A powerful feature of find is the `-delete` flag. Including `-delete` will permanently remove all objects returned by the find search. First run the command without `-delete` to verify the files matched are the files targeted for deletion. Once the files have been identified with find, simply append `-delete` as the final argument:

```sh
$ find -name [PATTERN] -type [f/d] -delete
```

**`find` example #2 (advanced usage):**

It is frequently necessary to count the total number of lines of source code in a project repository. (referred to as "SLOCs"). We can use find in conjunction with `xargs` to obtain a SLOC grand total.

Under *DataFiles*, the *sklearn* folder contains the source files that comprise the popular Python machine learning library *scikit-learn*. We can determine the number of SLOCs in each file that make up scikit-learn as follows:


```sh
$ find . -name "*.py" | xargs wc -l
```

This includes a total at the bottom. To obtain only the total number of lines (not by file), use:   

```sh
$ find DataFiles/sklearn -name ".py" -type f | xargs cat | wc -l
184552
```


It may be necessary to search for more than a single file extension. For example, if we also wanted to include `.pyd` files, the command changes to the following (continue to add as many extensions/patterns as necessary):

```sh
$ find DataFiles/sklearn -type f \( -name "*.py" -o -name "*.pyd" \) | xargs cat | wc -l
209557
```



### Assorted Commands      



##### Killing running processes

We can list the currently running processes associated with our user id with the `ps` command. The output provided by `ps` is coarse by default, so it is necessary to change the default output format to produce a more interpretable summary:

```sh
$ ps o pid,time,args --forest
  PID     TIME COMMAND
25889 00:00:00 -bash
 8293 00:00:25  \_ python3
25823 00:00:00 -bash
 8562 00:00:00  \_ ps o pid,time,args --forest
12970 00:00:00 -bash
25820 00:00:00  \_ tmux
 3743 00:00:00 -bash
25636 00:00:00  \_ vim .bashrc
```

We can kill a process using `kill`. Simply pass the PID to the `kill` command. To terminate the *python3* process above, run:

```sh
$ kill 8293
```

##### Create zip archives

Creating a zip archive is straightforward. To create a file named *Session.zip* comprised of the contents of your local *Session* folder, run:

```sh
$ cd LinuxDemo
$ zip -r Session.zip ./Session
```

##### Email

Sending email from Bash is straightforward:

```sh
$ echo "[Message Body]" | -s "[Subject]" RECIPIENT
```
<br>

To send myself an email, the command is:

```sh
$ echo "Hello $USER" | mailx -s "Hello" JTriveri@guidehome.com
```
<br>

To send a message to 2 or more recipients, provide a comma-delimited list of recipients:

```sh
$ echo "Good afternoon!" | mailx -s "Hello" username1@guidehome.com,username2@guidehome.com
```
<br>

It is possible to include an attachment using the `-a` flag, along with the path to the target file. Let's send the same message, but this time attaching *Claims.csv* in *LinuxDemo/DataFiles*. 

```sh
$ pwd
LinuxDemo
$ echo "Good afternoon!" | mailx -s "Hello" -a DataFiles/Claims.csv James.Triveri@cna.com,Ji.Mei@cna.com
```

To send an email attachment without body text, use the following:

```sh
mailx -a DataFiles/Claims.csv -s "Attachment" James.Triveri@cna.com < /dev/null
```

#### Conclusion

This was only the tip of the iceberg in terms of Linux tools and techniques, but mastery of the examples in this article will have you well on your way.
