## A PDF Harvester in Less Than 25 Lines of Python
###### Author: James Triveri


### Prerequisites

This tutorial requires the requests library. If you access Python using Anaconda, you're all set (requests is distributed along with Anaconda). Otherwise, open the command prompt (press Windows key + R. type "cmd" (no quotes) followed by ENTER) and type:

```sh
C:\> python -m pip install requests
```

### Setup

The goal of this post is to develop a utility that facilitates the following:

1. Retrieve HTML from the target webpage.
2. Parse the HTML, extracting all embedded PDF links.
3. Download each PDF and save the documents locally.


Plenty of 3rd-party libraries can query and return all the links to PDF documents webpage's links in a single function call. However, the purpose of this post is to highlight the fact that by combining elements of the Python Standard Library with the Requests package, much can be accomplished.

#### Step 1: Acquire HTML

The Wikipedia page we'll use for the examples that follow will be Wikipedia's Markov Chain Monte Carlo article here:

```
https://en.wikipedia.org/wiki/Markov_chain_Monte_Carlo
```

If following along, feel free to substitute any other webpage with references to PDF documents. 


The library that facilitates communication between Python and the target webpage is requests. Retrieving the HTML associated with a webpage is as simple as:

```python
requests.get(URL).text  
```

Where `URL` is a string representing the target URL. `requests.get` returns an object, and by including the text suffix, we're requesting the the webpage's content be returned as plain text to allow for parsing with regular expressions in Step 2. 

The logic comprising step 1. is provided below:


```python
"""
Step 1: Retrieve HTML associated with target webpage. 
"""
import requests

url = "https://en.wikipedia.org/wiki/Markov_chain_Monte_Carlo"

html = requests.get(url).text
```

#### Step 2: Extract PDF links

The HTML has been obtained. We now need to highlight and extract references to all PDF references. For this step, I'll make use of regular expressions, available in the builtin `re` library.

A cursory review of the HTML from webpages having embedded PDF references revealed the following:

* Valid PDF URLs will in almost always be embedded within an `href` tag.
* Valid PDF URLs will in all cases be preceded by http or https.
* Valid PDF URLs will in all cases be enclosed by a trailing `>`.
* Valid PDF URLs will not contain whitespace.

After a bit of trial and error, the following regular expression was found to have "good-enough" performance for our test cases:

```python
"(?=href=).*(https?://\S+.pdf).*?>"
```

[Pythex](https://pythex.org/) is a great resource for practicing and testing regular expression patterns. The user supplies a target body of text and a regular expression pattern, and the app provides feedback on the quality of the match. I find myself using it on a regular basis.

He's what the html associated with the sample URL looks like around the area of arbitrary link to a PDF:


```html
<li id="cite_note-Gelman_and_Rubin,_1992-20"><span class="mw-cite-backlink">^ <a href="#cite_ref-Gelman_and_Rubin,
_1992_20-0"><sup><i><b>a</b></i></sup></a> <a href="#cite_ref-Gelman_and_Rubin,_1992_20-1"><sup><i><b>b</b></i></sup></
a></span> <span class="reference-text"><cite id="CITEREFGelmanRubin1992" class="citation journal cs1">Gelman, A.; Rubin,
D.B. (1992). <a rel="nofollow" class="external text" href="http://www.stat.duke.edu/~scs/Courses/Stat376/Papers/
ConvergeDiagnostics/GelmanRubinStatSci1992.pdf">"Inference from iterative simulation using multiple sequences (with
discussion)"</a> <span class="cs1-format">(PDF)</span>. <i>Statistical Science</i>. <b>7</b> (4): 457–511. <a href="/
wiki/Bibcode_(identifier)" class="mw-redirect" title="Bibcode (identifier)">Bibcode</a>:<a rel="nofollow"
class="external text" href="https://ui.adsabs.harvard.edu/abs/1992StaSc...7..457G">1992StaSc...7..457G</a>
```

It looks like a mess, but our regular expression pattern will be able to cut through the noise, extracting only the relevant PDF links. The code to do so is found in step 2., given below:


```python
"""
Step 2: Extract PDF URLs from html.
"""
import re

pdf_urls = re.findall(r"(?=href=).*(https?://\S+.pdf).*?>", html)
```

The regular expression is preceded with an `r` when passed to `re.findall`. This instructs the interpreter to treat what follows as a raw string and to ignore escape sequences.

`re.findall` returns a list of matches extracted from the source text. In our case, it returns a list of links of all PDF documents found in the html.


#### Step 3: Download PDFs and save to file Locally

For our last step we need to retrieve the documents associated with our collection of links and write them to file locally. We introduce another module from the Python Standard Library, `os.path`, which facilitates the partitioning of absolute filepaths into components in order to retain filenames when saving documents to disk.

Consider the following well-formed URL:

```sh
"http://Statistical_Modeling/Fall_2017/Lectures/Lecture11.pdf"
```

To capture *Lecture11.pdf*, we pass the absolute URL to `os.path.split`, which returns a tuple of everything preceeding the filename as the first element, along with the filename and extension as the second element:

```python
In [1]: import os.path
In [2]: url = "http://Statistical_Modeling/Fall_2017/Lectures/Lecture11.pdf"
In [3]: os.path.split(url)
Out[3]: ('http://Statistical_Modeling/Fall_2017/Lectures', 'Lecture11.pdf')
```

Filenames and extensions can be referenced by calling `os.path.split(url)`, which we can then use to preserve the name of each document when saving locally. 

This code for step 3 differs from the initial html retrieval code in that we need to request the content be returned as bytes, not text. By calling `requests.get(url).content`, we gain access to the raw bytes that comprise the PDF, which are then saved to file locally.  Here's the logic for the third and final step:


```python
"""
Step 3: Download documents for all links in pdf_urls.
"""

export_dir = "/"

for pdf_url in pdf_urls:
    # Get filename from url for naming file locally.
    pdf_name = os.path.split(pdf_url)[1]
    pdf_path = os.path.join(export_dir, pdf_name)

    # Get retrieved content as bytes.
    rr = requests.get(pdf_url).content
    try:
        with open(pdf_path, "wb") as ff: 
            ff.write(rr)
    except:
        print("Unable to download `{}`.".format(pdf_url))
        continue
```

Notice that we surround `with open(pdfname, "wb")...` in a `try-except` block: This handles situations that would prevent us from downloading a PDF, such as empty redirects or invalid or malformed links.

Next the full script of step 1, 2 and 3 combined is presented. Including comments and blanks lines, there are **23** lines of code:

```python
"""
A PDF Harvester in Less Than 25 Lines of Python.
Author: James D. Triveri
"""
import os
import os.path
import re
import requests

url = "https://en.wikipedia.org/wiki/Markov_chain_Monte_Carlo"
html = requests.get(url).text
pdf_urls = re.findall(r"(?=href=).*(https?://\S+.pdf).*?>", html)
export_dir = "/"

for pdf_url in pdf_urls:
    # Get filename from url for naming file locally.
    pdf_name = os.path.split(pdf_url)[1]
    pdf_path = os.path.join(export_dir, pdf_name)

    # Get retrieved content as bytes.
    rr = requests.get(pdf_url).content
    try:
        with open(pdf_path, "wb") as ff: 
            ff.write(rr)
    except:
        print("Unable to download `{}`.".format(pdf_url))
        continue
```

Finally, the logic can be encapsulated within a function that can be called and reused as needed:


```python
"""
Functional implementation of PDF harvester.
"""
import os
import os.path
import re
import requests

def pdf_harvester(url, loc=None):
    """
    Retrieve url's html and extract references to PDFs. Download PDFs, 
    writing to loc. If loc is None, save to current working directory.
    """
    print("Harvesting PDFs from  `{}`".format(url))
    os.chdir(os.getcwd() if loc is None else loc)

    html = requests.get(url, proxies=proxies).text
    pdf_urls = re.findall(r"(?=href=).*(https?://\S+.pdf).*?>", html)
    for pdf_url in pdf_urls:
        # Get filename from url for naming file locally.
        pdf_name = os.path.split(pdf_url)[1]
        pdf_path = os.path.join(export_dir, pdf_name)

        # Get retrieved content as bytes.
        rr = requests.get(pdf_url).content
        try:
            with open(pdf_path, "wb") as ff: 
                ff.write(rr)
        except:
            print("Unable to download `{}`.".format(pdf_url))
            continue

    print("\nProcessing complete!")
```

`pdf_harvester` could then be called as follows:


```python
In [4]: pdf_harvester(url, loc="/")
Out[4]: Harvesting PDFs from  https://...
```
