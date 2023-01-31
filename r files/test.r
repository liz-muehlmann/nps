library(tidyverse)          # useful data manipulation tools
library(sf)                 # read and write shapefiles
library(operator.tools)     # %!in% function
library(tigris)             # used to shift Alaska & Hawaii
library(leaflet)            # map making
library(raster)
## load the shapefile used for the base map ###############################
## this file was created in r files part I
states <- read_sf("./shapefiles/shifted/usa/usa.shp")

## territories ############################################################
## the nps shapefile includes the park boundaries for the 50 states and the
## associated territories. I only want the 50 states so I create a variable 
## that lists the postal abbreviations for the associated territories. We'll
## use the %!in% function included in operator.tools() to filter these areas
## out from the nps data set.

territories <- c("AS", "GU", "MP", "PR", "VI")

## national parks #########################################################
## the NPS data set has 21 columns. I only want the state, area type, area,
## and the geometry. The geometry column includes the coordinates necessary
## to create the map polygon. There are 23 types of park which I wanted
## to condense in the first mutate() call. In the second mutate call, I create 
## and fill in a variable that designates whether I've been to the park. You 
## will need to change these lines (or delete them) based on whether you've 
## visited any national parks.

nps2 <- st_read("./shapefiles/original/nps/NPS_-_Land_Resources_Division_Boundary_and_Tract_Data_Service.shp") 

st_crs(nps2)



