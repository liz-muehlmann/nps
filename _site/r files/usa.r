## part I: creating a US base map ########################################
##
## this file:
##      - Creates & saves the US basemap with Alaska & Hawaii in shifted
##        positions.
##          - Method 1: Downloads the cartographic boundaries using tigris()
##          - Method 2: Loads shapefile downloaded from the US Census website.
##      - Only one method is necessary, but the others are included for
##        reference in conjunction with my tutorial here:
##        https://www.liz-muehlmann.github.io/notes/cartography-in-r
##
## data source:
##      - Shapefiles can be downloaded by going to https://www.census.gov
##          - From the Data & Maps menu select on Mapping Files
##          - Halfway down the page there's a link titled "TIGER Data
##            Products Guide"
##            (https://www.census.gov/programs-surveys/geography/guidance/tiger-data-products-guide.html)
##          - Select "Cartographic Boundaries Shapefiles"
##            (https://www.census.gov/geographies/mapping-files/time-series/geo/cartographic-boundary.html)
##          - Select "Cartographic Boundary Files by Scale" [1:500,000 (national)]
##          - Unzip it
##          - This will download Shapefiles for a lot of Census data. Look for the
##            zip folder called "cb_2021_us_state_500k" and unzip it.
##
## Next:
##       - part II: loads and processes the national park boundaries (nps.r)
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

## method 1: downloading data using tigris() ##############################
states <- tigris::states(cb = TRUE, year = 2020) %>%
  filter(STATEFP < 57) %>% # keep only the 50 US states.
  shift_geometry(
    preserve_area = FALSE, # resize Alaska
    position = "below") %>% # move Alaska so it's by Hawaii
  sf::st_transform("+proj=longlat +datum=WGS84") # reproject the geographic data from NAD83 to WGS84

## method 2: using data downloaded from the census website ################
usa <- read_sf("shapefiles\\original\\usa\\states\\cb_2021_us_state_500k.shp") %>%
  filter(STATEFP < 57) %>%
  shift_geometry(
    preserve_area = FALSE,
    position = "below") %>%
  sf::st_transform("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs")

## save the shifted USA (uncomment EITHER line 55 or line 58) #############
#st_write(states, "C:/Users/lizmo/Documents/GitHub/nps/shapefiles/shifted/states.shp") # before the comma is the data to save and after is where you want to save it
## usa.shp is the filename the file will have. You have to save it with the .shp extension, but you can name it whatever you want.

# st_write(usa, "C:/Users/lizmo/Documents/GitHub/nps/shapefiles/shifted/usa.shp")

## create maps ###########################################################
## the maps created below are very basic. There are no markers or names.
## usually, I just make sure that Wisconsin & Michigan are separated by
## the great lakes. Sometimes it creates a weird frankenstate. Before I
## go and do all the work to create labels, this is just a decent gut-check.

method1 <- leaflet() %>%
  addPolygons(data = states,
    smoothFactor = 0.2,
    fillColor = "#808080",
    fillOpacity = .5,
    stroke = TRUE,
    weight = 0.5,
    opacity = 0.5,
    color = "#808080",
    highlight = highlightOptions(
      weight = 0.5,
      color = "#000000",
      fillOpacity = 0.7,
      bringToFront = FALSE),
    group = "Base Map")

method2 <- leaflet() %>%
  addPolygons(data = states,
    smoothFactor = 0.2,
    fillColor = "#808080",
    fillOpacity = .5,
    stroke = TRUE,
    weight = 0.5,
    opacity = 0.5,
    color = "#808080",
    highlight = highlightOptions(
      weight = 0.5,
      color = "#000000",
      fillOpacity = 0.7,
      bringToFront = FALSE),
    group = "Base Map")