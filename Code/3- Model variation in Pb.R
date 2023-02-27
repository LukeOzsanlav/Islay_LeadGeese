## Luke Ozsanlav-Harris

## Model variation in fecal lead concentrations
## Need mixed effects model to control for the non-independence between flocks

## packages required
library(tidyverse)
library(data.table)
library(lme4)
library(effects)
library(nlme)
library(DHARMa)
library(ggeffects)




#--------------------------------#
#### 1.  Read in the data set ####
#--------------------------------#

## read in the lead data with field codes and shooting intensity
lead <- fread("Outputs/LeadData_with_ShootingInt.csv")




#----------------------------------#
#### 2.  Models variation in Pb ####
#----------------------------------#

#------------------------#
#### 2.1 PREPARE DATA ####
#------------------------#

## run normal linear model with species interaction
## check distribution of response variable
hist(lead$Pb)
hist(log(lead$Pb))

## extract the farm from the field ID
lead$farm_code <- substr(lead$Field_Code, start = 1, stop = 2)

## set species as a two level factor
lead$Species <- ifelse(lead$Species == "D10", "GBG", lead$Species)
lead$Species <- factor(lead$Species, levels = c("GWFG", "GBG"), ordered = F)

## standardize the continuous predictors
lead$Al_sc <- scale(lead$Al)
lead$Shoot_int_sc <- scale(lead$Shoot_int)




#------------------------------#
#### 2.2 LINEAR MIXED MODEL ####
#------------------------------#

## run the linear model
## field code and farm code as nested random effects
modelint <- lmer(log(Pb) ~ log(Al) * Species + Shoot_int_sc + (1|farm_code/Field_Code), 
                 control=lmerControl(optimizer="bobyqa",
                                     optCtrl=list(maxfun=2e5)),
                 data = lead, 
                 REML = F)

## check model
summary(modelint)
plot(modelint)




#------------------------#
#### 2.3 MODEL CHECKS ####
#------------------------#

## check for heteroscadisity, 
modeltest <- lm(log(Pb) ~ log(Al) * Species + Shoot_int_sc, data = lead)
lmtest::bptest(modeltest) # test is significant

## Run model in nlme now as this allows you you account for changing varience
ModelNOhetro <- lme(log(Pb) ~ log(Al) * Species + Shoot_int_sc, 
                  random = ~ 1 | farm_code/Field_Code,
                  data = lead, 
                  method = "ML")
ModelhetroEXP <- lme(log(Pb) ~ log(Al) * Species + Shoot_int_sc, 
                  random = ~ 1 | farm_code/Field_Code,
                  weights = varExp(form= ~ log(Al)),
                  data = lead, 
                  method = "ML")
ModelhetroPOW <- lme(log(Pb) ~ log(Al) * Species + Shoot_int_sc, 
                  random = ~ 1 | farm_code/Field_Code,
                  weights = varPower(form= ~ log(Al)),
                  data = lead, 
                  method = "ML")

## rank the three models with AIC
AIC(ModelNOhetro);AIC(ModelhetroEXP); AIC(ModelhetroPOW) # varPower was best model, doesn't make it that much better
plot(ModelhetroPOW)




#---------------------------#
#### 2.4 MODEL INFERENCE ####
#---------------------------#

## Run model selection
## change default "na.omit" to prevent models being fitted to different datasets
options(na.action = "na.fail") 

## create all candidate models using dredge, specify any dependencies (trace shows progress bar)
## change to rank by AIC due to reviewer comment from IBIS
ms2 <- MuMIn::dredge(ModelhetroPOW, trace = 2, rank = "AIC")
ms2_sub <- subset(ms2, !MuMIn::nested(.), recalc.weights=T)

## run the top model now to obtain parameter estimates
modeltop <- lme(log(Pb) ~ log(Al), 
                random = ~ 1 | farm_code/Field_Code,
                weights = varPower(form= ~ log(Al)),
                data = lead, 
                method = "ML")
summary(modeltop)
drop1(modeltop, test = "Chisq")
performance::model_performance(modeltop)




#--------------------------------------#
#### 3. Plot the output of the model####
#--------------------------------------#

## extract the fitted values plus CIs using the effects package
effectz <- effects::effect(term= "log(Al)", mod= modeltop, xlevels= 200, se=list(level = 0.95))
effectz2 <- as.data.frame(effectz)

## transform back the estimates as the data was logged in the model
effectz2$fit <- exp(effectz2$fit) 
effectz2$lower <- exp(effectz2$lower) 
effectz2$upper <- exp(effectz2$upper) 


## create the plot
ggplot() + 
  geom_point(data=lead, aes(x=Al, y=Pb, colour = Species), size =1.8, shape = 21, stroke =1.5) + 
  geom_line(data=effectz2, aes(x= Al, y = fit), size = 1.25, colour = "black")  +
  geom_ribbon(data = effectz2, aes(x=Al, ymin = lower, ymax = upper), alpha = 0.4, colour = NA, fill = "grey") + 
  ylab("Pb (mg/kg of dry faeces)") + xlab("Al (mg/kg of dry faeces)") +
  theme_bw() +
  scale_colour_manual(values=c("#D55E00", "#0072B2")) +
  geom_text(data = lead, aes(x=Al, y=Pb, label=ifelse(Pb > 12 & Al < 5000, round(Pb, digits = 1),'')),hjust=0.5, vjust=-0.6, size = 5) +
  theme(panel.grid.major.y = element_blank(), panel.grid.minor.y = element_blank(), 
        axis.text=element_text(size=13), axis.title=element_text(size=17, face = "bold"), 
        plot.title = element_text(size=14, face="bold"), legend.text=element_text(size=12), legend.title=element_text(size=12),
        panel.grid.minor.x = element_blank(), strip.text.x = element_text(size = 13, face = "bold"))

# ## save the plot
# setwd("~/PhD Documents/2_Lead + Shooting/Paper plots 17-01-22")
# ## Save a plot
# ggsave("Figure 5- PB vs Al.png", 
#        width = 25, height = 22, units = "cm")




#---------------------------------------------------------------------------#
#### 4. Fischer exact test to look at outlier rates between GBG and GWfG ####
#---------------------------------------------------------------------------#

## create table for chi squared test and run test
## This is for the fecal sample anlaysis only
chi.data <- table(lead$Species, c(rep(1, times = nrow(lead)/2), rep(0, times = nrow(lead)/2)))
print(chi.data)
print(fisher.test(chi.data))

##now run one where I input the values myself from all three data sets (x-ray, post mortem and faecal)
chi.data[2,] <- c(483,5)
chi.data[1,] <-c(260,6)
print(chi.data)
print(fisher.test(chi.data))




#---------------------------------------------------------------------------------#
#### 5. Plot model output with 95% prediction interval and Confidence interval ####
#---------------------------------------------------------------------------------#

## creates columns with logged Pb and Al
## need to do this as the ggeffects package does not like logging variables in the model formula
lead2 <- lead
lead2$logPb <- log(lead2$Pb)
lead2$logAl <- log(lead2$Al)

## run the top model again now with the nw variables
modeltop <- lme(logPb ~ logAl, 
                random = ~ 1 | farm_code/Field_Code,
                weights = varPower(form= ~ log(Al)),
                data = lead2, 
                method = "ML")
## or run with gamma model here

## create 95% Prediction and confidence intervals with the ggeffects packae
max(lead2$logAl);min(lead2$logAl)
ggPredsCI <- ggpredict(model = modeltop, terms = "logAl [4.63:9.41, by = 0.02]")
ggPredsPI <- ggpredict(model = modeltop, terms = "logAl [4.63:9.41, by = 0.02]", type = "random") # specifying type = "random" is equivalent to prediction intervals, see short techinal note section: https://strengejacke.github.io/ggeffects/articles/ggeffects.html 

## add the standard error for the PI to the other data set
ggPredsCI$PI_ster <- ggPredsPI$std.error

## convert these variables back to the data scale, i.e. not log(Pb) scale
ggPredsCI$x <- exp(ggPredsCI$x) 
ggPredsCI$predicted <- exp(ggPredsCI$predicted) 
ggPredsCI$conf.low <- exp(ggPredsCI$conf.low)
ggPredsCI$conf.high <- exp(ggPredsCI$conf.high)

## now calculate the prediction intervals
ggPredsCI$pred.high <- ggPredsCI$predicted+1.96*exp(ggPredsCI$PI_ster)
ggPredsCI$pred.low <- ggPredsCI$predicted-1.96*exp(ggPredsCI$PI_ster)


## plot the final output
ggplot(ggPredsCI, aes(x=x,y=predicted)) + 
geom_point(data=lead, aes(x=Al, y=Pb, colour = Species), size =1.8, shape = 21, stroke =1.5) +
geom_line(size = 1.25, colour = "black") +
geom_ribbon(aes(ymin=conf.low, ymax=conf.high),alpha = 0.5, colour = NA, fill = "grey") +
geom_ribbon(aes(ymin=pred.low, ymax=pred.high),alpha = 0.3, colour = NA, fill = "grey") +
ylab("Pb (mg/kg of dry faeces)") + xlab("Al (mg/kg of dry faeces)") +
theme_bw() +
coord_cartesian(ylim=c(0,25)) +
scale_colour_manual(values=c("#D55E00", "#0072B2")) +
geom_text(data = lead, aes(x=Al, y=Pb, label=ifelse(Pb > 12 & Al < 5000, round(Pb, digits = 1),'')),hjust=0.5, vjust=-0.6, size = 3.3) +
theme(panel.grid.major.y = element_blank(), panel.grid.minor.y = element_blank(), 
        axis.text=element_text(size=13), axis.title=element_text(size=16), 
        plot.title = element_text(size=14, face="bold"), legend.text=element_text(size=12), legend.title=element_text(size=12),
        panel.grid.minor.x = element_blank(), strip.text.x = element_text(size = 12))

## save the plot
#setwd("~/PhD Documents/2_Lead + Shooting/Paper plots 17-01-22")
## Save a plot
ggsave("Outputs/Plots/Fig 6-Pb vs Al with prediction interval.png", 
       width = 25, height = 22, units = "cm")

