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

library(tidyverse)      # useful data manipulation tools
library(sf)             # read and write shapefiles
library(tigris)         # downloading shapefiles for Method 1
library(leaflet)        # map creation
library(operator.tools) # not-in function

## load usa data ###########################################################
usa <- read_sf("./shapefiles/shifted/usa/usa.shp")
nps <- read_sf("./shapefiles/shifted/nps/nps.shp")

## get geopackage layers ###################################################
layers <- st_layers("./shapefiles/original/state_parks_padus/PADUS3_0Geopackage.gpkg")

## territories ############################################################
## the pad us shapefile includes the park boundaries for the 50 states and the
## associated territories. I only want the 50 states so I create a variable 
## that lists the postal abbreviations for the associated territories. We'll
## use the %!in% function included in operator.tools() to filter these areas
## out from the pad us data set.

territories <- c("AS", "GU", "MP", "PR", "VI")

## state parks #############################################################
## the PAD-US data set has 42 columns. I only want the state, area type, area name,
## and the shape. The shape column includes the coordinates necessary
## to create the map polygon. There are 4 types of park  which I wanted
## to make consistent with the national park types in the first mutate() call. 
## In the second mutate call, I create and fill in a variable that designates 
## whether I've been to the park. You will need to change these lines (or delete them)
## based on whether you've visited any state parks.

state_parks <- st_read("./shapefiles/original/state_parks_padus/PADUS3_0Geopackage.gpkg", layer = "PADUS3_0Fee")  %>%
    filter(State_Nm %!in% territories & 
           Own_Type == "STAT")  %>% 
    filter(Des_Tp == "ACC" |
           Des_Tp == "HCA" |
           Des_Tp == "REC" |
           Des_Tp == "SCA" |
           Des_Tp == "SHCA" |
           Des_Tp == "SP" |
           Des_Tp == "SREC" |
           Des_Tp == "SRMA" |
           Des_Tp == "SW")  %>% 
    filter(d_Pub_Acce != "Closed" & 
           d_Pub_Acce != "Unknown")  %>% 
    filter(Loc_Ds != "ACC" &
           Loc_Ds != "Hunter Access",
           Loc_Ds != "Public Boat Ramp") %>% 
    select(d_Own_Type, d_Des_Tp, Loc_Ds, Unit_Nm, State_Nm, d_State_Nm, GIS_Acres, SHAPE)  %>% 
    mutate(type = case_when(d_Des_Tp == "Access Area" ~ "State Trail",
                            d_Des_Tp == "Historic or Cultural Area" ~ "State Historical Park, Site, Monument, or Memorial",
                            d_Des_Tp == "State Historic or Cultural Area" ~ "State Historical Park, Site, Monument, or Memorial",
                            d_Des_Tp == "Recreation Management Area" ~ "State Preserve, Reserve, or Recreation Area",
                            d_Des_Tp == "State Resource Management Area" ~ "State Preserve, Reserve, or Recreation Area",
                            d_Des_Tp == "State Wilderness" ~ "State Preserve, Reserve, or Recreation Area",
                            d_Des_Tp == "State Recreation Area" ~ "State Preserve, Reserve, or Recreation Area",
                            d_Des_Tp == "State Conservation Area" ~ "State Preserve, Reserve, or Recreation Area",
                            d_Des_Tp == "State Park" ~ "State Park or Parkway"))  %>% 
    mutate(visited = case_when(Unit_Nm == "Valley of Fire State Park" ~ "visited",
                               Unit_Nm == "Crissey Field State Recreation Site" ~ "visited",
                               Unit_Nm == "Salton Sea" ~ "visited",
                               Unit_Nm == "Anza-Borrego Desert State Park" ~ "visited",
                               Unit_Nm == "	Jedediah Smith Redwoods State Park" ~ "visited",
                               Unit_Nm == "Del Norte Coast Redwoods State Park" ~ "visited",
                               TRUE ~ "not visited"))  %>% 
    shift_geometry(preserve_area = FALSE, # resizes alaska to fit with the size of the other states
                    position = "below") %>% # moves alaska so it's near hawaii
    sf::st_transform("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs") # changes the geographic data from NAD83 to WGS84

## save shifted state parks file [all states] ###########################################
# st_write(state_parks, "./shapefiles/shifted/states/state_parks.shp")

## save state parks by state ############################################################
## there's too many state parks to map them all at the same time. I split them up by state
## first, use split() to separate the parks by state. Next get the names of the split data
## sets - essentially, the state names. Finally, loop through and write each shapefile
## by state

split_states <- split(state_parks, f = state_parks$State_Nm) # split the data by state

all_names <- names(split_states)   
for(name in all_names){            
     st_write(split_states[[name]], paste0("shapefiles/shifted/states/individual/", name, '.shp')) 
}

## filter for states I've visited #######################################################
## there are a lot of state parks. R was having a difficult time sorting and filtering even
## the reduced data after selecting the columns I wanted above. Until I find a better way
## to track the state parks I've visited, this will have to do. I'm leaving this code here
## so if anyone else wants to see how I did it, it's available. Basically, I created a 
## variable that contains the postal abbreviations for the states I have visited. Then I 
## filter for those state (keeping only the ones listed). Finally, I drop the shape data so
## the file size is reduced. I save the data frame as a csv. I opened this in a spreadsheet
## program like excel, google sheets, or libre calc. From there I looked up the state parks
## and marked them visited. This is what is merged back into the data below.
# visited_states <- c("AZ", "CA", "HI", "ID", "NV", "NM", "OH", "OR", "TN", "UT", "WA", "WI") ## states I've visited
# visited_parks <- state_parks  %>% filter(State_Nm %in% states_been) %>% 
#     st_drop_geometry() ## delete the geometry data
#                             
# write.csv(visited_parks, "./csv/state_park_visited.csv") ## save the data frame to my hard drive.
