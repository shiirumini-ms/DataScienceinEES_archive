##Linear Models 2 - Generlised and Mixed Effects Linear Models (aka GLMs, LMMs and GLMMs)
##A worksheet for Data Science. Written by Hannah Wauchope
##22nd Oct, 2025

##Install Packages (only run once)
remotes::install_github("timnewbold/StatisticalModels")
install.packages("DHARMa")

#Load Libraries
library(DHARMa)
library(StatisticalModels)
library(tidyverse)
library(lme4)
library(ggeffects)

#Load Data
Humming <- read.csv("weekly_materials/week_06/data/HummingBirds.csv")

#### Exercise 1 - Visualise #### 
unique(Humming$Species)
unique(Humming$Site)
#We have 6 species, in 3 countries (USA, Mexico, Guatemala)

#### Exercise 2 - Data Prep #### 
Humming$YearScale <- Humming$Year - min(Humming$Year) 

#### Exercise 3 - Build a GLM #### 
Mod1 <- glm(Count ~ YearScale, family="poisson", data=Humming)

#TEST
Mod5 <- glmmTMB(Count ~ YearScale, family="poisson", data=Humming)


#### Exercise 4 - Understanding GLM output #### 
summary(Mod1)
#Year Coefficient = 0.01

#### Exercise 5 - Year Coefficient interpretation #### 
exp(0.0127)
#By a proportion of 1.01

#### Exercise 5 continued
exp(0.0127)
#According to this GLM, every year, Hummingbird count will increase by 1.2% on average

#### Exercise 6 - Check GLM Variance #### 
(4654.5-4582.3)/4654.5

#### Exercise 6 continued
#1.6%, oh dear

#### Exercise 7 - Check GLM Assumptions #### 
simulateResiduals(fittedModel = Mod1, plot = T)

#### Exercise 8 - The other variables #### 
ggplot(Humming, aes(x=Year, y=Count))+
  geom_point()+
  facet_grid(Species~Site, scales="free")+
  theme_classic()


#### Exercise 9 - Build a GLMM #### 
# Response Variable: Count
# Categorical Predictor (i.e. Categorical Fixed Effect): Site
# Continuous Predictor (i.e. Continuous Fixed Effect): YearScale
# Categorical Random Effect: Species

#### Exercise 9 continued
# 5 to both!

#### Exercise 9 continued
Mod2 <- glmer(Count ~ YearScale + Site + (1|Species), family="poisson", data=Humming)

#### Exercise 10 - Check GLMM Assumptions #### 
simulateResiduals(fittedModel = Mod2, plot = T)

#### Exercise 11 - Check GLMM Variance #### 
R2GLMER(Mod2)

#### Exercise 11 continued
R2GLMER(Mod2)
#Conditional: YearScale and Site and Species explain 49% of the variance.  
#Marginal: YearScale and Site explain 25% of the variance
#This means that Species explain 24% of the variance
#Given that in Exercise 6 we were explaining 1% of the variance, we're doing a LOT better!

#### Exercise 12 - Finally Answer the Question #### 
plot(ggpredict(Mod2, c("YearScale", "Site")))

#### Exercise 12 continued
summary(Mod2)
#Year coefficient is 0.0075. 
exp(0.007535) # Is 1.0075
#In other words, our model says on average Hummingbirds are increasing by 0.7% per year

#### Exercise 12 continued
#Arizona A

#### Exercise 12 continued
#Y intercept for Arizona A is the (Intercept) Estimate
exp(0.9207) # 2.51
#There are an average of 2.51 (Let's round to 3) Humminbirds in Arizona A

#### Exercise 12 continued
#When YearScale = 0, Actual Year = 1957

#### Exercise 12 continued
exp(0.920746 + 2.094611)
#20.39
#There are avg 20 Hummingbirds in the Guatemala Site in 1957
