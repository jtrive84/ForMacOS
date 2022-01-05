

## Identify Newest File in a Directory
###### Author: James Triveri

### Setup


Imagine you have a directory `Inputs/` that contains the following files:


```text
Inputs ---|
       - 20200812_loss-IncurredLoss.csv
       - 20200824_loss-IncurredLoss.csv
       - 20200918_loss-IncurredLoss.csv
       - 20200922_loss-IncurredLoss.csv
       - 20201202_loss-IncurredLoss.csv
```

Also assume there is a process that uses the most recently added file to the `Inputs` directory as input to another program. The logic currently used to identify the most recently added file consists of ordering the files by name and extracting the last element, something along the lines of:

```R
> allFiles = list.files("Inputs", full.names=TRUE)
> sort(allFiles)[length(allFiles)]
[1] "Inputs/20201202_loss-IncurredLoss.csv"
```

So far so good. However, imagine the very likely scenario in which someone joins your team, and they become responsible for creating the files that get saved to the *Inputs/* directory. Not realizing the importance of using a consistent naming convention, the individual adds an updated version of the file, so directory now contains:


```text
Inputs ---|
       - 20200812_loss-IncurredLoss.csv
       - 20200824_loss-IncurredLoss.csv
       - 20200918_loss-IncurredLoss.csv
       - 20200922_loss-IncurredLoss.csv
       - 20201202_loss-IncurredLoss.csv
       - 2020-12-23_loss-IncurredLoss.csv
```

Running the original code to identify the newest file will not work, since it assumes a consistent file naming convention. The result will return the same file as before, ignoring the actual newest file:

```R
> allFiles = list.files("Inputs", full.names=TRUE)
> allFiles
[1] "Inputs/2020-12-23_loss-IncurredLoss.csv"
[2] "Inputs/20200812_loss-IncurredLoss.csv"  
[3] "Inputs/20200824_loss-IncurredLoss.csv"  
[4] "Inputs/20200918_loss-IncurredLoss.csv"  
[5] "Inputs/20200922_loss-IncurredLoss.csv"  
[6] "Inputs/20201202_loss-IncurredLoss.csv"

> sort(allFiles)[length(allFiles)]
[1] "Inputs/20201202_loss-IncurredLoss.csv"
```

We can overcome this limitation by referencing file attributes instead of filenames. We can pass a vector of files paths into the `file.info` function, then refer to each file's `mtime` attribute. Here's a sample of the output produced by passing `allFiles` into `file.info`:

```R
> file.info(allFiles)
                                        size isdir mode               mtime
Inputs/2020-12-23_loss-IncurredLoss.csv 3307 FALSE  666 2020-12-23 15:45:34
Inputs/20200812_loss-IncurredLoss.csv   3083 FALSE  666 2020-08-12 12:58:24
Inputs/20200824_loss-IncurredLoss.csv   3306 FALSE  666 2020-08-24 13:00:01
Inputs/20200918_loss-IncurredLoss.csv   3306 FALSE  666 2020-09-18 14:47:47
Inputs/20200922_loss-IncurredLoss.csv   3335 FALSE  666 2020-09-22 14:15:58
Inputs/20201202_loss-IncurredLoss.csv   3307 FALSE  666 2020-12-02 15:08:35
```

I've limited the output to only show the `mtime` attribute, but `file.info` returns 3 time-based attributes: 

* `mtime`: Modification time, when the file was last modified. When you change the contents of a file, its mtime changes.
* `ctime`: Change time, when the file's property changes. It will always be changed when the mtime changes, but also when you change the file's permissions, name or location.
* `atime`: Access time, updated when the file's contents are read by an application such as Excel.

For our purposes, using `mtime` makes the most sense, since the creation of a file is considered a modification which updates mtime. `file.info` returns a data.frame, so we can use standard data.frame indexing techniques to identify the file with the latest `mtime` attribute:

```R
> allFiles = list.files("Inputs", full.names=TRUE)
> DF = file.info(allFiles)
> newestFile = rownames(DF)[which(DF$mtime==max(DF$mtime))]
> newestFile
[1] "Inputs/2020-12-23_loss-IncurredLoss.csv"
```

Which is the expected result. 

It's important to clearly document process rules and conventions to all stakeholders involved in running, developing or maintaining a process or runtime. However, relying on users or contributors to do the "right thing" is almost always a bad idea. If it is possible to replace code or logic that relies on consistent user behavior with code that takes user decisions out of the loop entirely, it is almost always a good idea. Be proactive in protecting your programs from the whims of end users!
