## Luke Ozsanlav-Harris
## Created: 01/11/2022

## Use soil sample data and soil type map from the James Hutton Institute to determine range Al/Pb ratios in the soil
## Determine the soil types were we collected our poo samples on Islay
## Find soil samples from the James Hutton Institute from across Scotland with the same soil types (as poo samples) and from agricultural land
## Determine range of Al/Pb ratios in soil samples and compare then to the ratios in our poo samples
## Poo samples with elevated lead levels should have a lower Al/Pb ratio than those from the soil samples

## Packages required
pacman::p_load(tidyverse, data.table, sf, raster, rnaturalearth)




##--------------------------##
#### 1. Read in data sets ####
##--------------------------##

## Read in the shapefile with the Soil Types from across Scotland
SoilType <- st_read(dsn = "SoilData/SoilTypes", 
                layer = "qmsoils_UCSS_v1_3")

## Read in the shapefile with the Soil Samples from across Scotland
SoilSamp <- st_read(dsn = "SoilData/SoilSamples", 
                    layer = "NSIS_10km")
## filter the rows with the metal composition values, there are some rows with additional spatial data that we don't need
SoilSamp <- SoilSamp %>% filter(nipaqua_pb > 0)

## Read in the shapefile with the Islay Field boundaries
IslayFields <- st_read(dsn = "SpatialData/88090_ISLAY_GMS_FIELD_BOUNDARY", 
                       layer = "AS_ISLAY_GMS_FIELD_BOUNDARY")

## Read in the poo sample data with the field codes where sampels were collected appended
PooSites <- fread("Outputs/LeadData_with_FieldCodes.csv")
## sort out a couple fo typos in the data sheet
PooSites$Field_Code <- ifelse(PooSites$Field_Code == "2K4", "RK4", PooSites$Field_Code)
PooSites$Species <- ifelse(PooSites$Species == "D10", "GBG", PooSites$Species)

## Read in Landcover raster data for the UK
LandCov <- raster("SoilData/UKLandCover/lcm2015gb25m.tif") # has the same crs as the SoilType dataset so does not need transforming




##------------------------------------##
#### 2. Re-project the spatial data ####
##------------------------------------##

## Going to reproject all of the spatial dat so that it has the same crs as the soil types map

## define the target crs
TargetCrs <- st_crs(SoilType)

## transform the data
SoilSamptr <- st_transform(SoilSamp, crs = TargetCrs)
IslayFieldstr <- st_transform(IslayFields, crs = TargetCrs)





##--------------------------------------------------##
#### 3. Extract Soil types were poo was collected ####
##--------------------------------------------------##

## Add the field centroids to the poo sample data ##

## remove duplicates from the field data
dups <- duplicated(IslayFieldstr$FIELD_ID)
IslayFields <- filter(IslayFieldstr, !dups)

## calculate the centroid of each field
centroids <- sf::st_centroid(IslayFieldstr)

## Organise centroid data for a join 
centroids <- centroids %>% 
             dplyr::select(FIELD_ID, geometry) %>% 
             rename(Field_Code = FIELD_ID)

## Join the centorid data to the poo sampling sites
PooSitessf <- left_join(PooSites, centroids, by = "Field_Code")
plot(PooSitessf$geometry)


## Extract the soil types where the poo samples were collected ##
## Extract the column from the soil type data that I want
## Going to use the `MSSG84_1` column this contains the Major soil subgroup of the first named soil (Soil Survey of Scotland 1984 soil classification*)

## select columns
SoilTypeslim <- SoilType %>% dplyr::select(MSSG84_1, geometry)

## Crop to the extent of Islay to speed up geocopmutation
BBOX <- st_bbox(PooSitessf$geometry) 
BBOX[1:2] <- BBOX[1:2] - 10000; BBOX[3:4] <- BBOX[3:4] + 10000
SoilTypeslimcrop <- st_crop(SoilTypeslim, BBOX)

## plot of soil types and sampling locations
## Plot map with basemap and soil sampling sites
ggplot() + 
  geom_sf(data = SoilTypeslimcrop, aes(geometry = geometry, fill = MSSG84_1)) +
  geom_sf(data = PooSitessf, aes(geometry = geometry), size =3) +
  labs(x = "Longitude", y = "Latitude") +
  theme_light() +
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
        axis.text=element_text(colour="black"),
        axis.title.x = element_text(size = 15),
        axis.text.x = element_text(hjust=0.7),
        axis.title.y = element_text(angle=90, vjust = 0.4, size = 15),
        axis.text.y = element_text(hjust=0.7, angle=90, vjust=0.3))


## Calculate which Soil type for the field were each poo samples was collected
PooSamp_SoilTypes <- as.data.frame(st_within(PooSitessf$geometry, SoilTypeslimcrop))
PooSitessf$Soil <- SoilTypeslimcrop$MSSG84_1[PooSamp_SoilTypes$col.id]
table(PooSitessf$Soil)




##--------------------------------------------------------##
#### 4. Extract the soil samples from agricultural land ####
##--------------------------------------------------------##

## calcualte the ratio between Al and Pb
SoilSamptr$Ratio <- SoilSamptr$nipaqua_al/SoilSamptr$nipaqua_pb

## Extract the land cover values for the sites where the soil samples were taken
SoilSamptr$Habitat <- raster::extract(x= LandCov, y= SoilSamptr, method = "simple")

## Now just filter out the points with landcover values of 3 or 4 (Arable & Horticulture AND Improved grassland AND Natural Grassland)
SoilSamp_Agri <- filter(SoilSamptr, Habitat %in% c(3, 4))

## plot the Al/Pb ratios in soil 
ggplot() +
  geom_histogram(data = SoilSamp_Agri, aes(Ratio)) +
  facet_wrap(~mssg2013) + theme_light()




##------------------------------------------------------------##
#### 5. Extract Soil types were soil samples were collected ####
##------------------------------------------------------------##

## Calculate which Soil type where each of the soil samples were collected
## Sol names do not match between datsets so have to manually put them in below
table(PooSitessf$Soil) ## soil types were poo samples were collected
PooSoil_Freq <- as.data.frame(table(PooSitessf$Soil)) %>% 
                rename(SoilType = Var1) %>% 
                mutate(SoilType = recode(SoilType, 'Brown earths' = "Brown earth", 
                                         'Noncalcareous gleys' = "Noncalcareous gley", 
                                         'Humus-iron podzols' = "Humus-iron podzol", 
                                         'Peaty gleys' = "Peaty gley",
                                         'Peaty podzols' = "Peaty podzol", 
                                         'Mineral alluvial soils' = "Mineral alluvial soil", 
                                         'Blanket peat' = "Peaty ranker"))


## Filter out the soil types so only keep the soil types where poo samples were collected
Select_SoilSamp <- filter(SoilSamp_Agri, mssg2013 %in% PooSoil_Freq$SoilType)
unique(Select_SoilSamp$mssg2013)


## Re sample the data so that the frequency of soil types is the same in the Poo soil types and soil sample soil types
## Calculate the probabilities for the re sampling
PooSoil_Freq <- PooSoil_Freq %>% mutate(Probs = Freq/sum(Freq))
SoilSamp_Freq <- as.data.frame(table(Select_SoilSamp$mssg2013)) %>% rename(SoilType = Var1, Freq2 = Freq)
PooSoil_Freq <- PooSoil_Freq %>% left_join(SoilSamp_Freq, by = "SoilType") %>% 
                mutate(Probability = Probs/Freq2) %>% 
                dplyr::select(SoilType, Probability)

## Join the re sampling probabilities to the soil sample data
Select_SoilSamp <- Select_SoilSamp %>% 
                   dplyr::select(nipaqua_al, nipaqua_pb, msg2013, mssg2013, MAPSYMB, TempJoin, geometry, Ratio, Habitat) %>% 
                   left_join(PooSoil_Freq, by = c("mssg2013" = "SoilType"))

## Now do the re sampling
set.seed(1212)
Resamp_SoilSamps <- sample(x = Select_SoilSamp$Ratio, size = 1000, replace = TRUE, prob = Select_SoilSamp$Probability)





##--------------------------------------------------------##
#### 6. Plot histograms of Al/Pb ratios in soil and Poo ####
##--------------------------------------------------------##

## Create a AL/Pb ratio in the Poo sample data
PooSites$Ratio <- PooSites$Al/PooSites$Pb

## plot of soil and poo ratios
ggplot()+ 
  geom_histogram(data = Select_SoilSamp, aes(Ratio), fill = "blue", alpha = 0.5) +
  geom_histogram(data = PooSites, aes(Ratio), fill = "red", alpha = 0.5) +
  theme_light() 

## more zoomed in plot for low ratio value
ggplot()+ 
  geom_histogram(data = Select_SoilSamp, aes(Ratio), fill = "blue", alpha = 0.5) +
  geom_histogram(data = PooSites, aes(Ratio), fill = "red", alpha = 0.5) +
  theme_light() +
  xlim(0, 400)



##---------------------------------------------------------------##
#### 7. Plot overall Al/Pb ratios in soil with Poo data points ####
##---------------------------------------------------------------##


## Plot for the none re sampled data ##

## Create the ribbon to go in the plot based off of the soil samples 
Ribbons <- data.frame(Al = seq(1, 12500, by = 20))

## Add lines for the min/max
Ribbons$Ratio025 <- Ribbons$Al/quantile(Select_SoilSamp$Ratio, probs= 0.025)
Ribbons$Ratio975 <- Ribbons$Al/quantile(Select_SoilSamp$Ratio, probs= 0.975)
Ribbons$Mean <- Ribbons$Al/mean(Select_SoilSamp$Ratio)

Ribbons$MaxRatio <- Ribbons$Al/min(Select_SoilSamp$Ratio)
Ribbons$MinRatio <- Ribbons$Al/max(Select_SoilSamp$Ratio)


## create the plot with raw A/ & Pb from poo and ratio from soil as a ribbon
ggplot() + 
  geom_point(data=PooSites, aes(x=Al, y=Pb, colour = Species), size =1.8, shape = 21, stroke =1.5) + 
  geom_line(data=Ribbons, aes(x= Al, y = Mean), size = 1.25, colour = "black")  +
  geom_ribbon(data = Ribbons, aes(x=Al, ymin = Ratio025, ymax = Ratio975), alpha = 0.4, colour = NA, fill = "grey") + 
  geom_line(data = Ribbons, aes(x = Al, y = MaxRatio), linetype = 2) +
  geom_line(data = Ribbons, aes(x = Al, y = MinRatio), linetype = 2) +
  ylab("Pb (mg/kg of dry faeces)") + xlab("Al (mg/kg of dry faeces)") +
  theme_bw() +
  coord_cartesian(ylim=c(0,55)) +
  scale_colour_manual(values=c("#D55E00", "#0072B2")) +
  theme(panel.grid.major.y = element_blank(), panel.grid.minor.y = element_blank(), 
        axis.text=element_text(size=13), axis.title=element_text(size=17, face = "bold"), 
        plot.title = element_text(size=14, face="bold"), legend.text=element_text(size=12), legend.title=element_text(size=12),
        panel.grid.minor.x = element_blank(), strip.text.x = element_text(size = 13, face = "bold"))

ggsave("Outputs/Plots/Sup Fig- Soil Sample AlPb ratio.png", 
       width = 25, height = 22, units = "cm")


## Plot for the re sampled data ##

## Create the ribbon to go in the plot based off of the soil samples 
RibbonsRE <- data.frame(Al = seq(1, 12500, by = 20))

## Add lines for the min/max
RibbonsRE$Ratio025 <- Ribbons$Al/quantile(Resamp_SoilSamps, probs= 0.025)
RibbonsRE$Ratio975 <- Ribbons$Al/quantile(Resamp_SoilSamps, probs= 0.975)
RibbonsRE$Mean <- Ribbons$Al/mean(Resamp_SoilSamps)

RibbonsRE$MaxRatio <- Ribbons$Al/min(Resamp_SoilSamps)
RibbonsRE$MinRatio <- Ribbons$Al/max(Resamp_SoilSamps)


## create the plot with raw A/ & Pb from poo and ratio from soil as a ribbon
ggplot() + 
  geom_point(data=PooSites, aes(x=Al, y=Pb, colour = Species), size =1.8, shape = 21, stroke =1.5) + 
  geom_line(data=RibbonsRE, aes(x= Al, y = Mean), size = 1.25, colour = "black")  +
  geom_ribbon(data = RibbonsRE, aes(x=Al, ymin = Ratio025, ymax = Ratio975), alpha = 0.4, colour = NA, fill = "grey") + 
  geom_line(data = RibbonsRE, aes(x = Al, y = MaxRatio), linetype = 2) +
  geom_line(data = RibbonsRE, aes(x = Al, y = MinRatio), linetype = 2) +
  ylab("Pb (mg/kg of dry faeces)") + xlab("Al (mg/kg of dry faeces)") +
  theme_bw() +
  coord_cartesian(ylim=c(0,55)) +
  scale_colour_manual(values=c("#D55E00", "#0072B2")) +
  theme(panel.grid.major.y = element_blank(), panel.grid.minor.y = element_blank(), 
        axis.text=element_text(size=13), axis.title=element_text(size=17, face = "bold"), 
        plot.title = element_text(size=14, face="bold"), legend.text=element_text(size=12), legend.title=element_text(size=12),
        panel.grid.minor.x = element_blank(), strip.text.x = element_text(size = 13, face = "bold"))

ggsave("Outputs/Plots/Sup Fig- Soil Sample AlPb ratio RESAMPLED.png", 
       width = 25, height = 22, units = "cm")




##-----------------------------------------------------------##
#### 8. Plot locations of soil samples used in above method ####
##-----------------------------------------------------------##

## use rnatural earth high res countries basemap
countries <- ne_countries(scale = "large", returnclass = "sf")

## transform the base map to the same crs os the soil site shapefile
countries <- st_transform(countries, crs = st_crs(Select_SoilSamp))

## crop the countries shapefile to just a region around Islay and Jura
BBOX <- st_bbox(Select_SoilSamp) 
BBOX[1:2] <- BBOX[1:2] - 80000
BBOX[3:4] <- BBOX[3:4] + 30000
countries_crop <- st_crop(countries, BBOX)

## Plot soil samples over map of Scotland
ggplot() + 
  geom_sf(data = countries_crop, aes(geometry = geometry), show.legend = FALSE) +
  geom_sf(data = Select_SoilSamp, aes(geometry = geometry, colour = mssg2013), size =3) +
  labs(x = "Longitude", y = "Latitude", colour = "Soil Type") +
  theme_light() +
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
        axis.text=element_text(colour="black"),
        axis.title.x = element_text(size = 15),
        axis.text.x = element_text(hjust=0.7),
        axis.title.y = element_text(angle=90, vjust = 0.4, size = 15),
        axis.text.y = element_text(hjust=0.7, angle=90, vjust=0.3))

ggsave("Outputs/Plots/Sup Fig- Map of soil sampling sites used.png", 
       width = 25, height = 22, units = "cm")






