## Luke Ozsanlav-Harris

## create a distribution of the percentage of birds exposed to lead within a single winter
## Simulate retention time from a poisson distribution

## packages required
library(ggplot2)


## These are the proportion of bird that we identified shot in
GBG_prev <- (5/482)
GWfG_prev <- (6/260)



#-------------------------------#
#### RUN FOR 20 DAYS AVERAGE ####
#-------------------------------#

## create sample of retention time
set.seed(121)
retention <- rpois(1000,20) # need to stop this going below zero
hist(retention) # histogram of retention times
max(retention) # max value, Should be about 36

## Now work out the multiplication factor
## 150 is the number of days in a winter period
factor <- 150/retention

## Now extrapolate up the instantaneous prevalence rate for a whole winter
## the factor is a power here to account for the fact that some individuals will ingest lead twice
GBG_exposure <- (1-(1-(GBG_prev))^(factor))*100
GWfG_exposure <- (1-(1-(GWfG_prev))^(factor))*100

## Calculate the mean and sd of retention times
mean(GBG_exposure);sd(GBG_exposure)
mean(GWfG_exposure);sd(GWfG_exposure)

## make into a data frame for plotting
GBG_exposure <- as.data.frame(GBG_exposure)
colnames(GBG_exposure) [1] <- "Exposure"
GBG_exposure$Species <- "GBG"
GBG_exposure$col <- "#D55E00"
GWfG_exposure <- as.data.frame(GWfG_exposure)
colnames(GWfG_exposure) [1] <- "Exposure"
GWfG_exposure$Species <- "GWfG"
GWfG_exposure$col <- "#0072B2"
All_exposure <- rbind(GBG_exposure, GWfG_exposure)


## Now plot the distributions
ggplot(data = All_exposure) +
  geom_histogram(aes(Exposure, fill = Species), binwidth = 2, colour = "white") +
  facet_wrap(~Species) +
  theme_bw() +
  xlab("Percentage of individuals ingesting shot") + ylab("Count") + 
  scale_fill_manual(values=c("#0072B2", "#D55E00")) +
  scale_x_continuous(breaks = seq(0,35, 5)) +
  theme(panel.grid.major.y = element_blank(), panel.grid.minor.y = element_blank(), 
        axis.text=element_text(size=18), axis.title=element_text(size=22),
        plot.title = element_text(size=18, face="bold"), legend.text=element_text(size=18), legend.title=element_text(size=22),
        panel.grid.minor.x = element_blank(), strip.text.x = element_text(size = 18)) # +
  # geom_text(data = data.frame(x = 28, y = 410, label = "λ = 20", Species = "GWfG"), 
  #           aes(x = x, y = y, label = label), size = 8)

## save the ggplot
ggsave("Outputs/Plots/Fig 7-Percentage of individuals ingesting lead over a winter.png", 
       width = 28, height = 22, units = "cm")




#-------------------------------#
#### RUN FOR 12 DAYS AVERAGE ####
#-------------------------------#

## create sample of retention time
set.seed(121)
retention <- rpois(1000,12) # need to stop this going below zero
hist(retention) # histogram of retention times
max(retention) # max value, Should be about 36

## Now work out the multiplication factor
## 150 is the number of days in a winter period
factor <- 150/retention

## Now extrapolate up the instantaneous prevalence rate for a whole winter
## the factor is a power here to account for the fact that some individuals will ingest lead twice
GBG_exposure <- (1-(1-(GBG_prev))^(factor))*100
GWfG_exposure <- (1-(1-(GWfG_prev))^(factor))*100

## Calculate the mean and sd of retention times
mean(GBG_exposure);sd(GBG_exposure)
mean(GWfG_exposure);sd(GWfG_exposure)

## make into a data frame for plotting
GBG_exposure <- as.data.frame(GBG_exposure)
colnames(GBG_exposure) [1] <- "Exposure"
GBG_exposure$Species <- "GBG"
GBG_exposure$col <- "#D55E00"
GWfG_exposure <- as.data.frame(GWfG_exposure)
colnames(GWfG_exposure) [1] <- "Exposure"
GWfG_exposure$Species <- "GWfG"
GWfG_exposure$col <- "#0072B2"
All_exposure <- rbind(GBG_exposure, GWfG_exposure)


## Now plot the distributions
ggplot(data = All_exposure) +
  geom_histogram(aes(Exposure, fill = Species), binwidth = 5, colour = "white") +
  facet_wrap(~Species) +
  theme_bw() +
  xlab("Percentage of individuals ingesting shot") + ylab("Count") + 
  scale_fill_manual(values=c("#0072B2", "#D55E00")) +
  scale_x_continuous(breaks = seq(0,90, 5)) +
  theme(panel.grid.major.y = element_blank(), panel.grid.minor.y = element_blank(), 
        axis.text=element_text(size=13), axis.title=element_text(size=16), 
        plot.title = element_text(size=14, face="bold"), legend.text=element_text(size=12), legend.title=element_text(size=12),
        panel.grid.minor.x = element_blank(), strip.text.x = element_text(size = 12)) +
  geom_text(data = data.frame(x = 62, y = 510, Species = "GWfG", label = "λ = 12"), 
            aes(x = x, y = y, label = label), size = 6)







#-------------------------------#
#### RUN FOR 35 DAYS AVERAGE ####
#-------------------------------#

## create sample of retention time
set.seed(121)
retention <- rpois(1000,35) # need to stop this going below zero
hist(retention) # histogram of retention times
max(retention) # max value, Should be about 36

## Now work out the multiplication factor
## 150 is the number of days in a winter period
factor <- 150/retention

## Now extrapolate up the instantaneous prevalence rate for a whole winter
## the factor is a power here to account for the fact that some individuals will ingest lead twice
GBG_exposure <- (1-(1-(GBG_prev))^(factor))*100
GWfG_exposure <- (1-(1-(GWfG_prev))^(factor))*100

## Calculate the mean and sd of retention times
mean(GBG_exposure);sd(GBG_exposure)
mean(GWfG_exposure);sd(GWfG_exposure)

## make into a data frame for plotting
GBG_exposure <- as.data.frame(GBG_exposure)
colnames(GBG_exposure) [1] <- "Exposure"
GBG_exposure$Species <- "GBG"
GBG_exposure$col <- "#D55E00"
GWfG_exposure <- as.data.frame(GWfG_exposure)
colnames(GWfG_exposure) [1] <- "Exposure"
GWfG_exposure$Species <- "GWfG"
GWfG_exposure$col <- "#0072B2"
All_exposure <- rbind(GBG_exposure, GWfG_exposure)


## Now plot the distributions
ggplot(data = All_exposure) +
  geom_histogram(aes(Exposure, fill = Species), binwidth = 1, colour = "white") +
  facet_wrap(~Species) +
  theme_bw() +
  xlab("Percentage of individuals ingesting shot") + ylab("Count") + 
  scale_fill_manual(values=c("#0072B2", "#D55E00")) +
  scale_x_continuous(breaks = seq(0,35, 5)) +
  theme(panel.grid.major.y = element_blank(), panel.grid.minor.y = element_blank(), 
        axis.text=element_text(size=13), axis.title=element_text(size=16), 
        plot.title = element_text(size=14, face="bold"), legend.text=element_text(size=12), legend.title=element_text(size=12),
        panel.grid.minor.x = element_blank(), strip.text.x = element_text(size = 12)) +
  geom_text(data = data.frame(x = 17, y = 410, label = "λ = 35", Species = "GWfG"), 
            aes(x = x, y = y, label = label), size = 6)



