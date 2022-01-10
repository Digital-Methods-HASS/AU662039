# https://github.com/jessecambon/tidygeocoder 
# https://leaflet-extras.github.io/leaflet-providers/preview/ maps i need
# mesurement script https://github.com/Digital-Methods-HASS/MapsWithLeaflet/commit/6590b5530582c471b94be9734a8bc28a36436d85
# Search bar https://community.rstudio.com/t/how-to-add-search-box-on-tmap-leaflet-linked-to-google-street-map-using-r/67741

# I use the packet rio to export from Rstudio 

install.packages("rio")
install.packages("leaflet.extras")
install.packages("tidygeocoder")

library(rio)
library(leaflet.extras)
library(dplyr, warn.conflicts = FALSE)
library(revgeo)
library(tidygeocoder)
library(leaflet)
library(htmlwidgets)
library(ggplot2)
library(htmltools)


#read file, its import to rember where you put your document and what you load
pd <- read.csv2("C:/Users/erikl/Documents/Rstudio_files/Ddd_V5_special.csv")
pd

#Here i check the names of the columns in the file
colnames(pd)

#checking the class
class(pd)

#i need this for the geocoding, because here i pull out the places

pd2 <- pd$Place_of_death

#now i have a list of places where they died called pd2, pd means place of death.
pd2

# I used the geocode function to get the longitude and latitude it take,
# roughly around 48 minutes to run this command, so get some coffee

#using some magic from my github saviour Jessecambon
#some_addresses <- tibble::tibble(pd2)

# Also i had to deactivate line 47-48, after i got the cordinates 
# because i dont want to start it by mistake, it does take around 45 minuts.

#lat_long3 <- some_addresses%>%
#geocode(pd2, method = 'osm', lat = latitude , long = longitude)


#after getting the cords, save them in the data in the folder you work in 
# so you can get it again

# Here i combine my main file with the latitude and longitude 
# and assign it the value soldier
soldiers <- cbind(pd,lat_long3)
head(soldiers)

mainmap5 <-leaflet(lat_long3) %>% 
  addTiles() %>% 
  addCircleMarkers(lng = soldiers$longitude, 
                   lat = soldiers$latitude,
                   popup = paste(
                     "<strong>Name: </strong>",soldiers$ï..Name_of_deceased,
                     "<br><strong>Last Name: </strong>",soldiers$Last_name_of_deceased,
                     "<br><strong>Location: </strong>",soldiers$Place_of_death,
                     "<br><strong>Age of death: </strong>",soldiers$Age_of_death,
                     "<br><strong>Date : </strong>",soldiers$Date_of_death,
                     "<br><strong>Cause of death : </strong>",soldiers$Cause_of_death,
                     "<br><strong>Rank: </strong>",soldiers$Militaryranks,
                     "<br><strong>Place of birth: </strong>",soldiers$Place_of_birth,
                     "<br><strong>Typers comment: </strong>",soldiers$Typers_comment),
                   color = "red",
                   weight = 10,
                   radius = 8,
                   clusterOptions = markerClusterOptions( spiderfyOnMaxZoom = TRUE)
  ) %>%
  addMeasure(
    position = "bottomleft",
    primaryLengthUnit = "meters",
    primaryAreaUnit = "sqmeters",
    activeColor = "#3D535D",
    completedColor = "#7D4479") %>% 
  htmlwidgets::onRender("
                        function(el, x) {
                        var myMap = this;
                        myMap.on('baselayerchange',
                        function (e) {
                        myMap.minimap.changeLayer(L.tileLayer.provider(e.name));
                        })
                        }") %>% 
  addProviderTiles("Esri.WorldPhysical", group = "Physical") %>% 
  addProviderTiles("Esri.WorldImagery", group = "Aerial") %>% 
  addProviderTiles("MtbMap", group = "Geo") %>% 
  addProviderTiles("OpenRailwayMap", group = "Railway") %>% 
  addLayersControl(
    baseGroups = c("CartoDB.DarkMatter","Aerial", "Physical","Geo", "Railway"),
    options = layersControlOptions(collapsed = T)) %>%
  setView(lng = 7.6393248, lat = 50.7551004, zoom = 5) %>%
  leaflet.extras::addSearchOSM(options = searchOptions(collapsed = TRUE, minLength = 2)) %>%
  addFullscreenControl()
  
mainmap5  


#here i make it to a html file that you can open in the browser
save_html(mainmap5,"worldwar1map.html")

#here i extract the lat and long to an excel so i can work in openrefine with them
export(lat_long3, "Test_lat_long_main_1.xlsx")
