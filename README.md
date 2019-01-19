# R-ArcGIS

This repository gives you basic instructions and tips to apply R-ArcGIS Bridge'

Website:https://r-arcgis.github.io

# sf Package
Tutorial: https://www.jessesadler.com/post/gis-with-r-intro/; https://github.com/jessesadler/intro-to-r

# Open Multiple Spatial Files
------------------
wd=setwd("C:/Users/oc3512/Documents/ArcGIS/Projects/Python_practice/Lesson1")
listFiles=list.files(wd,pattern=".shp")

for (shp in listFiles){
  if(length(grep(".xml",basename(shp)))==1){
    print("not shapefile")
  } else {
    assign(shp, readOGR(shp))
  }
}
------------------
