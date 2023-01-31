## part II: national park processing #######################################
##
## this file:
##      - loads and processes the national park service boundaries
##      - saves the shifted national park service boundaries
##
## data source:
##      - Shapefiles can be downloaded by going to https://public-nps.opendata.arcgis.com/
##          - From here select "boundaries"
##          - Find the file called "nps boundary"
##          https://public-nps.opendata.arcgis.com/datasets/nps::nps-boundary-1/explore?location=14.071968%2C-12.497900%2C3.05
##          - This will open a map and on the left will be a download button
##          - Click the download link under "Shapefile"
##          - Save and unzip the file.
##
## next:
##      - part III: state park processing
##  
############################################################################

## load libraries ##########################################################
## if you haven't downloaded these packages yet, you'll need to install them
## the syntax is: install.packages("package-name"). You only need to install
## the packages once, but you'll need to load the libraries every time.
library(tidyverse)          # useful data manipulation tools
library(sf)                 # read and write shapefiles
library(operator.tools)     # %!in% function
library(tigris)             # used to shift Alaska & Hawaii
library(leaflet)            # map making

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
 
nps <- read_sf("./shapefiles/acres/NPS_-_Land_Resources_Division_Boundary_and_Tract_Data_Service.shp")  %>% # load shapefile
    select(STATE, UNIT_TYPE, PARKNAME, area, geometry) %>% # select only certain columns from the nps data
    filter(STATE %!in% territories) %>%  # filter out the outlying islands and associated territories
    mutate(type = case_when(UNIT_TYPE == "International Historic Site" ~ "International Historic Site", # there's 23 types of national land, I wanted to reduce this number.
                UNIT_TYPE == "National Battlefield Site" ~ "National Military or Battlefield", # lines 56-77 reduce the number of park types
                UNIT_TYPE == "National Military Park" ~ "National Military or Battlefield", 
                UNIT_TYPE == "National Battlefield" ~ "National Military or Battlefield",
                UNIT_TYPE == "National Historical Park" ~ "National Historical Park, Site, Monument, or Memorial",
                UNIT_TYPE == "National Historic Site" ~ "National Historical Park, Site, Monument, or Memorial",
                UNIT_TYPE == "National Historic Trail" ~ "National Historical Park, Site, Monument, or Memorial",
                UNIT_TYPE == "National Memorial" ~ "National Historical Park, Site, Monument, or Memorial",
                UNIT_TYPE == "National Monument" ~ "National Historical Park, Site, Monument, or Memorial",
                UNIT_TYPE == "National Preserve" ~ "National Preserve, Reserve, or Recreation Area",
                UNIT_TYPE == "National Reserve" ~ "National Preserve, Reserve, or Recreation Area",
                UNIT_TYPE == "National Recreation Area" ~ "National Preserve, Reserve, or Recreation Area",
                UNIT_TYPE == "National River" ~ "National River, Lakeshore, or Seashore",
                UNIT_TYPE == "National Lakeshore" ~ "National River, Lakeshore, or Seashore",
                UNIT_TYPE == "National Wild & Scenic River" ~ "National River, Lakeshore, or Seashore",
                UNIT_TYPE == "National Seashore" ~ "National River, Lakeshore, or Seashore",
                UNIT_TYPE == "National Trails Syste" ~ "National Trail",
                UNIT_TYPE == "National Scenic Trail" ~ "National Trail",
                UNIT_TYPE == "National Park" ~ "National Park or Parkway",
                UNIT_TYPE == "Park" ~ "National Park or Parkway",
                UNIT_TYPE == "Parkway" ~ "National Park or Parkway",
                UNIT_TYPE == "Other Designation" ~ "Other National Land Area")) %>% 
    mutate(visited = case_when(PARKNAME == "Joshua Tree" ~ "visited", # this creates a new variable "visited" in the nps data
                                PARKNAME == "Redwood" ~ "visited", # it marks the park as visited if the park name matches
                                PARKNAME == "Santa Monica Mountains" ~ "visited", 
                                PARKNAME == "Sequoia" ~ "visited", 
                                PARKNAME == "Kings Canyon" ~ "visited",
                                PARKNAME == "Lewis and Clark" ~ "visited",
                                PARKNAME == "Mount Rainier" ~ "visited",
                                PARKNAME == "Siskiyou National Forest" ~ "visited",
                                TRUE ~ "not visited")) %>%  # all other parks are marked as "not visited"
    shift_geometry(preserve_area = FALSE, # resizes alaska to fit with the size of the other states
                    position = "below") %>% # moves alaska so it's near hawaii
    sf::st_transform("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs") # changes the geographic data from NAD83 to WGS84

## save shifted map #######################################################
#st_write(nps, "shapefiles/shifted/nps/nps.shp") # saves the data "nps" to the path specified

map <- leaflet() %>%
  addPolygons(data = states,
    smoothFactor = 0.2,
    fillColor = "#808080",
    stroke = TRUE,
    weight = 0.5,
    opacity = 0.5,
    color = "#808080",
    highlightOptions = highlightOptions(
      weight = 0.5,
      color = "#000000",
      fillOpacity = 0.7,
      bringToFront = FALSE),
    group = "Base Map") %>%  
  addPolygons(data = nps,
    smoothFactor = 0.2,                 
    fillColor = "#354f52",
    fillOpacity = 1,
    stroke = TRUE,
    weight = 1,     
    opacity = 0.5,                       
    color = "#354f52",             
    highlight = highlightOptions(
      weight = 3,
      color = "#fff",
      fillOpacity = 0.8,
      bringToFront = TRUE),
    group = "National Parks")  %>%
  addLayersControl(
    baseGroups = "Base Map",
    overlayGroups = "National Parks",
    options = layersControlOptions(collapsed = FALSE))
