## Luke Ozsanlav-Harris

## Script structure/goals
## 1. Read in the data sets required
## 2. Calculate field centroids and those that fall within RAMSAR sites
## 3. Prepare the shooting data and extract the shooting intensity for lead and non-lead
## 4. Add shooting intensity to each field code and then read out as a shapefile
## 5. Calculate the total area of all fields and those shot over
## 6. Identify fields within a 1km buffer of sampling fields and calculate shooting intensity in the buffer
## 7. Plot Shooting intensity by year


## packages 
library(tidyverse)
library(data.table)
library(rgeos)
library(sf)
library(lubridate)





#-----------------------------------------#
#### 1. Read in the data sets required ####
#-----------------------------------------#


## read in the field shapefile
Islay_field <- st_read(dsn = "SpatialData/88090_ISLAY_GMS_FIELD_BOUNDARY", 
                         layer = "AS_ISLAY_GMS_FIELD_BOUNDARY")
st_crs(Islay_field) ## check the crs of the layer

## Read in the shapefile of the Ramsar wetlands
Ramsar <- st_read(dsn = "SpatialData/RAMSAR_SCOTLAND_ESRI", 
                       layer = "RAMSAR_SCOTLAND")
st_crs(Ramsar) ## check the crs of the layer


## read in the lead analysis data with the field codes
lead <- fread("Outputs/LeadData_with_FieldCodes.csv")

## read in the shooting data
shoot_data <- fread("Data/Shooting logs cleaned.csv")





#----------------------------------------------------------------------------#
#### 2. Calculate field centroids and those that fall within RAMSAR sites ####
#----------------------------------------------------------------------------#

## remove duplicates from the field data
dups <- duplicated(Islay_field$FIELD_ID)
Islay_field <- filter(Islay_field, !dups)

## calculate the centroid of each field
centroids <- sf::st_centroid(Islay_field)

## Which fields are within the designated RAMSAR wetlands
## trim the RAMSAR file and check that the cropping has worked
Ramsar_crop <- st_crop(Ramsar, xmin = 100000, ymin = 600000, xmax = 150000, ymax = 700000)
plot(st_geometry(Ramsar_crop), border = 'black', axes = TRUE)

## find fields within the RAMSAR shapefile
##Which field centroids fall within the RAMSAR shapes
Desig_fields <- as.data.frame(st_within(centroids, Ramsar_crop))

## Assign a 1 to the designated fields
Islay_field$RAMSAR <- 0
Islay_field$RAMSAR[c(Desig_fields$row.id)] <- 1





#---------------------------------------------------------------------------------------------#
#### 3. Prepare the shooting data and extract the shooting intensity for lead and non-lead ####
#---------------------------------------------------------------------------------------------#

## Assign RAMSAR status to the fields in the shooting logs
RAMSAR_fields <- Islay_field %>% filter(RAMSAR == 1) %>% as.data.frame() %>% select(c("FIELD_ID", "RAMSAR"))
IDs <- as.vector(RAMSAR_fields$FIELD_ID)
shoot_data$RAMSAR <- ifelse(shoot_data$Field_code_Cl %in% c(IDs), 1, 0)

## set the date and add a year column
shoot_data$Date_Cl <- ymd(shoot_data$Date_Cl)
shoot_data$year <- year(shoot_data$Date_Cl)

## filter the data set so that there isn't any data for the winter after our sample were collected
shoot_data_cut <- filter(shoot_data, Date_Cl < "2019-05-15")
shoot_data_cut <- filter(shoot_data_cut, is.na(Shots_fired_Cl) == F & is.na(Field_code_Cl) == F) ## just the shooting events with field codes

## Filter out shooting events that were only using a rifle
## There are a lot of NAs in the gun type column and need to change the NAs to unknown for the filtering to work
shoot_data_cut$Gun_used_S_R_Cl <- ifelse(is.na(shoot_data_cut$Gun_used_S_R_Cl)==T, "Unknwon", shoot_data_cut$Gun_used_S_R_Cl)
shoot_data_cut <- filter(shoot_data_cut, !Gun_used_S_R_Cl=="R")
table(shoot_data_cut$Gun_used_S_R_Cl)

## calculate a decay factor for each year
shoot_data_cut$decay_years <- as.numeric(max(shoot_data_cut$year) - shoot_data_cut$year)
shoot_data_cut$decay_years <- ifelse(shoot_data_cut$decay_years == 0, 1, shoot_data_cut$decay_years)
shoot_data_cut$decay <- 1/(shoot_data_cut$decay_years)
shoot_data_cut$decay_shoot <- shoot_data_cut$Shots_fired_Cl * shoot_data_cut$decay
  
## Calculate the total number of shots for each field over time
Shoot_sum <- shoot_data_cut %>% 
             group_by(Field_code_Cl) %>% 
             summarise(shoot_int = sum(Shots_fired_Cl, na.rm = T),
                       shoot_int_decay = sum(decay_shoot, na.rm = T),
                       RAMSAR = max(RAMSAR)) %>% 
             ungroup()

## If fields are RAMSAR then change the lead shots fired to zero
Shoot_sum$lead_shoot_int <- ifelse(Shoot_sum$RAMSAR == 1, 0, Shoot_sum$shoot_int)
Shoot_sum$lead_shoot_int_decay <- ifelse(Shoot_sum$RAMSAR == 1, 0, Shoot_sum$shoot_int_decay)

## Add all the other field codes and give them a zero
all_fields <- as.data.frame(Islay_field$FIELD_ID)
colnames(all_fields)[1] <- "Field_code_Cl"

## Now join the two data sets together
Shoot_sum2 <- full_join(Shoot_sum, all_fields, by = "Field_code_Cl")
Shoot_sum2$shoot_int <- ifelse(is.na(Shoot_sum2$shoot_int) == T, 0, Shoot_sum2$shoot_int)
Shoot_sum2$shoot_int_decay <- ifelse(is.na(Shoot_sum2$shoot_int_decay) == T, 0, Shoot_sum2$shoot_int_decay)
Shoot_sum2$lead_shoot_int <- ifelse(is.na(Shoot_sum2$lead_shoot_int) == T, 0, Shoot_sum2$lead_shoot_int)
Shoot_sum2$lead_shoot_int_decay <- ifelse(is.na(Shoot_sum2$lead_shoot_int_decay) == T, 0, Shoot_sum2$lead_shoot_int_decay)





#----------------------------------------------------#
#### 4. Add shooting intensity to each field code ####
#----------------------------------------------------#

## rename column names for the join
setnames(Shoot_sum2, old = "Field_code_Cl", new = "FIELD_ID")

#### THINK SOMETHING IS MESSING UP WITH THIS JOIN HERE ###
## join together the data sets
Islay_field2 <- inner_join(Islay_field, Shoot_sum2, by = "FIELD_ID")
dups <- duplicated(Islay_field2$FIELD_ID)
Islay_field2 <- filter(Islay_field2, !dups)





#---------------------------------------------------------------------#
#### 5. Calculate the total area of all fields and those shot over ####
#---------------------------------------------------------------------#

## change the data set name so i don't mess anything up
Islay_FieldArea <- Islay_field2

## Calculate the area of all the fields (286278091 [m^2])
total_area <- sum(st_area(Islay_FieldArea))

## Calculate the area of fields that were shot over with lead (38471402 [m^2])
Islay_LeadArea <- filter(Islay_FieldArea, lead_shoot_int > 0)
lead_area <- sum(st_area(Islay_LeadArea))

## Calculate the % of total agricultural that have been shot with lead
(lead_area/total_area)*100

## Calculate the % of agricultural fields that have been shot over with lead
(nrow(Islay_LeadArea)/nrow(Islay_FieldArea))*100

## Calculate the density of lead shot in shooting fields, assuming a cartridge has 30g of lead
LeadWeight <- sum(Islay_LeadArea$lead_shoot_int)*(175)
(LeadWeight/lead_area)*1000000


## Calculate the number of samples collected from high intensity shooting areas
## first find the shooting intensity for the high intensity quantile
high_int <- quantile(Islay_LeadArea$lead_shoot_int, probs = 0.9)

## filter out the fields where we sampled with shooting intensities above the 90th quantile
FieldsUnique <- unique(lead$Field_Code)
sample_fields <- filter(Islay_LeadArea, FIELD_ID %in% c(FieldsUnique))
High_sample_fields <- filter(sample_fields, lead_shoot_int >= high_int)

## Now extract the sampling data for the fields above the 90th quantile
leadhigh <- filter(lead, Field_Code %in% c(High_sample_fields$FIELD_ID))
table(leadhigh$Species)





#----------------------------------------------------------------------------------------------------------------#
#### 6. Identify fields within a 1km buffer of sampling fields and calculate shooting intensity in the buffer ####
#----------------------------------------------------------------------------------------------------------------#

## extract just the fields were we sampled poo from
fields <- unique(lead$Field_Code)
sample_cents <- filter(centroids, FIELD_ID %in% c(fields))

## now extract the field codes within 1000m of these centroids
## add the buffer to the points
sample_cents_buf <- st_buffer(sample_cents, dist = 1000)

## Going to loop through each buffer and extract the relevant fields

## Create a data frame to put value into 
buff_shoot <- as.data.frame(1:length(fields))
buff_shoot$field_ID <- NA
buff_shoot$Shoot_int <- NA
buff_shoot$Shoot_int_decay <- NA

## set up the loop
for(j in 1:nrow(sample_cents_buf)){
  
  ## Add the field ID to the buff_shoot data set
  buff_shoot$field_ID[j] <- as.character(sample_cents_buf$FIELD_ID[j])
  
  ## extract fields that are within and overlap with the buffer
  buff_fields <- sf::st_overlaps(sample_cents_buf[j,], Islay_field)
  buff_fields2 <- sf::st_contains(sample_cents_buf[j,], Islay_field)
  
  ## combine all the fields in the buffer and filter any duplicates
  All_buffs <- as.vector(c(buff_fields[[1]], buff_fields2[[1]]))
  Dups <- duplicated(All_buffs)
  All_buffs <- All_buffs[Dups==F]
  
  ## now filter out the appropriate fields from the shooting data
  field_set_shoot <- Islay_field[c(All_buffs),]
  field_set_shoot2 <- filter(Shoot_sum2, FIELD_ID %in% c(as.character(field_set_shoot$FIELD_ID)))

  
  ## Assign the shooting intensity values to the right rows in the buff shoot data set
  buff_shoot$Shoot_int[j] <- sum(field_set_shoot2$lead_shoot_int, na.rm = T)
  buff_shoot$Shoot_int_decay[j] <- sum(field_set_shoot2$lead_shoot_int_decay, na.rm = T)
  
  ## Save all the fields within buffers
  if(j==1){Final_set <- field_set_shoot2}
  else{Final_set <- rbind(Final_set, field_set_shoot2)}
  
  
}


## Now join these shooting intensity values on to the data set
setnames(buff_shoot, old = "field_ID", new = "Field_Code")
lead2 <- inner_join(lead, buff_shoot, by = "Field_Code")


## write out this data set so it can be used for modeling
write_csv(lead2, file = "Outputs/LeadData_with_ShootingInt.csv")





#------------------------------------------#
#### 7. Plot Shooting intensity by year ####
#------------------------------------------#

## create a winter ID column so that I can summarse shooting by year
shoot_data_cut$year_day <- yday(shoot_data_cut$Date_Cl)
shoot_data_cut$winter <- ifelse(shoot_data_cut$year_day < 150, paste0((shoot_data_cut$year-1), "-", shoot_data_cut$year), paste0(shoot_data_cut$year, "-", (shoot_data_cut$year+1)))

## summarize Shoot_sum2 by year and shot type
Shoot_sum3 <- shoot_data_cut %>% 
              group_by(winter, RAMSAR) %>% 
              summarise(total_shots = sum(Shots_fired_Cl, na.rm = T)) %>% 
              ungroup()

## create a column with labels needed for figure legend
Shoot_sum3$Shot_type <- ifelse(Shoot_sum3$RAMSAR == 1, "Non-Lead", "Lead")

## write out this data so that Aimee can play about with the plot
#write_csv(Shoot_sum3, file = "~/PhD Documents/2_Lead + Shooting/Lead Feacal Analysis/shot_by_year.csv")

## plot total number of shots by year for lead and non-lead shot
ggplot(data = Shoot_sum3) + 
  geom_point(aes(x=winter, y=total_shots, colour = Shot_type), size =2, shape =4) + 
  geom_line(aes(x=winter, y=total_shots, colour = Shot_type), size = 1.25) +
  ylab("Total No of shots fired") + xlab("Winter") +
  theme_bw() +
  labs(colour="Shot type", linetype ="Shot type") +
  scale_x_continuous(n.breaks = 8) +
  theme(panel.grid.major.y = element_blank(), panel.grid.minor.y = element_blank(), panel.grid.major.x = element_blank(),
        axis.text=element_text(size=11, face = "bold"), axis.title=element_text(size=17, face = "bold"), 
        plot.title = element_text(size=14, face="bold"), legend.text=element_text(size=12), legend.title=element_text(size=12),
        panel.grid.minor.x = element_blank(), strip.text.x = element_text(size = 13, face = "bold"))


