## part II: national park processing #######################################
##
## this file:
##      - loads, processes, & saves the state park service boundaries
##        - Method 1: loads and merges the PADUS data that was broken up by
##          Census regions.
##        - Method 2: uses the national PADUS geodatabase that has been converted
##          to a shapefile using QGIS
##      - Only one method is necessary, but the others are included for 
##        reference in conjunction with my tutorial here
##        https://liz-muehlmann.github.io/converting-gdb-files
##
## data source:
##      - Shapefiles for the state parks can be found in the PAD-US database
##        PAD-US "was originally designed to support biodiversity assessments"
##        but has expanded to "include all public and nonprofit held lands and 
##        waters." By definition, it has a lot of information. The data
##        includes polygons for National, State, Local, and Tribal land along
##        with rivers, lakes, and other public land. Due to the size of the 
##        files they need to be downloaded separately either by state or by
##        Census region. The latter has 12 downloads the former 50. I will
##        use the data based on Census regions. Both are available here:
##        https://www.sciencebase.gov/catalog/item/62225612d34ee0c6b38b6bad
##      - National level data is available, but it requires an additional 
##        step using QGIS (free) or ArcGIS (paid) to convert the file from
##        a geodatabase to a shape file. I outline the steps to convert the
##        data using QGIS here: https://liz-muehlmann.github.io/converting-gdb-files
##        National level data is available here:
##        https://www.sciencebase.gov/catalog/item/61794fc2d34ea58c3c6f9f69
##        
## next:
##      - part V: adding in shiny functionality.
##  
############################################################################

## load libraries ##########################################################
## if you haven't downloaded these packages yet, you'll need to install them
## the syntax is: install.packages("package-name"). You only need to install
## the packages once, but you'll need to load the libraries every time.

library(tidyverse)    # useful data manipulation tools
library(sf)           # read and write shapefiles
library(tigris)       # downloading shapefiles for Method 1
library(leaflet)      # map creation

## load usa data ###########################################################
usa <- read_sf("./shapefiles/shifted/usa/usa.shp")
nps <- read_sf("./shapefiles/shifted/nps/nps.shp")

## get geopackage layers ###################################################
layers <- st_layers("./shapefiles/original/state_parks_padus/PADUS3_0Geopackage.gpkg")




#############################################################################
# https://clauswilke.com/blog/2016/06/13/reading-and-combining-many-tidy-data-files-in-r/
# 
# ** also make notes on downloading the padus data for blog.
