## Manipulating PDFs with PyPDF2
###### Author: James Triveri


### Prerequisites

This tutorial requires the PyPDF2 library. If you access Python using Anaconda, PyPDF2 can be installed with conda by first adding the conda-forge channel as follows:


```
$ conda config --add channels conda-forge
$ conda install pypdf2
```

If instead you work from a stand-alone Python environment, open the command prompt (press Windows key + R. type "cmd" (no quotes) followed by ENTER) and type:

```cmd
C:\> python -m pip install pypdf2
```


### Setup

PyPDF2 is a PDF toolkit which simplifies working with PDF documents in Python. Although the library exposes a good deal of useful functionality, this post focuses on how to merge two or more PDFs into a single document using the `PdfFileMerger` class.

Assume a directory contains several PDFs documents which are to be compiled into a single document. With PyPDF2, it's as simple as instantiating and instance of the `PdfFileMerger` class and calling its `append` method:


```python
"""
Demonstration of PDF merge using PyPDF2.
"""
import os
import os.path
from PyPDF2 import PdfFileMerger, PdfFileReader

# Directory containing files to merge.
pdf_dir = "C:/PDFs"

# Generate list of files for merging.
pdf_files = [os.path.join(pdf_dir, ii) for ii in os.listdir(pdf_dir) if ii.endswith(".pdf")]

try:
    # Instantiate PdfFileMerger instance.
    merger = PdfFileMerger()
    for i in enumerate(pdf_files):
        print("Merging {} ({} of {})".format(ii[1], ii[0]+1, len(pdf_files)))
        merger.append(PdfFileReader(open(ii[1], 'rb')))

    # Write merged PDF to file.
    merger.write("C:/PDFs/merged_files.pdf")
finally:
    merger.close()
```

PyPDF2's interface is very intuitive, and in only a few lines of Python you can create a custom PDF document merging tool that merges an arbitrary number of documents.
