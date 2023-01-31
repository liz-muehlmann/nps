## part IV: adding interactivity ########################################
##
## this file:
##

setwd("/Users/lizmo/Documents/GitHub/nps/")

## load libraries ##########################################################
## if you haven't downloaded these packages yet, you'll need to install them
## the syntax is: install.packages("package-name"). You only need to install
## the packages once, but you'll need to load the libraries every time.

library(tidyverse)      # useful data manipulation tools
library(sf)             # read and write shapefiles
library(tigris)         # downloading shapefiles for Method 1
library(leaflet)        # map creation
library(operator.tools) # not-in function
library(shiny)          # interactivity


## load data ################################################################
usa_base <- as_Spatial(read_sf("./shapefiles/shifted/usa/usa.shp"))
nps <- as_Spatial(read_sf("./shapefiles/shifted/nps/nps.shp"))


## calculate area devoted to public land ####################################
## the census TIGER/Shapefile reports land area (ALAND) in square meters while 
## the national park shapefile reports the park area in acres. I have opted to
## convert the states' area to acres. To convert square meters to acres you
## divide by 4,047. From there, I have to sort the parks by state then add the 
## areas together. I'll then divide by the size of the state to get the percentage
## devoted to public land.

# usa_base$acres <- usa_base$ALAND/4047
# 
# nps_areas <- nps  %>%
#              st_drop_geometry()  %>% 
#              group_by(STATE)  %>% 
#              mutate(area = sum(Shape__Are))  %>% 
#              distinct(STATE, .keep_all = TRUE)
# 
# usa_base$public <- nps_areas$area/usa_base$acres

## define colors ############################################################
## any modifications to the map need to be made before the map widget is called.
## in this section, I'll define the colors I want to use for the national park
## data set. I will color by time. Leaflet is fully compatible with RColorBrewer
## which has pre-defined color palettes: 
## https://r-graph-gallery.com/38-rcolorbrewers-palettes.html For maps, I also 
## suggest looking at these palettes https://colorbrewer2.org/#type=sequential&scheme=BuGn&n=3
## which help choose a palette specifically for mapped data. I want to use 
## specific colors (instead of a palette), so I'll define them here.

nps_color <- colorFactor(c("#B2AC88", # national historical
                           "#F9F2CB", # international historical       
                           "#99941A", # military
                           "#006C5F", # park
                           "#568762", # preserves and rec areas
                           "#31B8E6", # lakes and rivers
                           "#899B7C", # trails
                           "#AFAC99"), nps$type) # other

# ## create base & nps map ####################################################
# map <- leaflet() %>%
#   addPolygons(data = usa_base,
#     smoothFactor = 0.2,
#     fillColor = "#808080",
#     stroke = TRUE,
#     weight = 0.5,
#     opacity = 0.5,
#     color = "#808080",
#     highlightOptions = highlightOptions(
#       weight = 0.5,
#       color = "#000000",
#       fillOpacity = 0.7,
#       bringToFront = FALSE),
#     group = "Base Map") %>%  
#   addPolygons(data = nps,
#     smoothFactor = 0.2,                 
#     fillColor =  ~nps_color(type),
#     fillOpacity = 1,
#     stroke = TRUE,
#     weight = 1,     
#     opacity = 0.5,                       
#     color = "#354f52",             
#     highlight = highlightOptions(
#       weight = 3,
#       color = "#fff",
#       fillOpacity = 0.8,
#       bringToFront = TRUE),
#     group = "National Parks")  %>%
#   addLayersControl(
#     baseGroups = "Base Map",
#     overlayGroups = "National Parks",
#     options = layersControlOptions(collapsed = FALSE))

ui <- fillPage(tags$head(includeCSS("C:/Users/lizmo/Documents/GitHub/nps/r files/shiny/www/styles.css")),
              title = "National Parks I've Visited",
              bootstrap = TRUE,
              leafletOutput("map", width = "100%", height = "100%"),
              absolutePanel(id = "info-panel",
                            class = "panel panel-default", 
                            bottom = 75, 
                            left = 55, 
                            width = 250,
                            fixed = TRUE, 
                            draggable = FALSE, 
                           fluidRow(
                              column(
                                width = 12,
                                align = "center",
                                style = "height:auto",
                                p(class = "info-title", 
                                  "National Park Data:"),
                                textOutput("info_text")))))

server <- function(input, output) {
  output$map <- renderLeaflet({
    leaflet() %>%
  addPolygons(data = usa_base,
    layerId = ~NAME,
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
    # layerId = ~national_parks,
    smoothFactor = 0.2,                 
    fillColor =  ~nps_color(type),
    fillOpacity = 1,
    stroke = TRUE,
    weight = 0.2,     
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
    options = layersControlOptions(collapsed = FALSE))  %>% 
  addLegend(pal = nps_color,
            values = nps$type,
            position = "bottomright",
            title = "National Land by Type")
  })
  output$info_text <- renderText ({
    current_state = input$map_shape_mouseover$id
    if(is.null(current_state)){
      return("Hover over a state")
    } else{
      return(paste(current_state, " has an land area of ", usa_base@data[usa_base$NAME==current_state, 'ALAND'], " square miles. Approximately ", usa_base@data[usa_base$NAME==current_state, ''] ))
    }
  })
}
