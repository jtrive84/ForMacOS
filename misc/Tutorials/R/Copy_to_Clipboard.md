

## Copying data.frames/data.tables To and From the Clipboard
###### Author: James Triveri


### Prerequisites


If you don't have it already, install the data.table library the conventional way: Open RStudio, and from the interactive console, run:

```R
> install.packages("data.table")
```


### Setup

This is a brief article, but is nonetheless something I rely on frequently. Often times it is necessary to copy a data.frame (or data.table, henceforth data.frame will serve as a stand-in for both) to another application. Of course it's possible to export the data.frame to a .csv or .xlsx file,  then open the file and copy the exported data for use as needed, but there is an easier way. Using R's built-in `write.table`, instead of providing a file name, specify `"clipboard"`, and the table will be copied. With the table contents copied to the clipboard, it can be pasted into any other application. For example, here's how to copy the *trees* sample dataset to the clipboard using `write.table`:

```R
> data(trees)
> DF = trees
> write.table(DF, "clipboard", sep="\t", row.names=FALSE)
```

After the commands have been executed, the data can be transferred to another application by selecting `CTRL + v`. Here's what the data looks like in Notepad:


```text
"Girth"	"Height"	"Volume"
8.3	70	10.3
8.6	65	10.3
8.8	63	10.2
10.5	72	16.4
10.7	81	18.8
10.8	83	19.7
11	66	15.6
11	75	18.2
11.1	80	22.6
11.2	75	19.9
11.3	79	24.2
11.4	76	21
11.4	76	21.4
11.7	69	21.3
12	75	19.1
12.9	74	22.2
12.9	85	33.8
13.3	86	27.4
13.7	71	25.7
13.8	64	24.9
14	78	34.5
14.2	80	31.7
14.5	74	36.3
16	72	38.3
16.3	77	42.6
17.3	81	55.4
17.5	82	55.7
17.9	80	58.3
18	80	51.5
18	80	51
20.6	87	77
```

In the call to `write.table`, I specified a tab delimiter (`"\t"`). For comma-delimited data, set `sep=","`:

```R
> write.table(DF, "clipboard", sep=",", row.names=FALSE)
```

Which would be rendered as:

```text
"Girth","Height","Volume"
8.3,70,10.3
8.6,65,10.3
8.8,63,10.2
10.5,72,16.4
10.7,81,18.8
10.8,83,19.7
11,66,15.6
11,75,18.2
11.1,80,22.6
11.2,75,19.9
11.3,79,24.2
11.4,76,21
11.4,76,21.4
11.7,69,21.3
12,75,19.1
12.9,74,22.2
12.9,85,33.8
13.3,86,27.4
13.7,71,25.7
13.8,64,24.9
14,78,34.5
14.2,80,31.7
14.5,74,36.3
16,72,38.3
16.3,77,42.6
17.3,81,55.4
17.5,82,55.7
17.9,80,58.3
18,80,51.5
18,80,51
20.6,87,77
```

### Reading Data From the Clipboard into R

We can go the other way as well. Imagine a dataset copied from an Excel worksheet that we need quickly load into R to perform some analysis. We can encapsulate the commands within a function for reusability. The function,`dfFromClipboard`, leverages the `fread` function, which comes from the data.table library:


```R
# Function to load data from the clipboard into an R data.table.
library("data.table")

dfFromClipboard = function(...) {
    content = tempfile()
    writeLines(readLines("clipboard"), content)
    fread(content, ...)
}
```

`dfFromClipboard` creates a temporary file, write the contents of the clipboard into the temporary file, then loads the content into R via `fread`. Notice  `dfFromClipboard`'s definition includes `...`, indicating additional keyword arguments can be passed which will be forwarded to `fread`. For example, to prevent strings from being treated as categorical factor variables, it is often useful to initialize data.table's with `stringsAsFactors=FALSE`. I'll demonstrate with two examples.

First, calling `dfFromClipboard` with no arguments: Assume a table has just been copied from an Excel worksheet that needs to be read into R:

```
> DF = dfFromClipboard()
> class(DF)
[1] "data.table" "data.frame"
```

Second, loading the dataset from Excel into R as in the previous example, this time specifying `stringsAsFactors=FALSE`:

```R
> DF = dfFromClipboard(stringsAsFactors=FALSE)
> class(DF)
[1] "data.table" "data.frame"
```

That's it. To find out other parameters accepted by `fread`, refer to the help page, which can be accessed from the RStudio console by running:

```R
> ?fread
```
