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
