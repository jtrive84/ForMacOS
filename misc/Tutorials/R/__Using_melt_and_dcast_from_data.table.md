


```R
library("data.table")
library("ChainLadder")
library("MASS")




data(Insurance)
DF = setDT(Insurance)
names(DF) = toupper(names(DF))

fwrite(DF, "F:\\actu-s\\jtrive\\Datasets\\MASS_Insurance_Claims.csv")


DF = fread("F:\\actu-s\\jtrive\\Datasets\\freMTPL2freq.csv")
names(DF) = toupper(names(DF))

fwrite(DF, "F:\\actu-s\\jtrive\\Datasets\\FREMTPL.csv")



# Convert ChainLadder RAA triangle data into incremental tabular format.
tri = RAA
triDF0 = as.data.table(tri, keep.rownames="origin")
triDF = melt(triDF0, variable.name="dev", value.name="value1", id.vars="origin", variable.factor=FALSE, na.rm=TRUE)
triDF[,`:=`(
    origin=as.numeric(origin), dev=as.numeric(dev), value1=as.numeric(value1)
    )]

setorderv(triDF, c("origin", "dev"), c(1, 1))

triDF[,value2:=shift(value1, 1), by="origin"]

triDF[,value:=ifelse(is.na(value2), value1, value1-value2)]

triDF = triDF[,.(origin, dev, value)]
names(triDF) = toupper(names(triDF))

fwrite(triDF, "F:\\actu-s\\jtrive\\Datasets\\SAMPLE_RAA_TABULAR.csv")
```

# Coerce lossDF to large count triangle =>
rawTri = dcast(
    data=lossDF,formula=LOSS_YR~DEV_MONTHS,fun.aggregate=sum, 
    value.var=lossMetric,fill=NA_real_
)