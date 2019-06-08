# R-GIS

This repository gives you basic instructions and tips for R and GIS interactions

# R-ArcGIS Bridge
Website:https://r-arcgis.github.io

# sf Package
*Tutorial: https://www.jessesadler.com/post/gis-with-r-intro/; https://github.com/jessesadler/intro-to-r

*Vignettes (Lots of examples): https://cran.r-project.org/web/packages/sf/index.html

# R Spatial Files
1. Open Multiple Shapefiles
------------------
    library(sf)
    wd=setwd("C:/Users/oc3512/Documents/ArcGIS/Projects/Python_practice/Lesson1")
    listFiles=list.files(wd,pattern=".shp")
    for (shp in listFiles){
      if(length(grep(".xml",basename(shp)))==1){
       print("not shapefile")
       } else {
        assign(gsub(".shp","",shp), st_read(shp)) # use gsub to remove ".shp" character to assign shapefile names
       }
     }
------------------

2. Open and Write features from/to File Geodatabase in ArcGIS
------------------
    library(sf)
    library(rgdal)
    library(dplyr)
    
    ## read vector in file geodatabase
    a=choose.dir()
fgdb="C:\\Users\\oc3512\\Documents\\ArcGIS\\Projects\\MMSP\\MMSP_utm.gdb"
listLayers=ogrListLayers(fgdb)

la=st_read(dsn=fgdb,layer = listLayers[6])

# read a table to merge
b=file.choose()
table=read.csv(b)

# Merge
test=la %>% left_join(table,by="LotNum")

# Write to file geodatabase
library(arcgisbinding)
arc.check_product()

arc.write("C:/Users/oc3512/Documents/ArcGIS/Projects/MMSP/MMSP_utm.gdb/test",data=test,overwrite=TRUE)


# R and PostgreSQL
1. Connect PostgreSQL and Load Spatial Data
------------------
    library(sf)
    library(RPostgreSQL)
       
    ### Connct PostgreSQL
    pg = dbDriver("PostgreSQL")
    con = dbConnect(pg, user="postgres", password="timberland",host="localhost", port=5432, dbname="postgres")
    
    ### List tables
    dbListTables(con)
    
    ### Read Table
    x = st_read(con, "delete", query = NULL)
    
    ### Write Table
    dbWriteTable(con, "delete_11", x, row.names=FALSE, overwrite=TRUE)
------------------
