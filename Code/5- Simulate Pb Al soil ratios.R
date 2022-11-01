## Luke Ozsanlav-Harris

## Use soil sample data from the James Hutton Institute to simulate possible Pb/Al ratios in the soil
## We will use soil data from 9 sites across Islay and Jura
## We will compare the ratios of Pb to Al from our simulation to the ratios in our fecal samples


## Packages required
pacman::p_load(tidyverse, data.table, sf,rnaturalearth, marmap, truncnorm)


##----------------------------##
#### 1. Read in sample data ####
##----------------------------##

## Read in the cropped shapefile with the soil sample data from Islay and Jura
Soil <- st_read(dsn = "SpatialData/Islay_Jura_Soil", 
               layer = "IslayJura_Soil")

## filter the ones with the metal values 
Soil <- Soil %>% filter(nipaqua_pb > 0)



##--------------------------------##
#### 2. Map Soil sampling sites ####
##--------------------------------##

## use rnatural earth high res countries basemap
countries <- ne_countries(scale = "large", returnclass = "sf")

## transform the base map to the same crs os the soil site shapefile
countries <- st_transform(countries, crs = st_crs(Soil))

## crop the countries shapefile to just a region around Islay and Jura
BBOX <- st_bbox(Soil) 
BBOX[1:2] <- BBOX[1:2] - 30000
BBOX[3:4] <- BBOX[3:4] + 30000
countries_crop <- st_crop(countries, BBOX)


## Plot map with basemap and soil sampling sites
ggplot() + 
  geom_sf(data = countries_crop, aes(geometry = geometry), fill = NA) +
  geom_sf(data = Soil, aes(geometry = geometry, colour = nipaqua_pb), size =3) +
  scale_colour_viridis_c(option="viridis", name = "Lead (mg/kg)") +
  labs(x = "Longitude", y = "Latitude") +
  theme_light() +
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
        axis.text=element_text(colour="black"),
        axis.title.x = element_text(size = 15),
        axis.text.x = element_text(hjust=0.7),
        axis.title.y = element_text(angle=90, vjust = 0.4, size = 15),
        axis.text.y = element_text(hjust=0.7, angle=90, vjust=0.3))
  



##-------------------------------------------------##
#### 3. Calculate variation in Pb and AL in Soil ####
##-------------------------------------------------##

## Calculate mean and SD of Pb and Al across the 9 sampling sites
Pb_mean <- mean(Soil$nipaqua_pb)
Pb_sd <- sd(Soil$nipaqua_pb)
Al_mean <- mean(Soil$nipaqua_al)
Al_sd <- sd(Soil$nipaqua_al)

## calcualte the mean ratio
Mean_ratio <- mean(Soil$nipaqua_al/Soil$nipaqua_pb)
SD_ratio <- sd(Soil$nipaqua_al/Soil$nipaqua_pb)

## Calculate the standard deviation around the ratio using the delta method, forumla below
std.dev = function(b,c){
  
  var.b <- var(b)
  var.c <- var(c)
  cov.bc <- cov(b,c)
  
  a <- sum(b)/sum(c)
  
  pd.a.b <- 1/sum(c)
  pd.a.c <- -sum(b)/sum(c)^2
  
  pd.mat  <- matrix(c(pd.a.b, pd.a.c), nrow=1)
  vcv.mat <- matrix(c(var.b, cov.bc, cov.bc, var.c), nrow = 2, byrow = TRUE)
  mat1  <- pd.mat %*% vcv.mat
  var.a <- mat1   %*% t(pd.mat)
  
  return(sqrt(var.a))
  
}

## Calculate the standard deviation of the ration between Al and Pb
Sd_ratio <- std.dev(Soil$nipaqua_al, Soil$nipaqua_pb)



##
#### 4. Run simulation of Al Pb ratios ####
##

## Number of times to sample
N_sim <- 1000

## Simulate values from the ratio
set.seed(1212)
Ratio_sim <- as.data.frame(rtruncnorm(N_sim, a = 0, b = Inf, mean = Mean_ratio, sd= SD_ratio)) %>% rename(Ratio = colnames(.)[1])


## Simulate values for Pb and Al then calculate the ratio
Pb_vals <- rtruncnorm(n = N_sim,a = 0, b = Inf, mean = Pb_mean,sd = Pb_sd)
Al_vals <- rtruncnorm(n = N_sim,a = 0, b = Inf, mean = Al_mean,sd = Al_sd)

Sims <- as.data.frame(cbind(Al_vals, Pb_vals))
Sims$Ratio <- Sims$Al_vals/Sims$Pb_vals



##
#### 5. Plot simulation alongside real data ####
##

## Read in the faecal sampling data 
Feacal <- fread("Data/Lead lab analysis.csv")

## calculate the ratio  between the 
Feacal <- Feacal %>% mutate(Ratio = Al/Pb)


ggplot() +
  geom_histogram(data = Feacal, aes(Ratio), fill = "red", alpha = 0.2) +
  geom_histogram(data = Ratio_sim, aes(Ratio), fill = "blue", alpha = 0.2) +
  theme_light()  + xlim(-100,1700)

hist(Pb_vals)
