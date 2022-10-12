###############################################################
#### PhD Chapter: Unobserved consequences of shooting      ####
####                Faecal lead                            ####
####          Start Date: 28/08/2020                       #### 
####  R version 4.0.2 (2020-06-22) -- "Taking Off Again"   ####
###############################################################

##### Updated: 12/10/2020 #######


## LIBRARIES 
library(dplyr) # Manipulating data
library(tidyr) # Formatting for analysis
library(tidyverse) #
library(readr) # Manipulating data
library(ggplot2) # Plotting data/results
library(lubridate)


## Read in data for shooting intensity over time
shot <- read.csv("Data/PlotData/shot_by_winter.csv")
head(shot)
shot$winter <- as.factor(shot$winter)
shot$RAMSAR <- as.factor(shot$RAMSAR)
shot$total_shots <- as.numeric(shot$total_shots)


## make the plot
ggplot(data = shot, aes(x = Winter_year, y = total_shots, group = Shot_type, colour = Shot_type)) +
  geom_point(aes(), size = 2) +
  geom_line(aes()) +
  labs(x = " Winter", y = "Total number of shots fired", colour = "Shot type")+
  scale_x_continuous(limits = c(2005, 2018),breaks = seq(2005,2018, by = 2)) +
  scale_y_continuous(limits = c(0, 4000), breaks = seq(0,4000, by = 500)) +
  scale_color_manual(values = c("red","black")) +
  theme_bw()+ 
  theme(panel.grid.major.y = element_blank(), panel.grid.minor.y = element_blank(), panel.grid.major.x = element_blank(), 
        axis.text=element_text(size=18), axis.title=element_text(size=22),
        plot.title = element_text(size=18, face="bold"), legend.text=element_text(size=18), legend.title=element_text(size=22),
        panel.grid.minor.x = element_blank(), strip.text.x = element_text(size = 18))

## save output
ggsave("Outputs/Plots/Fig 1-Total number of lead and non-lead cartridges fired.png", 
       width = 28, height = 22, units = "cm")





## Read in data for GBG hunting mortality over time
shoot_history <- read.csv("Data/PlotData/Shooter_hist.csv")
str(shoot_history)
shoot_history$Shoot_total <- as.numeric(shoot_history$Shoot_total)

## make the plot
ggplot(data = shoot_history, aes(x = Year, y = Shot_Total, group = Shooter, colour = Shooter)) +
  geom_point(aes(), size = 2) +
  geom_line(aes()) +
  labs(x = " Winter", y = "Total number of geese killed", colour = "Shooter")+
  scale_x_continuous(limits = c(2012, 2018),breaks = seq(2012,2018, by = 1)) +
  scale_y_continuous(limits = c(0,3300), breaks = seq(0,3300, by = 300)) +
  scale_color_manual(values = c("orange","darkblue")) +
  theme_bw() +
  theme(panel.grid.major.y = element_blank(), panel.grid.minor.y = element_blank(), panel.grid.major.x = element_blank(), 
        axis.text=element_text(size=18), axis.title=element_text(size=22),
        plot.title = element_text(size=18, face="bold"), legend.text=element_text(size=18), legend.title=element_text(size=22),
        panel.grid.minor.x = element_blank(), strip.text.x = element_text(size = 18))

## save the plot as PNG
ggsave("Outputs/Plots/Fig 3-The number of Barnacle Geese killed .png", 
       width = 28, height = 22, units = "cm")
