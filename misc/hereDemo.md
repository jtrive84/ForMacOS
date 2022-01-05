In what follows, we'll retrieve the `LAST_DDL_TIME` attribute from the
MV_R_LL_INC_8 table in the MIS_DM_RPT schema on MERWHP. We set 
`DATABASE`, `SCHEMA` and `TABLENAME` to the target settings at the top of the 
script under *Configuration*:

```sh
#!/bin/bash

# Configuration ===============================================================]
DATABASE=MERWHP
SCHEMA=MIS_DM_RPT
USERNAME=cac9159
PASSWORD=pppwwwddd
TABLENAME=MV_R_LL_INC_8
# =============================================================================]

### Create Oracle connection string.
CONNECT_STR="${USERNAME}/${PASSWORD}@${DATABASE}"

### Retrieve TABLENAME's LAST_DDL_TIME and bind it to `LATEST`.
LATEST=$("${SQLPLUS_EXE}" -S "${CONNECT_STR}" << EOF
SET HEADING OFF
SET PAGESIZE 0 EMBEDDED ON
SELECT LAST_DDL_TIME FROM DBA_OBJECTS WHERE OWNER=${SCHEMA} AND OBJECT_NAME=${TABLENAME};
EXIT;
EOF
)
```

We used `EOF` as the delimiting identifier. It specifies the start and end of 
the here document. It can be anything, but `EOF` is frequently used. The way
it works is we pass the sqlplus command line specification prior to `<<`, and 
everything after `<<` gets passed into the initial command spec as standard 
input for processing. This serves the same purpose as a file given on the 
command line. For example, if we had a file named `query.sql` that contained:

```sh
SET HEADING OFF
SET PAGESIZE 0 EMBEDDED ON
SELECT LAST_DDL_TIME FROM DBA_OBJECTS WHERE OWNER=MIS_DM_RPT AND OBJECT_NAME=MV_R_LL_INC_8;
EXIT;
```

Then from the shell, we would execute `query.sql` directly as follows:

```sh
$ cd /folder/containing_query_file/
$ sqlplus -L -S MIS_DM_RPT@MERWHP/pppwwwddd @query.sql
```

But when implemented using the here document approach, we can substitute 
variables into any part of the connection string or query, then process the 
results with any of available Linux command line utilities.
<br>
Notice that none of the lines comprising the here document commands were indented.
This is intentional. Whitespace is significant within this context, which makes
more difficult to identify the actual query at first glance. It is possible to 
indent lines using a single tab character (unfortunately it cannot be two or 
four space characters that render like a tab character). If you intend to go 
this route, you need to change `<<` to `<<-`. In our example, the result would
look like:

```sh
### Retrieve TABLENAME's LAST_DDL_TIME and bind it to `LATEST`.
LATEST=$("${SQLPLUS_EXE}" -S "${CONNECT_STR}" << EOF
    SET HEADING OFF
    SET PAGESIZE 0 EMBEDDED ON
    SELECT LAST_DDL_TIME FROM DBA_OBJECTS WHERE OWNER=${SCHEMA} AND OBJECT_NAME=${TABLENAME};
    EXIT;
    EOF
)
```

When the script executes, then all tab characters are omitted from the start 
of each line, resulting in an identical result as in the original implementation. 
<br>
Once the LAST_DDL_TIME is obtained, we can determine the action to take based 
on logic constructs following the here document in the same script. This is
a very powerful paradigm which you will see time and time again in more advanced
shell scripts. 

