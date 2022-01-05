
## Writing Queried Data to Compressed Format
###### Author: James Triveri

### References 

* Pandas documentation: https://pandas.pydata.org/


### Prerequisites

This tutorial requires the Pandas and sqlalchemy libraries. If you access Python using Anaconda, you're all set (Pandas and sqlalchemy are distributed with Anaconda). Otherwise, open the command prompt (press Windows key + R. type "cmd" (no quotes) followed by ENTER) and type:

```cmd
C:\> python -m pip install pandas sqlalchemy
```

### Setup

In an earlier post, I demonstrated how to interact with SQL Server databases from Pandas. In this article, I'll demonstrate how data can be queried iteratively and written directly to a compressed file format. This is especially useful when working with very large datasets, or when the data in question exceeds available system resources. 

Another reason to save datasets in compressed format is that Pandas can read compressed files just as easily as csvs. 
Once read into memory, the data will expand to the full uncompressed size, but by writing data to compressed format we reduce our overall storage footprint, which is always a good thing. 

As in the earlier Pandas-SQL Server post, we'll retrieve the French Motor Third-Party Liability Claims sample dataset found in *SAMPLE_FREMTPL* from the *User_ActuarialPilot* database in 100,000 record blocks, writing each block to a compressed file named `"COMPRESSED_FREMTPL.csv.gz"`. By retrieving the dataset iteratively, no more than 100,000 records will be in memory at any given point, making this a particularly memory efficient approach to data export:


```python
"""
Exporting query results to compressed file format. 
"""
import gzip
import time
import pandas as pd
import sqlalchemy

DRIVER = "SQL Server"
SERVER = "dnsdbentrep01p"
DATABASE = "User_ActuarialPilot"
CHUNKSIZE = 100000
DATA_PATH = "COMPRESSED_FREMTPL.csv.gz"

# Create connection uri.
conn_uri = "mssql+pyodbc://{}/{}?driver={}".format(
    SERVER, DATABASE, DRIVER.replace(" ", "+")
    )

# Initialize connection.
conn =  sqlalchemy.create_engine(conn_uri)
SQL = "SELECT * FROM SAMPLE_FREMTPL"
dfiter = pd.read_sql(SQL, con=conn, chunksize=CHUNKSIZE)

t_i = time.time()
trkr, nbrrecs = 0, 0
with gzip.open(DATA_PATH, "wb") as fgz:
    for df in dfiter:
        fgz.write(df.to_csv(header=nbrrecs==0, index=False, mode="a").encode("utf-8"))
        nbrrecs+=df.shape[0]
        print("Retrieved records {}-{}".format((trkr * CHUNKSIZE) + 1, nbrrecs))
        trkr+=1

t_tot = time.time() - t_i
retrieval_rate = nbrrecs / t_tot

print(
    "Retrieved {} records in {:.0f} seconds ({:.0f} recs/sec.).".format(
        nbrrecs, t_tot, retrieval_rate
        )
    )       
```

The compressed file, `"COMPRESSED_FREMTPL.csv.gz"` is ~6.6MB, whereas the original, uncompressed dataset is ~36MB. 

To read the compressed file back into Pandas, use the `read_csv` function specifying the compression type (in this example we used "gzip" - other options are "zip", "bz2" or "xz". 


```python
In [1]: df = pd.read_csv(DATA_PATH, compression="gzip")
In [2]: df.shape
Out[2]: (678013, 12)
```
