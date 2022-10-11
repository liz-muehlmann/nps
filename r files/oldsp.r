state_parks <- st_read("./shapefiles/original/state_parks_padus/PADUS3_0Geopackage.gpkg", layer = "PADUS3_0Fee")  %>% 
    filter(State_Nm %!in% territories)  %>% 
    filter(d_Own_Type == "State" & d_Des_Tp == "Recreation Management Area" | 
           d_Des_Tp == "State Historic or Cultural Area"  | 
           d_Des_Tp == "State Park" | 
           d_Des_Tp == "State Wilderness")  %>% 
    select(d_Des_Tp, Unit_Nm, State_Nm, d_State_Nm, GIS_Acres) %>% 
    mutate(type = case_when(d_Des_Tp == "Recreation Management Area" ~ "State Preserve, Reserve, or Recreation Area", 
                            d_Des_Tp == "State Historic or Cultural Area" ~ "Historical Park, Site, Monument, or Memorial",
                            d_Des_Tp == "State Park" ~ "State Park",
                            d_Des_Tp == "State Wilderness" ~ "State Wilderness"))   %>% 
    mutate(visited = case_when(Unit_Nm == "Valley of Fire State Park" ~ "visited",
                               Unit_Nm == "Jedediah Smith Redwoods State Park" ~ "visited",
                               Unit_Nm == "Del Norte Coast Redwoods State Park" ~ "visited",
                               Unit_Nm == ""
                               TRUE ~ "not visited"))  %>% 
      shift_geometry(preserve_area = FALSE, # resizes alaska to fit with the size of the other states
                    position = "below") %>% # moves alaska so it's near hawaii
    sf::st_transform("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs") # changes the geographic data from NAD83 to WGS84

st_write(state_parks, "./shapefiles/shifted/states/state_parks.shp")
                            
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
# states_been <- c("AZ", "CA", "HI", "ID", "NV", "NM", "OH", "OR", "TN", "UT", "WA", "WI") ## states I've visited
# been <- state_parks  %>% filter(State_Nm %in% states_been) %>% 
#     st_drop_geometry() ## delete the geometry data
#                             
# write.csv(been, "./csv/state_park_visited.csv") ## save the data frame to my hard drive.

## add state parks to the map ##############################################################
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
     addPolygons(data = state_parks,
    smoothFactor = 0.2,                 
    fillColor = "#354152",
    fillOpacity = 1,
    stroke = TRUE,
    weight = 1,     
    opacity = 0.5,                       
    color = "#354152",             
    highlight = highlightOptions(
      weight = 3,
      color = "#fff",
      fillOpacity = 0.8,
      bringToFront = TRUE),
    group = "State Parks")  %>% 
  addLayersControl(
    baseGroups = "Base Map",
    overlayGroups = c("National Parks", "State Parks")
    options = layersControlOptions(collapsed = FALSE))
