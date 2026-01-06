# In class activity for Data Science in EES
# Starter script written by Isla Myers-Smith
# 10th October 2019/12th October 2021

# Instructions ----

# Each group will tackle one question. To answer your question you need to use a pipe and dplyr functions. You can also use other functions. Here is a list of the dplyr functions:

# https://dplyr.tidyverse.org/reference/

# Before you start coding, you need to draw a work flow diagram in a file, on paper or a white board for how you are going to design your code. Then you need to take a screen cap/photo of that diagram and upload it to the folder for this activity.

# Then you need to translate your workflow diagram into comments in the R code.

# Then you can start coding.

# Remember that you are working on this script collaboratively so commit, pull and push frequently!


# Starter code ----

# Librarys
library(tidyverse)

# Load Living Planet Data
load("weekly_materials/week_04/LPI_species.Rdata")

# How many unique species are there?
# Step 1: Find the name of the "species" column
# Step 2: Check that the species and genus columns
# are character columns (e.g., not numbers)
# Step 3: Use the unique function or the distinct function
# Step 4: Use length() to get the length of the list of unique species

# Step 1:
head(LPI_species)

# Step 2:
str(LPI_species)

# Step 3 and 4:
LPI_species %>%
  summarise(n = length(unique(Species)))


# Group 1 ----
# How many bird species are monitored, what are the three most monitored birds?  How many mammal species are monitored, what are the three most monitored mammals?  Are birds monitored on average for longer than mammals across all populations?

# How many bird species are monitored, what are the three most monitored birds?
# Workflow 2 Group 1 ----
# Step 1: Filter by the bird category (Class = Aves)
# Step 2: Group by species variable
# Step 3: Tally bird species // summarise by unique length - does the same thing
# Step 4: Arrange in order of abundance - descending order

LPI_species %>%
  filter(Class == "Aves") %>% # step 1: filter by bird class
  group_by(Common.Name) %>% # step 2: grouping by species variable
  tally() %>% # tally up species counts
  arrange(desc(n)) %>% # arrange in descending order
  ungroup()

# There are 16 bird species.
# Common starling / European starling
# Winter wren
# Great cormorant / Cormorant

# How many mammal species are monitored, what are the three most monitored mammals?
# Workflow 3 Group 1 ----
# Step 1: Filter by the mammal category (Class = Mammalia)
# Step 2: Group by species variable
# Step 3: Tally mammal species // summarise by unique length - does the same thing
# Step 4: Arrange in order of abundance - descending orde

mammal_count <- LPI_species %>%
  filter(Class == "Mammalia") %>% # step 1: filter by mammal class
  group_by(Common.Name) %>% # step 2: grouping by species variable
  tally() %>% # tally up species counts
  arrange(desc(n)) %>% # arrange in descending order
  ungroup()

mammal_count
# There are 3 mammal species. Grey seal, harbour seal, red fox

# Are birds monitored on average for longer than mammals across all populations?
# Workflow 4 Group 1 ----
# Step 1: Filter for BOTH mammals and birds
# Step 2: Group by class variable so we only have birds and mammals -- try with and without
# Step 3: Make a duration column (mutate - recent year minus first year)
# Step 4: Summarise the mean for the duration column
# Step 5: ungroup

LPI_species %>%
  filter(Class %in% c('Aves','Mammalia')) %>%
  group_by(Class) %>%
  mutate(year = parse_number(as.character(year)),
         duration = max(year) - min(year)) %>%
  summarise(mean_duration = mean(duration)) %>%
  ungroup()


# Group 2 ----
# What are the top three countries with the most populations monitored?
# What are the bottom three countries with the least populations monitored?
# What country has on average the longest duration of population monitoring?

# Group the dataset by country, and count the number of unique IDs
LPI_countries <- LPI_species %>% 
  group_by(Country.list) %>% 
  summarise(Country_Count = length(unique(id))) %>% 
  ungroup()

# Organise LPI_countries in descending order by number of populations monitored
LPI_countries_top3 <- LPI_countries %>% 
  arrange(desc(Country_Count)) %>% 
  slice_head(n = 3)

# Organise LPI_countries in ascending order by number of populations monitored
LPI_countries_bottom3 <- LPI_countries %>% 
  arrange(Country_Count) %>% 
  slice_head(n = 3)

# Remove the X from the year column, convert to numeric data
LPI_years <- LPI_species %>% 
  mutate(year = str_remove(year, pattern = "X"))

# Turn year column into numeric
LPI_years$year <- as.numeric(LPI_years$year)

# Check that the year column is numeric
str(LPI_years)

# Calculate the duration of measurement for each population
LPI_duration <- LPI_years %>% 
  group_by(Country.list, id) %>% 
  summarise(Duration = max(year) - min(year)) %>% 
  ungroup()

# Average duration per country
LPI_duration_country <- LPI_duration %>% 
  group_by(Country.list) %>% 
  summarise(Mean_Duration = mean(Duration)) %>% 
  ungroup() %>% 
  arrange(desc(Mean_Duration)) %>% 
  slice_head(n = 1)


# Group 3 ----
# Rank all of the biomes from most to least well represented with populations monitored?  What is the biome with the most different genera monitored?

## Workflow:
## Q1
# 1) Break down the data into biomes for subsequent analysis
# 2) Work out the number of populations being monitored per biome
# 3) Rank the biomes by the population monitored in each
## Q2
# 4) Get the genus name from the species name
# 5) Work out the number of genera per biome
# 6) Rank the biomes by no. of genera

# Find out what biomes are in the dataset
list_biomes <- unique(LPI_species$biome)
list_biomes

# Try to count the number of observations for each biome
biomes.grouped <- group_by(LPI_species, biome)
biomes.tallied <- tally(biomes.grouped)

# Try that again with a pipe
biomes.summary <- LPI_species %>%
  group_by(biome) %>%
  tally() %>%
  ungroup()

# Find the number of unique IDs per biome, where ID is a population
biomes.summary.2 <- LPI_species %>%
  group_by(biome) %>%
  summarise(n = length(unique(id))) %>%
  ungroup()

# Rank the biomes by population monitored#
biomes.ranking <- biomes.summary.2 %>%
  arrange(desc(n))

# Check the calculations of population make sense
temp.con.for <- LPI_species %>%
  filter(biome == 'Temperate coniferous forests') %>%
  group_by(Species, Location.of.population, id) %>%
  tally() %>%
  ungroup()



#### Question 2, Group 3 ----
# Get the genus from the first half of the species column
LPI_species <- LPI_species %>%
  tidyr::separate(Species, c('Genus', 'species_2'), sep = ' ', remove = FALSE)

# Get the number of unique genera per biome
biomes.genera <- LPI_species %>%
  group_by(biome) %>%
  summarise(n = length(unique(Genus))) %>%
  ungroup()

# Rank the biomes by the number of unique genera
biomes.gen.ranking <- biomes.genera %>%
  arrange(desc(n))

## Group 3 answers ----
# Rank all of the biomes from most to least well represented with populations monitored?
biomes.ranking
# What is the biome with the most different genera monitored?
biomes.gen.ranking  # Unknow has most genera

# Group 4 ----
# What are the top three the most frequent monitoring methods in the monitoring of populations?
# 1) get sampling methods
# 2) summarize unique methods
# 3) order our methods
# 4) print answer
sampletype <- LPI_species %>%
  group_by(Sampling.method) %>% # group by sampling type
  summarise(n = length(pop)) %>%  # counts
  arrange(desc(n))  %>% #arrange in descending order
  ungroup()
print(sampletype[1:3, ])
str(sampletype)
# What is the most common monitoring method for populations that have been monitored from 1970 to 2000?

# 1) get year as a number
# 2) get only relevant years
# 3) grouped by method
# 4) ordered methods

str(LPI_monitoring_1970_2000)

LPI_monitoring_1970_2000 <- LPI_species %>%
  # mutate(year = parse_number(as.character(year))) %>% another way to do it
  mutate(year = str_remove_all(year, "X"), #get rid of "x"
         year = as.numeric(year)) %>%   # make year a number
  filter(year %in% c(1970:2000)) %>%   # here we filter for years, we could also use >= and <=
  # filter(year, between(year, 1970, 2000)) more options!
  group_by(Sampling.method) %>%
  tally() %>%
  arrange(desc(n)) %>%
  ungroup()

print(LPI_monitoring_1970_2000[1, ])

# Group 5 ----

# How many different authorities are there for the species in the LPI database?
authority_df <- LPI_species %>%
  mutate(Authority = str_replace_all(Authority, '[(),]', "")) %>% 
  group_by(Authority) %>%
  summarise(species = length(unique(Species)))

length(unique(authority_df$Authority)) # 8 authorities for the species

# Are there any formatting differences in the Authority list?

authority_df$Authority #Authorities names are formated differently 

# How many LPI species have been first named by Linnaeus?
Linnaeus_df <- authority_df %>% 
  filter(Authority == "Linnaeus 1758")

Linnaeus_df

# Of the taxa named by Linneaus, what class is most common and least common in the database?

Linnaeus_df %>% group_by(Class)  %>%
  tally() %>%
  ungroup()