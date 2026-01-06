# In-class activity For Week 7
# Written by Hannah Wauchope 2024

# Libraries #------------------------------------------------------------------------------------
library(tidyverse)
library(lme4)

# Load data #------------------------------------------------------------------------
# Hummingbird data
Humming <- read.csv("weekly_materials/week_06-08/data/HummingBirds.csv")

# Begin Activity Sheet ----------------------------------------------------------------------------------

#### Part 1 - Data Exploration and Prep ####
## Exercise 1 - Visualise
glimpse(Humming)
head(Humming)

## Exercise 2 - Plot
ggplot(Humming, aes(x=Year, y=Count))+
  geom_point()+
  theme_classic()+

ggplot(Humming, aes(x=Year, y=Count))+
  geom_point()+
  theme_classic()+ 
  facet_grid(Site ~ Species)
  
ggplot(Humming, aes(x=Year, y=Count))+
  geom_point()+
  theme_classic()+ 
  facet_grid(Site ~ Species, scales="free")

## Exercise 3 - Understanding the Coefficients. Use the summary of your model from exercise 2 to calculate the coefficients. Then check your answer by running a ggpredict call here
Humming$Year <- Humming$Year - min(Humming$Year)

#### Part 2: Simple Linear Models ####

## Exercise 1 - Building an LM
LMMod <- lm(Count~YearScale, data=Humming)

## Exercise 2 - Model Output
summary(LMMod)

#No effect of year (i.e. hummingbirds aren't changing)

## Exercise 3 - Variance

#R2 is 0.004 (i.e. basically no variance is explained)

## Exercise 4 - Assumptions

#3 assumptions are: independence of data, normality of residuals, homogeneity of variance

## Exercise 5 - Check Assumptions

plot(LMMod) #Plots look baaad

shapiro.test(resid(LMMod)) #Shapiro test significant (i.e. residuals non-normally distributed)

#Bartlett test won't run because some years only have one data point. Tell students not to worry, we'll check for homogeneity of variance in later models

#### Part 3 - Generalised Linear Models ####

## Exercise 1 - Building a GLM
GLMMod <- glm(Count~Year, data=Humming, family="poisson")

## Exercise 2 -  Model Output
summary(GLMMod)

#Year now significantly positive (don't worry about exact estimate for now)

## Exercise 3 - Variance
summary(GLMMod)

(4654.5 - 4582.3)/4654.5 # = 0.015. Better than before, but still very very bad. We're explaining 1.5% of the variance in the data

## Exercise 4 - Check Assumptions
install.packages("DHARMa")
library(DHARMa)

ModResiduals <- simulateResiduals(fittedModel = GLMMod, plot = F)
plot(ModResiduals)

#First plot is looking for normality of residuals, second homogeneity of variance. KS test = Kolmogorov-Smirnov, a test of normality. Dispersion test = more variability than expected. Outlier = there are outliers
#Second plot the thick lines should follow the dashed. Looks at homogeneity of variance. 

## Exercise 5 - Now What
#Our data has groups, i.e. is non independent. Run a GLMM!

#### Part 3 - Linear Mixed Models ####

##Exercise 1 - Identifying grouped data
#We will group on species and site

#Both have at least 5 levesl so we're good

## Exercise 2 - Building a GLMM

GLMMMod <- glmer(Count~Year + (1|Species) + (1|Site), data=Humming, family="poisson")

## Exercise 3 - Model output
summary(GLMMMod)

#Understanding hasn't changed

## Exercise 4 - Variance
remotes::install_github("timnewbold/StatisticalModels")
library(StatisticalModels)

R2GLMER(GLMMMod)

#The R2 is VERY high. I think a bit weirdly high, so remind them it's not perfect, just a guide. 
#Year explains very little variation, but this isn't necessarily a bad thing. It means species/site have a much bigger impact on how many hummingbirds there are in general
#But that's not surprising.
#We can still be intersted in, for a given species/site, whether hummingbirds are increasing!

## Exercise 5 - Check Assumptions. 

ModResiduals <- simulateResiduals(fittedModel = GLMMMod, plot = F)
plot(ModResiduals)

#Looks way better. 

