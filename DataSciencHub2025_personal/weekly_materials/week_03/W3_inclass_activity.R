# Author: Mako Shibata (s2471259@ed.ac.uk)
# Created: 02/10/2025 
# Aim: Cleaning LPI_species data

# set working directory 
setwd("/Users/Owner/Library/CloudStorage/OneDrive-UniversityofEdinburgh/#00_DSinEES/W3/Course_material")

# load a library
library(tidyverse)
install.packages("skimr")
library(skimr)

# Load Living Planet Data
load("LPI_species.Rdata")
View(LPI_species)

# How many unique species are there?
length(unique(LPI_species$Species))

# 29 species. 

# Challenge 1 ----
# How many bird species are monitored, what are the three most monitored birds? 
unique(LPI_species$Class) # bird == Aves is a class 
colnames(LPI_species)
count_bird_species <- LPI_species %>% 
  filter(Class == "Aves") %>%
  group_by(Species) %>%
  count(sort = TRUE)
count_bird_species

# 1. Sturnus vulgaris 1286
# 2. Troglodytes troglodytes  1261
# 3. Phalacrocorax carbo      1124

# How many mammal species are monitored, what are the three most monitored mammals?
unique(LPI_species$Class)
count_mammal_species <- LPI_species %>%
  filter(Class == "Mammalia") %>%
  group_by(Species) %>%
  count(sort = TRUE)

count_mammal_species

# 1. Halichoerus grypus  1642
# 2. Phoca vitulina       358
# 3. Vulpes vulpes        354

# Are birds monitored on average for longer than mammals across all populations?
LPI_species$year <- gsub("X", "", LPI_species$year)

## Group the observations by species and count the latest/oldest year observation ----
# per species
monitor_years <- LPI_species %>% 
  select(Class, Species, year) %>%
  group_by(Species) %>%
  mutate(max_year = max(year), min_year = min(year)) 


### setting max/min years to numeric 
monitor_years$max_year <- as.numeric(monitor_years$max_year)
monitor_years$min_year <- as.numeric(monitor_years$min_year)

monitor_years <- monitor_years %>%
  mutate(length_monitor = max_year - min_year)

monitor_years
mean_years <- monitor_years %>% 
  group_by(Class) %>%
  summarise(mean = mean(length_monitor))

mean_years

# Birds: 43.1 years, Mammals: 40.1 years. 

## Group the observations by ID and count the latest/oldest year observation ----
# per species
monitor_years <- LPI_species %>% 
  select(id, Class, Species, year) %>%
  group_by(id) %>%
  mutate(max_year = max(year), min_year = min(year)) 


### setting max/min years to numeric 
monitor_years$max_year <- as.numeric(monitor_years$max_year)
monitor_years$min_year <- as.numeric(monitor_years$min_year)

monitor_years <- monitor_years %>%
  mutate(length_monitor = max_year - min_year)

monitor_years
mean_years <- monitor_years %>% 
  group_by(Class) %>%
  summarise(mean = mean(length_monitor))

mean_years

# Birds: 29.4 years, Mammals: 24.4 years. 

# Challenge 2 ----
## What are the top three countries with the most populations monitored? ----
# Canada, Norway and US 
LPI_species$Country.list <- as.character(LPI_species$Country.list)
country <- LPI_species %>%
  group_by(Country.list) %>%
  summarise(n = sum(id)) %>%
  ungroup()

country <- country %>%
  arrange(n)
country

unique(country$Country.list)
# Antarctica is on the third place but it is not a country. 

## What are the bottom three countries with the least populations monitored? ----

# 1 Svalbard And Jan Mayen                                11430
# 2 Norway, Denmark, Sweden                               20258
# 3 India                                                 34160
## What country has on average the longest duration of population monitoring? ----
LPI_species$year <- as.numeric(LPI_species$year)
country_year <- LPI_species %>%
  select(Country.list, year) %>%
  group_by(Country.list) %>% 
  mutate(max_year = max(year), min_year = min(year)) %>%
  mutate(length_record = max_year - min_year) 

country_year
country_year <- country_year %>%
  group_by(Country.list) %>%
  summarise(mean_year = mean(length_record)) %>%
  arrange(mean_year)

country_year
# 1 Comoros
# 2 Brazil, Uruguay                                                                                    9
# 3 China, Hong Kong, Macao, Taiwan, Province Of China, Japan, Korea, Democratic People's Rep…         9



# Challenge 3 ----
## Rank all of the biomes from most to least well represented with populations monitored? ----
### 1. Get the representativeness of populations = unique number of ID per biome
length(unique(LPI_species$id))
biome <- LPI_species %>% 
  select(biome, id) %>%
  group_by(biome) %>%
  summarise(number_pop = length(unique(id))) %>%
  arrange(number_pop)
View(biome)
### 2. rank it. 
# most represented: Unknown biome (434), Polar freshwaters (172)
# least represented: 	Flooded grasslands and savannas (1)

## What is the biome with the most different genera monitored? ----
### separate species name into two 
LPI_species <- LPI_species %>%
  tidyr::separate(Species, c("Genus", "Species"), sep = " ", remove = FALSE) %>%
  dplyr::select(-Species)

### group by biome, count the number of unique genera per biome 
biome <- LPI_species %>%
  select(biome, Genus) %>%
  group_by(biome) %>%
  summarise(count_genera = length(unique(Genus))) %>%
  arrange(count_genera)

biome
write.csv(biome, file = "genera_count_biome.csv")