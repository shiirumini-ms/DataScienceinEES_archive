# In-class activity For Week 7
# Written by Hannah Wauchope 2024

# Libraries #------------------------------------------------------------------------------------
library(tidyverse)
library(lme4)
library(ggplot2)
install.packages("DHARMa")
library(DHARMa)
install.packages("StatisticalModels")
library(StatisticalModels)
install.packages("ggiraphExtra")
library(ggiraphExtra)
library(ggeffects)

# Load data #------------------------------------------------------------------------
# Hummingbird data
Humming <- read.csv("weekly_materials/week_06/data/HummingBirds.csv")

# Begin Activity Sheet ----------------------------------------------------------------------------------

#### Part 1 - Data Exploration and Prep ####
## Exercise 1 - Visualise
str(Humming)
length(unique(Humming$Species)) # 5 species
length(unique(Humming$Site)) # 6 site
length(unique(Humming$Count)) # 46 countries 
length(unique(Humming$Year)) # 51 years 
View(Humming)

ggplot(Humming, aes(Year, Count)) + 
  geom_point() + 
  theme_classic()

## Exercise 2 - Data Prep 
Humming$YearScale <- Humming$Year - min(Humming$Year)

#### Part 2 - Generalised Linear Models ####
## Exercise 3 - Build GLM 

Mdl1 <- glm(Count ~ YearScale, family = "poisson", data = Humming)
summary(Mdl1)
prediction <- ggplot(Humming, aes(YearScale, Count)) +
  geom_jitter(width = 0.05, height = 0.05) + 
  geom_smooth(method = "glm", method.args = list(family = "poisson")) + 
  theme_classic()

predicted <- predict(Mdl1)

## Exercise 4 - 6 Understanding GLM output 
summary(Mdl1)
exp(coef(Mdl1))
# every year, hummingbird count increases by a proportion of 1.01 
# 0.01% increase in population every year
R2 <- (4654.5 - 4582.3)/4654.5
R2
# A year explains 1.6% of the variance in hummingbird count. 

## Exercise 7 - Check GLM Assumptions 
simulateResiduals(fittedModel = Mdl1, plot = T)
## QQ plot does NOT follow the diagonal line
## residual vs. predicted do NOT follow dashed lines
# so what kind of assumption is this violating? 
## --> predictors are missing. 

## Exercise 8 - The other variables
head(Humming)
# site and species

ggplot(Humming, aes(Year, Count)) + 
  geom_point() + 
  facet_grid(Species ~ Site, scales="free") + 
  theme_classic()

#### Part 3 - Generalised Linear Mixed Models ####
## Exercise 9 - Build a GLMM 
length(unique(Humming$Species))

Mdl2 <- glmer(Count ~ Site + YearScale  + (1|Species), family = "poisson", 
      data = Humming)

## Exercise 10 - Check GLMM Assumptions 
simulateResiduals(fittedModel = Mdl2, plot = T)
# not too well

## Exercise 11 - Check GLMM Variance
## packages not found. 

## Exercise 12 - Finally Answer the Question
summary(Mdl2)
plot(ggpredict(Mdl2, c("YearScale", "Site"))) #? 
exp(confint(Mdl2)) 
exp(coef(Mdl2)) ## does not work because coefficients are in matrix
## rather than vector. 
## this means I need to transform the fixed effects output into 
## matrix, then transform all to exponential. 

# number of Hummingbirds in Arizona A: exp(0.920)
# to interpret the outcome of generalised linear model: 
#   transform back the coefficients exponential for poisson 
#   get the confidence interval and transform 
#   the value itself is the mean Y-value per the X group. 
#   for a continuous X variable, it is Y = exp(0.007535*X) 

