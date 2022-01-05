

## Querying SQL Server Database Tables from R
###### Author: James Triveri

### Prerequisites

If you don't have them already, install the **data.table** and **odbc** libraries the conventional way: Open RStudio, and from the interactive console, run:

```R
> install.packages(c("data.table", "odbc"))
```

### Setup

Much of our work requires querying/updating data that resides in SQL Server database tables. In what follows, we demonstrate how to query and upload datasets into SQL Server from R.


### Creating the Connection

Windows typically comes preinstalled with a number of different SQL Server drivers. To find the drivers available on your system, open the Windows run dialouge (CRTL + R), and type `odbcad32`. In the rendered GUI, select *Drivers*, and look for SQL Server-related entries. 
For the purpose of this article we'll use the most generic driver, `"SQL Server"`, which should work independent of version number. 

In what follows, we create a connection to the User_ActuarialPilot database, and query the first 1000 records from one of our sample tables identified as  `SAMPLE_FREMTPL`


```R
# Demonstration of SQL Server database connection creation.
library("data.table")
library("DBI")
library("odbc")

# Connection details.
DRIVER   = "SQL Server"
SERVER   = "dnsdbentrep01p"
DATABASE = "User_ActuarialPilot"

# Create connection string to pass into connection initializer.
connStr = paste0(
    "driver={", DRIVER_, "};server=", SERVER_, ";database=", DATABASE_, 
    ";trusted_connection=yes;"
    )

# Initialize connection.
dbConn = dbConnect(odbc::odbc(), .connection_string=connStr)
```

Instead of remembering how to create this connection string each time, we can encapsulate the logic within a function, which we identify as `getDBConn`:


```
getDBConn = function(driver, server, dbname) {
    # ------------------------------------------------------------------
    # Create connection to SQL Server database. Requires odbc library. |
    #                                                                  |
    # driver: character - SQL Server driver specification.             |
    # server: character - Server name which hosts target database.     |
    # dbname: character - Database name.                               |  
    #                                                                  |    
    # Returns: DB connection object.                                   |  
    # ------------------------------------------------------------------
    connStr = paste0(
        "driver={", driver, "};server=", server, ";database=", 
        dbname, ";trusted_connection=yes;"
        )
    dbConn = dbConnect(
        odbc::odbc(), .connection_string=connStr
        )
    return(dbConn)
}
```

Then, to invoke `getDBConn`, simply pass the desired driver, server and dbname as arguments to the function as follows:

```R
> dbConn = getDBConn(driver="SQL Server", server="dnsdbentrep01p", dbname="User_ActuarialPilot")
```



### Retrieving Data from SQL Server Database

Retrieving data from SQL Server is straightforward, and mirrors the API of many other R DBI-compliant database packages, such as SQLite, ROracle, etc. In the following example, we retrieve data from the **SAMPLE_MASS_CLAIMS** table in **User_ActuarialPilot**. We'll leverage the `getDBConn` function we created earlier to establish the connection (To load `getDBConn` into the current R session, highlight the function declaration then from RStudio, select **Run** or press Ctrl+Enter):

```R
# SQL Server data retrieval example. 
library("data.table")
library("DBI")
library("odbc")

# Connection details.
DRIVER   = "SQL Server"
SERVER   = "dnsdbentrep01p"
DATABASE = "User_ActuarialPilot"

# Initialize connection.
dbConn = getDBConn(driver=DRIVER, server=SERVER, dbname=DATABASE)

# Specify query string then call dbGetQuery.
SQLStr = "SELECT * FROM SAMPLE_MASS_CLAIMS"
DF = setDT(dbGetQuery(dbConn, SQLStr))
```

Note that the result returned by `dbGetQuery` is a data.frame. We wrap the result in `setDT`, which transforms the object to a data.table. Viewing the first few records yields:

```
   DISTRICT  GROUP   AGE HOLDERS CLAIMS
1:        1    <1l   <25     197     38
2:        1    <1l 25-29     264     35
3:        1    <1l 30-35     246     20
4:        1    <1l   >35    1680    156
5:        1 1-1.5l   <25     284     63
6:        1 1-1.5l 25-29     536     84
```



### Exporting Data from R to SQL Server

The primary function that handles table uploads is `dbWriteTable`. Assume we want to append a timestamp to the table retrieved in the previous example, and then push it back to the database. We'd also like to check the return code to determine whether or not the export was successful. This can be accomplished as follows:

```R
# Starting point is DF from previous example. dbConn is same as before. 
TABLENAME = "SAMPLE_MASS_CLAIMS"

DF[,TIMESTAMP:=format(Sys.time(), "%Y%m%d %H:%M:%S")]

returnCode = dbWriteTable(conn=dbconn, TABLENAME, DF, overwrite=TRUE)

if (returnCode) {
    message("[", Sys.time(), "] Table successfully exported.")
} else {
    message("[", Sys.time(), "] An error occurred exporting ", TABLENAME, ".")
}
```

In the call to `dbWriteTable`, we specified `overwrite=TRUE`. If a table with the same name exists in the target database, it will be overwritten, so be careful.

In a future article, we'll cover more advanced topics such as iterative data retrieval and utilizing `dbExecute`. 
