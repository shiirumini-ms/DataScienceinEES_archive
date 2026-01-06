##Introduction to Linear Models
##A worksheet for Data Science. Written by Hannah Wauchope
##10th Oct, 2025

### ANSWERS ###

#### Load Libraries ####
#We're going to be using the palmerpenguins dataset
#We also need the ggeffects package. 

#Install both of these (then don't run these lines again)
remotes::install_github("allisonhorst/palmerpenguins")
install.packages("ggeffects")

library(palmerpenguins)
library(tidyverse)
library(ggeffects)

#### Exercise 1 – Inspect the data ####
summary(penguins)

#We have data for 3 species, at 3 islands (Biscoe, Dream and Torgersen), 
#we have data on bill length and depth, flipper length and body mass. 
#We have data for 2007, 2008 and 2009

#Grams to kg
#If you did it in base r it would look like this:
penguins$body_mass_kg <- penguins$body_mass_g/1000

#Or, if you did it in tidyverse, it would look like this:
penguins <- penguins %>% mutate(body_mass_kg = body_mass_g/1000)

#### Exercise 2 - Look at relationships ####
ggplot(data=penguins, aes(x=body_mass_kg, y=flipper_length_mm))+
  geom_point()+
  theme_classic()

#### Exercise 3 - Model relationships ####
Model1 <- lm(flipper_length_mm ~ body_mass_kg, data=penguins)

#### Exercise 4 - Remember assumptions ####
#The assumptions we need to check for are:
#1. Independence
#2. Linearity
#3. Normality
#4. Constant Variance
#5. Outliers
#We can't check for independence using code, we just have to consider it based on our knowledge of how the data was collected

#### Exercise 5 - Test for assumptions
par(mfrow=c(2,2))
plot(Model1)
par(mfrow=c(1,1))

#See here for great explanations! https://library.virginia.edu/data/articles/diagnostic-plots 
#Residuals vs Fitted - LINEARITY: You should see a clear trend from left to right to be worried about violating this assumption, don't stress too much about the line - it's very reactive
#QQplot - NORMALITY: Normality if residuals are more or less normally distributed, they'll more or less follow the line. Often you see little upticks at the top and bottom, this is okay. This can be checked with the Shapiro Wilk test, but we're focussing on visual inspection today.
#Scale-Location - CONSTANT VARIANCE: Again, don't stress too much about the line if it's wiggly. But if it's clearly and consistently going up or down, that means variance is clearly going up or down with our predictor. In this cae fine. 
#Residuals vs Leverage - OUTLIERS: None looking too crazy here. When things are bad you see red dotted lines, and one or two points on the other side of them to the rest - These are major outliers. That doesn't necessarily mean you should just remove them!! If you think they're accurate (and not a mismeasurement or someting), then they're an important part of your study system. But know what they'll be having a disproporionate influence on the conclusions of your model - so the model isn't so much representative of what's going on overall in your data.

#### Exercise 6 - Inspect model output ####
summary(Model1)
#R-squared is 0.76. This means that 76% of the variance in flipper length is explained by body mass.

#### Exercise 7 - Looking at the relationship ####
#The estimate for body mass is 15.28, meaning for every rise in 1kg of penguin body mass, 
#flipper length increases by 15.28mm on average.

#### Exercise 8 - Standard Error ####
confint(Model1)

PredictedFlippers <- ggpredict(Model1, c("body_mass_kg"))
PredictedFlippers
plot(PredictedFlippers)

#### Exercise 9 - P Values ####
#Yes, at P <0.0001

#### Exercise 10 - Concluding this section ####
#There is a strong positive relationship between body mass and flipper length, 
#with flipper length increasing by 15mm on average for every 1kg increase in body mass (95% CI: 14-16mm). 
#Body mass explains a high proportion of the variance in flipper length (76%). 
#The model meets all assumptions*, meaning we can be confident in these results.
#*(well, except Independence, but we're pretending here)

#### Exercise 11 - Categorical Variables ####
ggplot(data=penguins, aes(x=body_mass_kg, y=flipper_length_mm, colour=species))+
  geom_point()+
  theme_classic()

#### Exercise 12 - Categorical Variables Model ####
ggplot(data=penguins, aes(x=species, y=flipper_length_mm))+
  geom_boxplot()+
  theme_classic()

Model2 <- lm(flipper_length_mm ~ species, data=penguins)

par(mfrow=c(2,2))
plot(Model2)
par(mfrow=c(1,1))

#1. Independence (technically not, given the data are from different islands, but we're ignoring this)
#2. Linearity - residuals vs fitted (looks good, points evenly spread above and below line)
#3. Normality - Q-Q residuals (looks good, points follow diagonal line)
#4. Constant Variance - Scale-Location (Looks good, points evenly spread above and below line)
#5. Outliers - Residuals vs Leverage (no sign of red dotted lines, so no major outliers)

#### Exercise 13 - Interpreting Categorical Variables Model ####
summary(Model2)

#Adjust R-squared is 0.78. Penguin species explains 78% of the variance in flipper length, even more than body mass!
#What's weird about the table is that 'Adelie' is missing
#Adelie = 189.95
#Intervals = 188.89 - 191.01
#Yes, p < 0.0001

#Chinstrap = 189.95 + 5.86 = 195.81
#Yes, p < 0.0001
#Gentoo = 189.95 + 27.23 = 217.81
#Yes, p < 0.0001

#Check with:
ggpredict(Model2, c("species"))
plot(ggpredict(Model2, c("species")))

#### Exercise 14 - Bring it home ####
Model3 <- lm(flipper_length_mm ~ species + body_mass_kg, data=penguins)

#All look good!
summary(Model3)

#Adj R squared is 0.85 = this is the best model so far, and explains the most variance - 85%!

#Adelie y-intercept is 158.86
#Chinstrap y-intercept is 158.86 + 5.59 = 164.45
#Gentoo y-intercept is 158.86 + 15.68 = 174.54
#All rise by 8.4 per kg of body mass

plot(ggpredict(Model3, c("body_mass_kg", "species")))

#This new model makes estimates in spaces we don't have data for, 
#e.g. Adelie and Chinstrap penguins don't get bigger than about 5kg, 
#but we get estimates there anyway. You've gotta be careful about this kind of thing 
#when you have continuous and categorical variables combined in a model 
#as these extrapolations might not make much sense in some cases! 
