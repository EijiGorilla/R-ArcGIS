# R-ArcGIS

This repository gives you basic instructions and tips for R and ArcGIS interactions such as R-ArcGIS Bridge'

Website:https://r-arcgis.github.io

# sf Package
Tutorial: https://www.jessesadler.com/post/gis-with-r-intro/; https://github.com/jessesadler/intro-to-r
Vignettes: https://cran.r-project.org/web/packages/sf/index.html

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
