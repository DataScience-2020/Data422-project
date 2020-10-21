# coded by Jian ZHOU
# Jian ZHOU 51404140 jzh210@uclive.ac.nz
# This code is used to plot a world map by using geojson data combined with storyline locations globally extracted by Clavin
library(sf)
library(tidyverse)
library(ggplot2)

#read datasets from files
world_shp <- read_sf('ne_10m_admin_0_countries.geojson')
story_plc <- read.csv('story_place_2010.csv', header=TRUE)

#convert number of occurance to numeric type
story_plc$NUM <- as.numeric(story_plc$NUM)

# calculate points at which to plot labels
centroids <- world_shp %>% 
    st_centroid() %>% 
    bind_cols(as_data_frame(st_coordinates(.)))    # unpack points to lat/lon columns


#plot the map using storyline location data
story_plc %>% 
	#left_join(ecuador_shp, ., by = c('DPA_DESPRO' = 'STATE')) %>%
	left_join(world_shp, ., by = 'NAME') %>% 
	ggplot() + 
    geom_sf(aes(fill = NUM, color = NUM)) + 
    #geom_text(aes(X, Y, label = NAME), data = centroids, size = 1, color = 'white') +
    ggtitle("2010 IMDB Storyline Location Distribution") +
    theme(axis.title.x = element_text(colour="DarkGreen",size=0),
          axis.title.y = element_text(colour="Red",size=0),
          axis.text.x = element_text(size=0),
          axis.text.y = element_text(size=0),
          
          legend.title = element_text(size=10),
          legend.text = element_text(size=10),
          
          #legend.position = c(1,0), # need to add more
          #legend.justification =c(1,0),
          
          plot.title = element_text(size=15, colour="Orange", family="Courier")
    )


