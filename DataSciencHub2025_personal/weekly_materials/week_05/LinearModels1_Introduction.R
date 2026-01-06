##Introduction to Linear Models
##A worksheet for Data Science. Written by Hannah Wauchope
##10th Oct, 2025

#### Load Libraries #### ----
#We're going to be using the palmerpenguins dataset
#We also need the ggeffects package. 

#Install both of these (then don't run these lines again)
remotes::install_github("allisonhorst/palmerpenguins")
install.packages("ggeffects")

library(palmerpenguins)
library(tidyverse)
library(ggeffects)
library(ggplot2)

# Load a Theme ----
theme.clean <- function(){
  theme_bw()+
    theme(axis.text.x = element_text(size = 12, angle = 0, vjust = 0.5, hjust = 0.5),
          axis.text.y = element_text(size = 12),
          axis.title.x = element_text(size = 14, face = "plain"),             
          axis.title.y = element_text(size = 14, face = "plain"),             
          panel.grid.major.x = element_blank(),                                          
          panel.grid.minor.x = element_blank(),
          panel.grid.minor.y = element_blank(),
          panel.grid.major.y = element_blank(),  
          plot.margin = unit(c(0.5, 0.5, 0.5, 0.5), units = , "cm"),
          plot.title = element_text(size = 20, vjust = 0.5, hjust = 0.5),
          legend.text = element_text(size = 12, face = "italic"),          
          legend.position = "right")
}
#### Exercise 1 – Inspect the data #### ----
#This data is already loaded from 'palmerpenguins'. Have a look here:
glimpse(penguins)
summary(penguins)
view(penguins)

unique(penguins$species) # Adelie, Gentoo, Chinstrap
unique(penguins$island) # Torgersen, Biscoe, Dream 

penguins_na <- na.omit(penguins)
glimpse(penguins_na)

#### Exercise 2 - Look at relationships #### ----
# flipper_length_mm as y, body_mass_g as x. ggpoint
ggplot(penguins_na, aes(body_mass_g, flipper_length_mm)) + 
  geom_point() + 
  geom_smooth(method = "lm") + 
  theme.clean() + 
  theme(axis.text.x = element_text(angle = 0, colour = "black", hjust = 0.5), 
        axis.text.y = element_text(colour = "black"))

# there seems to be one. 
#### Exercise 3 - Model relationships #### ----
peng.md <- lm(flipper_length_mm ~ body_mass_g, data = penguins_na)
summary(peng.md)
# R-squared of 0.76, p << 0.05. 

#### Exercise 4 - Remember assumptions #### ----
#No code for this exercise
# 1. Independence of data point 
# 2. Linear relationship between the the response and predictor variable 
# 3. Equal variances 
# 4. Residuals are normally distributed 
# 5. There is no outliers (that cannot be explained)

#### Exercise 5 - Test for assumptions ----
plot(peng.md)
# 1. No clear trend for residuals vs. fitted. Linear
# 2. Q-Q plot in line with the straight line, residuals are normally distributed
# 3. No pattern for Scale-location, equal variables
# 4. No datapoints outside Cook's distance

#### Exercise 6 - Inspect model output #### ----
# R-squared of 0.76, p << 0.05.
# 76% of the variance in penguin flipper length can be explained by their body mass.
# flipper_length = 137 + 0.0152*body_mass_g

#### Exercise 7 - Looking at the relationship #### ----
#No Code for this exercise 
df <- data.frame()
ggplot(penguins_na, aes(body_mass_g/1000, flipper_length_mm)) + 
  geom_smooth(method = "lm") + 
  #  xlim(0, 7) + 
  #  ylim(0, 250) + 
  scale_x_continuous(name="Body Mass (kg)", limits = c(0, 7), breaks = seq(0,7,1)) +
  scale_y_continuous(name = "Flipper length (mm)", limits = c(0, 250)) +
  theme.clean() 
#### Exercise 8 - Standard Error #### ----
# 95% confidence interval. 
confint(peng.md)
#               2.5 %       97.5 %
#  (Intercept) 133.10772802 140.97151377
# body_mass_g   0.01427728   0.01611325
predictflippers <- ggpredict(peng.md, c("body_mass_g"))
predictflippers
plot(predictflippers)

#### Exercise 9 - P Values #### ----
# yes. p << 0.05. it is "significatnt". 

#### Exercise 10 - Concluding this section #### ----
#No code for this exercise
# Heavier the penguin, longer the penguin flipper length will be 
# (R-squared = 0.76, < 2.2e-16, df = 331)

#### Exercise 11 - Categorical Variables ####
ggplot(penguins_na, aes(body_mass_g/1000, flipper_length_mm, colour = species)) + 
  geom_point() + 
  geom_smooth(method = "lm") + 
  scale_x_continuous(name = "Body Mass (kg)", breaks = seq(0, 7, 1)) + 
  scale_y_continuous(name = "Flipper Length (mm)", breaks = seq(170, 240, 10)) + 
  theme.clean() + 
  theme(axis.text.x = element_text(angle = 0, colour = "black", hjust = 0.5), 
        axis.text.y = element_text(colour = "black"))

#### Exercise 12 - Categorical Variables Model #### ----
# Boxplot: species vs. flipper length 
ggplot(penguins_na, aes(species, flipper_length_mm, colour = species)) + 
  geom_boxplot() + 
  theme.clean() 

#### Exercise 13 - Interpreting Categorical Variables Model #### ----
species.md <- lm(flipper_length_mm ~ species, data = penguins_na)
summary(species.md)
# Adjusted R-squared == 0.77 
# There are (Intercept) is Adelie and speciesChinstrap, speciesGentoo are the 
# difference from the Adelie estimate value. 

# Average flipper length for Chinstrap penguin: 19.6 cm
190.1027 + 5.7208
# # Average flipper length for Chinstrap penguin: 21.7 cm 
190.1027 + 27.1326

ggpredict(species.md, c("species"))

#### Exercise 14 - Bring it home #### -----
penguins.md <- lm(flipper_length_mm ~ body_mass_g*species, data = penguins_na)
summary(penguins.md)

# flipper_length_adelie = 165 + 6.6^e-3(body_mass)
# flipper_length_chinstrap = 165 + 6.6^e-3*body_mass -1.422e+01 + 5.295e-03(bodymass)
# flipper_length_Gentoo = 165 + 6.6^e-3*body_mass + 4.064e+00 + 2.730e-03(bodymass)

plot(ggpredict(penguins.md, c("body_mass_g", "species")))
