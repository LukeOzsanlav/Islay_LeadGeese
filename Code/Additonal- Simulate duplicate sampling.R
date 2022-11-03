## Luke Ozsanlav-Harris
## This code tries to replicate our fecal sampling process with a simulation
## We then calcualte the number of duplicate samples we are likely to have collected

## packages required
pacman::p_load(tidyverse, svMisc)




#------------------------#
#### INPUT PARAMETERS ####
#------------------------#

Pop_size <- 33000 # size of the total population sampled (GBG Isaly population size)
Flock_size <- 540 # the average flock size from which each round of sampling is conducted
Perc_movement <- 10 # the percentage of birds that move from one flock to another in between each sampling round
Samps_collected <- 4 # the number of samples collected in each round of sampling
Samp_rounds <- 180/Samps_collected # the total number of sampling rounds to be conducted
n_sims <- 1000 # number of simulations to run




#-------------------------#
#### SET UP SIMULATION ####
#-------------------------#

## create data frame to put all of the simulation outputs in
Output <- as.data.frame(c(1:n_sims))
Output$sample <- NA

## create the simulated population of birds
birds <- c(1:Pop_size)




#----------------------#
#### RUN SIMULATION ####
#----------------------#

set.seed(1212) # make simualtion repeatable
for(j in 1:n_sims){
  
  svMisc::progress(j, max.value = n_sims)
  
  ## loop through each round of sampling, in each round `Samps_collected` number of samples are collected
  for(i in 1:Samp_rounds){
    
    ## This if else statement allows birds from the previous round of sampling to be included in the current flock that is sampled
    if(i==1){samp <- sample(birds, size = Flock_size, replace = FALSE)}else{
      movers <- sample(samp, size = (Flock_size*(Perc_movement/100)), replace = FALSE)
      NewFlock <- sample(birds, size = (Flock_size-(Flock_size*(Perc_movement/100))), replace = FALSE)
      samp <- c(movers, NewFlock)
    }
    
    ## take samples from the current flock
    poos <- sample(samp, size = Samps_collected, replace = TRUE)
    
    ## Join all the samples together for each iteration of the i loop
    if(i==1){poops <- poos}else{poops <- c(poops,poos)}
    
  }
  
  ## determine if we have any duplicates in our sample
  dups <- duplicated(poops)
  
  ## calculate the number of duplicates and then save to a data frame
  Output$sample[j] <- length(dups[dups==TRUE])
  
}


## the percentage of duplicates 
## top row is the number of duplicate samples collected from the same individual
## the bottom row is the percentage of the simulations that had the given number of duplciations
table(Output$sample)/(n_sims/100)







