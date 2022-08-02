## Luke Ozsanlav-Harris

## Create plot of faecal sampling locations

## packages required
library(tidyverse)
library(data.table)





#------------------------------------#
#### 1. Read in the data required ####
#------------------------------------#

## read in the lead lab analysis data
lead <- fread("Data/Lead lab analysis.csv")

## read in the field codes where each smaple was collected
GWfG_data <- fread("Data/GWfG sampling locations.csv")
GBG_data <- fread("Data/GBG sampling locations.csv", header = T)

## read in the locations of field centroids
field_centres <- fread("Data/Field centroids.csv", header = T)





#----------------------------------------------------#
#### 2. Combine all of the data sets for plotting ####
#----------------------------------------------------#

## Combine the meta data from me and Aimee with the field codes in

## select the column needed
GWfG_fields <- GWfG_data %>% select(c("Sample Code", "Date", "Field Code"))
GBG_fields <- GBG_data %>% select(c("Sample", "Date", "Field_Code"))

## changes the col names in one data set so that they bind together
setnames(GWfG_fields, old = c("Sample Code", "Field Code"), new = c("Sample", "Field_Code"))

## bind the two data sets together
All_fields <- plyr::rbind.fill(GWfG_fields, GBG_fields)


## now join these field codes onto the lead data
lead2 <- inner_join(lead, All_fields, by = c("Sample", "Date"))
stopifnot(nrow(lead)==nrow(lead2))

## read out this dataset of the lead data with the field codes
write_csv(lead2, file = "Outputs/LeadData_with_FieldCodes.csv")


