## Luke Ozsanlav-Harris

## create a distribution of the percentage of birds exposed to lead within a single winter
## Simulate retention time from a poisson distribution

## packages required
library(ggplot2)


## These are the proportion of bird that we identified shot in
GBG_prev <- (6/482)
GWfG_prev <- (6/260)


## create sample of retention time
set.seed(121)
retention <- rpois(1000,20) # need to stop this going below zero
hist(retention) # histogram of retention times
max(retention) # max value, Should be about 36


## Now work out the multiplication factor
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
  geom_histogram(aes(Exposure, fill = Species), binwidth = 2.5, colour = "white") +
  facet_wrap(~Species) +
  theme_bw() +
  xlab("Percentage of individuals ingesting shot") + ylab("Count") + 
  scale_fill_manual(values=c("#0072B2", "#D55E00")) +
  scale_x_continuous(breaks = seq(0,35, 5)) +
  theme(panel.grid.major.y = element_blank(), panel.grid.minor.y = element_blank(), 
        axis.text=element_text(size=13), axis.title=element_text(size=16), 
        plot.title = element_text(size=14, face="bold"), legend.text=element_text(size=12), legend.title=element_text(size=12),
        panel.grid.minor.x = element_blank(), strip.text.x = element_text(size = 12))

## save the ggplot
setwd("~/PhD Documents/2_Lead + Shooting/Lead Feacal Analysis")
ggsave("Percentgae of inddividuals ingesting lead over a winter.png", 
       width = 28, height = 22, units = "cm")
