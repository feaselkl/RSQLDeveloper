######################################
### R For The SQL Server Developer ###
### Kevin Feasel                   ###
### 3 - Getting a Taste of R       ###
######################################

#Load various packages that we'll need.
install.packages('RCurl', repos = "http://cran.us.r-project.org")
install.packages('RDSTK', repos = "http://cran.us.r-project.org")
install.packages("ggplot2", repos = "http://cran.us.r-project.org")
install.packages("tidyr", repos = "http://cran.us.r-project.org")
install.packages("ggmap", repos = "http://cran.us.r-project.org")
library(RDSTK)
library(dplyr)
library(ggplot2)
library(tidyr)
library(ggmap)
print('Finished loading libraries.')

#I've geocoded restaurant data so you don't have to.
restaurants <- read.csv("http://www.catallaxyservices.com/media/blog/restaurants.csv", sep=",", header=TRUE)

#Basic details on the restaurants in the data set
summary(restaurants)
head(restaurants, 5)
tail(restaurants, 5)
summary(restaurants$score)

#Build a map of Wake County using Google Maps
wakemap <- get_map(location = c(lon = mean(restaurants$long), lat = mean(restaurants$lat)), zoom = 11, maptype = "roadmap", scale = 2)

#Plot restaurant data on top of that map
#This is a rather unhelpful heat map, so we'll try to create some more useful visualizations.
ggmap(wakemap, extent = "device") +
  geom_density2d(data = restaurants, aes(x=long,y=lat),size = 0.3) +
  stat_density2d(data=restaurants, aes(x=long, y=lat, fill=..level.., alpha=..level..), size=0.01, bins=16, geom="polygon") +
  scale_fill_gradient(low="red",high="green") +
  scale_alpha(range = c(0,0.3), guide=FALSE)

#Problems we are trying to solve:
#1) Where are the sketchy restaurants (rating of 85 or lower)?
#2) Which parts of Wake county have the worst ratings?
#3) Zooming into Cary, what do the ratings look like?

# Create a filter which gets ONLY restaurants with a rating UNDER 85.
sketchy <- filter(restaurants, score < 85)

# Use dplyr to get the number of failures (scores < 85) per lat-long pair.
sketchy <- sketchy %>%
  group_by(lat, long) %>%
  summarize(failures = n())

#Show all restaurant failure points on a map
ggmap(wakemap) +
  geom_point(data = sketchy, aes(x = long, y = lat, fill = "red", alpha=0.1, size = failures))

# We want to group restaurants by longitude and latitude.  Specifically, longitude and latitude at 1 place
# after the decimal.  This way, we can get clusters of restaurants and they'll show up on the map more clearly.
restgrp <- restaurants
restgrp$lat <- round(restgrp$lat, 1)
restgrp$long <- round(restgrp$long, 1)

# Use dplyr like in the sketchy example to do the following:
# 1)  Filter out any N/A scores
# 2)  Group by latitude and longitude
# 3)  Create two aggregates:  ratings, which is the number of records; and meanscore, which is the mean of scores
restgrp <- restgrp %>%
  filter(!is.na(score)) %>%
  group_by(lat, long) %>%
  summarize(ratings = n(), meanscore = mean(score))

# Set wakemap to a new map value.  This time, we set the zoom value to 10 so we can see the entire region.
wakemap <- get_map(location = c(lon = mean(restgrp$long), lat = mean(restgrp$lat)), zoom = 10, maptype = "roadmap", scale = 2)

# We want three function calls:
# scale_fill_gradient (to give us a visual cue of restuarants.  Pick good colors for low & high.)
# geom_text (to display the meanscore, giving us precise values.  Round meanscore to 1 spot after decimal)
# geom_tile (to display blocks of color.  Set alpha = 1)
ggmap(wakemap) +
  scale_fill_gradient(low="black",high="orange") +
  geom_text(data = restgrp, aes(x=long, y=lat, fill = meanscore, label = round(meanscore, 1))) +
  geom_tile(data = restgrp, aes(x=long, y=lat, alpha=1, fill=meanscore)) 

# For Cary restaurants, we want to go down to 2 spots after the decimal.  This is a nice compromise and should
# fit our map size better than prior examples.
caryrestgrp <- restaurants
caryrestgrp$lat <- round(caryrestgrp$lat, 2)
caryrestgrp$long <- round(caryrestgrp$long, 2)

# Use dplyr like in the sketchy example to do the following:
# 1)  Filter out any N/A scores
# 2)  Group by latitude and longitude
# 3)  Create two aggregates:  ratings, which is the number of records; and meanscore, which is the mean of scores
caryrestgrp <- caryrestgrp %>%
  filter(!is.na(score)) %>%
  group_by(lat, long) %>%
  summarize(ratings = n(), meanscore = mean(score))

# We will now create a Cary map with a zoom of 13 and longitude and latitude around a fixed point.
carymap <- get_map(location = c(lon = -78.8, lat = 35.8), zoom = 13, maptype = "roadmap", scale = 2)

# We want the same function calls as the wakemap example above, but we will fill in values from caryrestgrp instead of restgrp.
ggmap(carymap) +
  scale_fill_gradient(low="black",high="orange") +
  geom_text(data = caryrestgrp, aes(x=long, y=lat, fill = meanscore, label = round(meanscore, 1))) +
  geom_tile(data = caryrestgrp, aes(x=long, y=lat, alpha=1, fill=meanscore)) 
