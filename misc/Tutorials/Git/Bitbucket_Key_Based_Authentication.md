

## Setting Up Key-Based Authentication to Bitbucket
###### Author: James Triveri


### Prerequisites

In order to setup key-based authentication, the following are required:

* Access to the the Actuarial Bitbucket Project [here](https://git.guidehome.com/projects/AC).    
* The Git Terminal.   


If you are unable to access the Actuarial project on Bitbucket using the link above, submit an IT ticket, and in the comments section, include *Please grant access to the Actuarial Bitbucket project.*


### Setup
    
It is possible to authenticate to Bitbucket using public-key cryptography as opposed entering a password at each login and after each push/pull to/from the shared master respository (referred to as "origin" in Git parlance).. This is far more convenient and relatively straightforward to setup.    


To begin, we need to configure the Windows file explorer so that file extensions are displayed and hidden files and folders are visible. From the file explorer (can be rendered with Windows Key + E), navigate to *Organize > Folder and search options > View*. Under *Hidden files and folders*, select *Show hidden files, folders and drives*, then uncheck *Hide extensions for known file types* if selected.      

Launch the Git terminal. From the Start Menu, under *G*, select *Git > Git Bash*. We need to navigate to the home directory as recognized by Git, which is accomplished by running:
```sh
$ echo $HOME
```

Change the terminal's working directory to your home directory as follows:
```sh
$ pushd $HOME
```

Next, we generate our public-private cryptographic key pair. Ensuring your home directory is the terminal's current working directory (can be verified by running ``pwd``), enter and run the following:

```sh
$ ssh-keygen -t rsa -b 4096
```

You'll be prompted with three questions. For each question, just hit ENTER without entering any text. Upon completion, you're terminal should look like:

```sh
$ ssh-keygen -t rsa -b 4096
Generating public/private rsa key pair.
Enter file in which to save the key (/c/Users/i103455/.ssh/id_rsa):
Created directory '/c/Users/i103455/.ssh'.
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
Your identification has been saved in /c/Users/i103455/.ssh/id_rsa.
Your public key has been saved in /c/Users/i103455/.ssh/id_rsa.pub.
The key fingerprint is:
SHA256:GqRB2OQ6ewkYObB6ccNgvM9NoioP96Tbn/cIvFO7A7E i103455@act-jtriveri
The key's randomart image is:
+---[RSA 4096]----+
|..o+o            |
|.+o=.            |
|= ..* .          |
|.+.+.=o          |
|o =+.+.oS        |
| ..+ooEo.        |
|..o + +o .       |
|oo *  .++.       |
|..+.o.+oo+.      |
+----[SHA256]-----+
```

A folder has been created in your home directory, identified as `.ssh`. This folder contains the generated public-private key pair. The private key can be found in ``~/.ssh/id_rsa``, the public key in ``~/.ssh/id_rsa.pub``.



>   **Never** share your private key. When pasting your key into Bitbucket, make absolutely certain the key you are pasting is from the file with the ``.pub`` extension. 



Next, login to Bitbucket. Once logged in, click on the circle icon in the upper right, and select *Manage Account*. On the left sidebar, click on *SSH keys*. 

Your public and private keys are simply a random assortment of 4096 bits worth of characters, therefore ``id_rsa.pub`` can be opened with a text editor. Navigate to the ``.ssh`` directory created in your home folder, and open ``id_rsa.pub`` in a text editor (use Notepad if you don't have something better). Highlight the contents of your public key, being sure to avoid leading or trailing whitespace. Back in Bitbucket, press the *Add key* button. Paste the contents of your public key into the box, then press *Add key* again.

Back in the Git terminal, add your key to the ssh agent. If executed successfully, a message should be output specifying the process id of the ssh agent (your pid will almost certainly be different):
```sh
$ eval $(ssh-agent)
Agent pid 24220
```

Then add your private key to the ssh-agent. After pressing ENTER, you should see a message indicating that the identity has been added, and will echo back the path of the private key file. 
```sh
$ ssh-add ~/.ssh/id_rsa
Identity added: /c/Users/i103455/.ssh/id_rsa (i103455@act-jtriveri)
```

Finally, you are ready to checkout your own working copy of a project's source files. This isn't required, but I find it helpful to create a new directory named *Repos*, which is used to hold all my source code repositories. Assuming you've created this directory in your home folder, we'll navigate to it and clone the act_env2 project:

```sh
$ pushd /c/Users/i103455/Repos
$ git clone ssh://git@git.guidehome.com:7999/ac/act_env2.git
```	
After hitting enter, you'll see the following::
```sh
Cloning into 'act_env2'...
The authenticity of host '[git.guidehome.com]:7999 ([172.16.204.229]:7999)' can't be established.
RSA key fingerprint is SHA256:ja1F4gmAEtf6w5wMXRomDM0yOnxFofANC764+GIJ16k.
Are you sure you want to continue connecting (yes/no)? 
```

Type "yes" (no quotes) then press ENTER. Once finished, you'll find a new folder in the directory from which you executed the `clone` command (in our case, `/c/Users/i103455/Repos`), which will be named `act_env2`. 

That's it!
