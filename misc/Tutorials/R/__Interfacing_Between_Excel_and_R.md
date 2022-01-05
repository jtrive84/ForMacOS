


### Prerequisites

If you don't have it already, install the data.table library the conventional way: Open RStudio, and from the interactive console, run:

```R
> install.packages("data.table")
```



jopDataList = split(dataDF, by="parent_ag")
wbTmpl = openxlsx::loadWorkbook(file=JOP_TMPL_PATH)
hdrColStyle = openxlsx::createStyle(
    halign="center", valign="center", border="TopBottomLeftRight",
    borderColour="#000000", textDecoration="bold", borderStyle="thin",
    fontColour="red"
)

tmplNames = openxlsx::getSheetNames(
    JOP_TMPL_PATH
)


 if ("Data" %in% wbNames) {
        openxlsx::removeWorksheet(wb, sheet="Data")
    }
    
    openxlsx::addWorksheet(
        wb, sheetName="Data", gridLines=TRUE
        )
    
    openxlsx::writeData(
        wb, "Data", DF, rowNames=FALSE, headerStyle=hdrColStyle,
        startRow=1, startCol=1
        )
		
		
 if (!file.exists(tracePath)) {
        wb = openxlsx::createWorkbook()
        sheetNames = c()
    } else {
        wb = loadWorkbook(file=tracePath)
        sheetNames = openxlsx::getSheetNames(tracePath)
    }
    
    if (view=="mid") {
        
        if ("triRaw" %in% sheetNames) {
            openxlsx::removeWorksheet(wb, "triRaw") 
        }
        openxlsx::addWorksheet(wb, "triRaw")
        openxlsx::writeData(wb, "triRaw", triFull, rowNames=FALSE)
        
        if ("triDF" %in% sheetNames) {
            openxlsx::removeWorksheet(wb, "triDF") 
        }
        openxlsx::addWorksheet(wb, "triDF")
        openxlsx::writeData(wb, "triDF", triDF, rowNames=FALSE)
        
        if ("premDF" %in% sheetNames) {
            openxlsx::removeWorksheet(wb, "premDF") 
        }
        openxlsx::addWorksheet(wb, "premDF")
        openxlsx::writeData(wb, "premDF", premDF, rowNames=FALSE)
    }
    
    if (exists("seedDF")) {
        if (paste0("seedDF-", view) %in% sheetNames) {
            openxlsx::removeWorksheet(wb, paste0("seedDF-", view)) 
        }
        openxlsx::addWorksheet(wb, paste0("seedDF-", view))
        openxlsx::writeData(
            wb,  paste0("seedDF-", view), seedDF, rowNames=FALSE
            )
    }
    
    if (paste0("ldfDF-", view) %in% sheetNames) {
        openxlsx::removeWorksheet(wb, paste0("ldfDF-", view)) 
    }
    openxlsx::addWorksheet(wb, paste0("ldfDF-", view))
    openxlsx::writeData(
        wb, paste0("ldfDF-", view), ldfDF, rowNames=FALSE
        )
    
    if (paste0("indDF-", view) %in% sheetNames) {
        openxlsx::removeWorksheet(wb, paste0("indDF-", view)) 
    }
    openxlsx::addWorksheet(wb, paste0("indDF-", view))
    openxlsx::writeData(
        wb, paste0("indDF-", view), indDF, rowNames=FALSE
        )
    
    openxlsx::saveWorkbook(wb, file=tracePath, overwrite=TRUE)
    