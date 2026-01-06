# Assessment 2. WWF Report
# Data Science in EES 2025
# Adapted from starter script written by Isla Myers-Smith, 3rd November 2022
# Aim: Load raw data, create a new csv.file only containing species of intereset



# Set working directory ---- 
setwd("/Users/Owner/Library/CloudStorage/OneDrive-UniversityofEdinburgh/#00_DSinEES/WWF/wwf-report")

# Libraries ----
library(tidyverse)
library(ggpubr)

# Load Living Planet Data ----
load("data/LPI_data.Rdata")

# Gather years into "year" and set them as numeric ----
data <- gather(data, year, pop, c(25:69)) 
data$year <- gsub("X", "", data$year) %>% 
  as.numeric(data$year)

View(data)
# Filter target species: "Red fox" ----
fox <- data %>% 
  filter(Common.Name == "Red fox")

(ggplot(fox, aes(year, pop, colour = realm)) + 
  geom_point() + 
  theme_classic())

write.csv(fox, "/Users/Owner/Library/Country.listwrite.csv")