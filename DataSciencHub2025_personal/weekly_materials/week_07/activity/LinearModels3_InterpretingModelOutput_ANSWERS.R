##Linear Models 3 - Interpreting Model Output
##A worksheet for Data Science. Written by Hannah Wauchope
##29th Oct, 2025

#Load Libraries
library(tidyverse)
library(data.table)
library(lme4)
library(DHARMa)
library(ggeffects)
library(stargazer)
library(StatisticalModels)
library(performance)

#Load Data
Falcon <- read.csv("/week_07/data/Falcons.csv")

#### Exercise 1 - Visualise Data ----
(PlotFalconData <- ggplot(Falcon, aes(x=Year, y=Count))+
    geom_point()+
    facet_grid(Species ~ Site)+
    theme_classic())

Falcon$YearScale <- Falcon$Year - min(Falcon$Year)

PlotFalconData

#### Exercise 2 - Model ----
Mod1 <- glm(Count ~ YearScale, data=Falcon, family ="poisson")
simulateResiduals(Mod1, plot=T)

#The residuals good enough, imo. There's quite a lot of wiggle on the first plot (means the data isn't following a poisson distribution suuuper well). 
#Second one could be worse! There's some residuals that aren't dispersed well, but the thick lines are at least near the dashed lines.

# run vignette("DHARMa", package="DHARMa") for (much) info if you're interested!

#### Exercise 3 - Plot ----
plot(ggpredict(Mod1, c("YearScale")))

#### Exercise 4 - Intercept Estimates ----
summary(Mod1)

exp(0.617916) #= 1.9, so roughly 2 falcons. Estimate taken from the intercept line of the summary

exp(confint(Mod1))
#Intervals are 1.6 to 2.2

#### Exercise 5 - Year Slope Estimates ----
exp(0.031780) #= 1.032 So the population is increasing by 3.2% per year (we measure relative to 1. 1 means no change, 1.01 means 1% increase, 0.99 means 1% decreaase etc)

exp(confint(Mod1))
#Population increase is somwhere between 2.6 and 3.8% per year

#### Exercise 6 - Accounting for groups ----
#Our groups are Site and Species

#Given all that, that means I would like a generalised linear mixed effects model. 
#As in the previous exercise, we need to specify a poisson family. 
#We will have two 'fixed effect' predictors, one continuous: YearScale, and one categorical: Site. 
#We will have one random effect, Species. 

#### Exercise 7 - Build GLMM ----
Mod2 <- glmer(Count ~ YearScale + Site + (1|Species), data=Falcon, family ="poisson")
simulateResiduals(Mod2, plot = T)
R2GLMER(Mod2) #This is from the statistical models r package

#I'd say we've met the assumptions similarly to the last model! 
#But we know Falcons vary by site from looking at the plot (slash, our common sense), 
#so still the right call to include it in the model. 
#We have explained more variance in the model according to the R2

#### Exercise 8 - Visualise GLMM ----
plot(ggpredict(Mod2, terms=c("YearScale", "Site")))

summary(Mod2)

exp(0.417181) #Taken from (Intercept) estimate. 1.5 falcons in year 0 in Belize1
exp(0.020285) #Taken from YearScale estimate. Population is increasing by 2% per year

exp(0.417083 + 0.083827) #Intercept plus Belize 2 estimate. 1.7 Falcons in year 0 in Belize2, but this isn't significantly different from Belize 1
exp(0.020285) #It's the same! Populations increasing by 2% per year

#### Exercise 9 - Check Model Representation of Data (WWF REPORT HINT) ----
FitDat <- data.frame(ggpredict(Mod2, terms=c("YearScale", "Site"), type="re")) %>%
  rename(Site = group, YearScale=x, Count = predicted)

(PlotRibbons <- ggplot()+
    geom_ribbon(data=FitDat, aes(x=YearScale, ymin = conf.low, ymax=conf.high), alpha=0.2)+
    geom_point(data=Falcon, aes(x=YearScale, y=Count, group=Species, colour=Species))+
    geom_line(data=FitDat, aes(x=YearScale, y=Count))+
    facet_wrap(. ~ Site, scales="free")+
    theme_classic()+
    theme(text=element_text(size=8)))

#### Exercise 10 - Model with Interaction ----
Mod3 <- glmer(Count ~ YearScale*Site + (1|Species), data=Falcon, family ="poisson")
#Don't worry about the warning, she happens sometimes
plot(simulateResiduals(Mod3, plot = T)) 
#Oof. Confusingly our assumption plots look a bit worse. 
#This is a good learning moment - we *know*, from our knowledge of the system, that populations behave differently between different sites. 
#And we could see it in the data. The models happened to meet assumptions better before, but its because we were kind of lying to them about the true structure of our data. 
#So we shouldn't use those other models, we just need to accept that our data isn't perfect for modelling as it doesn't meet assumptions.

R2GLMER(Mod3) #We are explaining more of the variance though

#If you're a 4th Year EES student you will also be familiar with AIC comparisons. 
#Compare the AIC of this Model and the one before - which one explains the data better? (Remembering lower AICs are better)

summary(Mod3)

#### Exercise 11 - Interaction Output ----
exp(0.248084) #1.3 falcons in Belize in Year 0
exp(0.027235) #The falcon population in Belize 1 increases by 2.7% per year

#### Exercise 12 - Interaction Output Pt 2 ----
exp(0.248084 + 0.362630) #We add the intercept and the Mexico 1 intercepts together. 1.8 falcons in Year 0 in Mexico.
exp(0.027235 + -0.073177) #And now, because we've interacted Year and Site, we have a adjustment to the year estimate for Mexico 1. It's below 1!! This means Falcons in Mexico 1 are declining by 4.5%. (1-0.955 = 0.045 = 4.5%)

#### Exercise 13 - Interaction Output Pt 3 ----
FitDat <- data.frame(ggpredict(Mod3, terms=c("YearScale", "Site"), type="re")) %>%
  rename(Site = group, YearScale=x, Count = predicted)

(PlotRibbons <- ggplot()+
    geom_ribbon(data=FitDat, aes(x=YearScale, ymin = conf.low, ymax=conf.high), alpha=0.2)+
    geom_point(data=Falcon, aes(x=YearScale, y=Count, group=Species, colour=Species))+
    geom_line(data=FitDat, aes(x=YearScale, y=Count))+
    facet_wrap(. ~ Site, scales="free")+
    theme_classic()+
    theme(text=element_text(size=8)))

#### Extension 1 - Random Slopes ----
Mod4 <- glmer(Count ~ YearScale*Site + (YearScale|Species), data=Falcon, family ="poisson")
#Don't worry about the warning, she happens sometimes, Extension 2 explains why
simulateResiduals(Mod4, plot = T)
R2GLMER(Mod4)

summary(Mod4)

FitDat <- data.frame(ggpredict(Mod4, terms=c("YearScale", "Site", "Species"), type="re")) %>%
  rename(Site = group, Species = facet, YearScale=x, Count = predicted)

ggplot()+
  #geom_ribbon(data=FitDat, aes(x=YearScale, ymin = conf.low, ymax=conf.high, group = Species, fill=Species), alpha=0.2)+
  geom_point(data=Falcon, aes(x=YearScale, y=Count, group=Species, colour=Species))+
  geom_line(data=FitDat, aes(x=YearScale, y=Count, group=Species, colour=Species))+
  facet_wrap(. ~ Site, scales="free")+
  theme_classic()

#### Extension 2 - Patchy Data ----
PlotFalconData

FalconSmall <- Falcon %>% filter(!Species %in% c("Orange-breasted Falcon", "Prairie Falcon"))

Mod6 <- glm(Count ~ YearScale*Site + Species, data=FalconSmall, family ="poisson") #Note we can't make species a random factor now as there are less that 5 groups. So it becomes a fixed effect, and our model becomes a glm
simulateResiduals(Mod6, plot = T)
r2_mcfadden(Mod6)
summary(Mod6)
plot(ggpredict(Mod6, terms=c("YearScale", "Species", "Site")), show_data=TRUE)

#WOW our assumptions plots look WAY better, and our confidence intervals are way down. As a final extension for you to ponder - why are Belize 2's confidence intervals so high?

#A philosophical question then... should we ever have tried to model all the falcons? Or should we have filtered the data immediately? It depends what we were hoping to say with our model and how broad we wanted our conclusions to be...

