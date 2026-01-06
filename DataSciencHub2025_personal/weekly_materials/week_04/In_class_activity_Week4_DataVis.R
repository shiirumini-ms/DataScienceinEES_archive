# In class activity for Data Science in EES
# Starter script written by Isla Myers-Smith and Gergana Daskalova
# 21st October 2020 and 20th October 2021
#Code initially created by Isla Myers-Smith
#Updated by Hannah Wauchope Oct 2025

setwd("/Users/Owner/Library/CloudStorage/OneDrive-UniversityofEdinburgh/#00_DSinEES/W3/Course_material")
### Instructions Overview ----

# This code is structured into two Parts. We'll focus on Part 1 in class, and you can use Part 2 for the 'Impress my Nieces' challenge (OR find your own data!)
# Here, we're looking at the slopes of population change in the LPI (is the population increasing, decreasing or stable?)

# Part 1 (Plot off) just looks at which biomes we have data for

# Part 2 (Impress My Nieces) looks at how slopes vary between biomes (and will require a bit of wrangling first)
# But for Part 2 there's plenty more information within the LPI_data (glimpse to take a look) - get creative! 
# Think up what you might like to do, and then ask us for help to achieve it
# Or for Part 2, you can find your own data!

#A remind of dplyr functions if you need them for wrangling:
# https://dplyr.tidyverse.org/reference/

#And here is a link to a ggplot cheatsheet
# https://rstudio.github.io/cheatsheets/data-visualization.pdf 

#Have a google for fun themes! Or try installing package "ThemePark" - https://github.com/MatthewBJane/ThemePark 

#More on themes: https://riffomonas.org/code_club/2020-05-07-fun-with-themes

### Starter code to produce plottable data ----
#We're using the LPI data again, 
#This time for each population (e.g. a group of lions) we calculate if it is increasing, decreasing, or stable through time

# Libraries ----
library(tidyverse)
library(scales)
library(ggplot2)
library(tidyr)
library(ggpubr)

# Load Living Planet Data ----
LPI_data <- read.csv("weekly_materials/week_04/data/LPI_data.csv")
LPI_data
# Reshape data into long form
LPI_long <- gather(LPI_data, key = "year", value = "pop", 25:69) %>%
  filter(is.finite(pop)) %>%
  group_by(id) 

LPI_long$year <- gsub("X", "", LPI_long$year) %>%
  as.numeric(LPI_long$year)

LPI_long <- LPI_long %>%
  mutate(lenyear = max(year) - min(year)) %>%
  filter(length(unique(year)) > 5) %>%
  mutate(scalepop = rescale(pop, to = c(-1, 1))) %>%
  drop_na(scalepop) %>%
  ungroup()

View(LPI_long)

# Calculate slopes of population change
LPI.models <- LPI_long %>%
  group_by(biome, Class, id, Common.Name) %>%
  do(mod = lm(scalepop ~ year, data = .)) %>%  # Create a linear model for each group
  mutate(.,
         slope = summary(mod)$coeff[2]) %>%
  ungroup() %>%
  mutate(id = id,
         biome = biome,
         Class = Class)

View(LPI_long)
# You can ignore the warnings, it's just because some populations don't have enough data
# In this output, 'slope' tells us the population change (negative = declining, positive = increasing)

#### Class Part 1 (Plot off) ----

# In teams of 2, you are to make a beautiful or an ugly figure (you choose! But if it's ugly, it needs to be *intentionally* ugly, and still show something interesting with the data). 
# The group with the prettiest and ugliest figures win the prize!

# I would like you to make a plot that ranks all of the biomes from most to least well represented 
# based on the number of populations we have monitoring data for. 
# I've started you off with code to get this information, and a very boring plot (that hasn't succeeded at ranking the biomes)
# Fix the plot, and customise!
# You're welcome to decide to represent less biomes if you think that would be good, or to group them into simpler groups
# Rank bioms for most to least well represented. 

# Defining functions ----
theme.LPI <- function(){
  theme_bw()+
    theme(axis.text.x=element_text(size=12, angle=0, vjust=1, hjust=1, color="black"), 
          axis.text.y=element_text(size=12, color="black"), 
          axis.title.x=element_text(size=14, face="plain", color="black"), 
          axis.title.y=element_text(size=14, face="plain", color="black"), 
          panel.grid.major.x=element_blank(), 
          panel.grid.minor.x=element_blank(), 
          panel.grid.minor.y=element_blank(), 
          panel.grid.major.y=element_blank(), 
          plot.margin=unit(c(0.5, 0.5, 0.5, 0.5), units= , "cm"), 
          plot.title = element_text(size=20, vjust=1, hjust=0.5), 
          legend.text = element_text(size=12, face="italic", color="black"), 
          legend.title = element_blank(), 
          legend.position=c(0.9,0.9))
}
### PAUSE HERE
#Look at the LPI.models data!
#NOW USING PEN AND PAPER DRAW OUT HOW YOU WOULD LIKE THE PLOT TO LOOK TO ANSWER THIS QUESTION
View(LPI.models)
# number of populations = number if unique id in each biome 

LPI_Bar <- LPI.models %>%
  group_by(biome) %>%
  summarise(count = length(unique(id))) %>%
  arrange(desc(count)) %>%
  ungroup()
LPI_Bar
# excluding unknown 
LPI_Bar$biome <- as.factor(LPI_Bar$biome)
LPI_Bar <- filter(LPI_Bar, biome != "Unknown")
LPI_Bar
LPI_Bar %>% mutate(biome = fct_reorder(biome, count))

(LPI_Bargraph <- ggplot(data = LPI_Bar, aes(x=reorder(biome, -count), y = count)) +
  geom_bar(stat = "identity") + 
  scale_y_continuous(breaks = c(0, 500, 1000, 1500), limits = c(0, 1500)) + 
  theme.LPI() + 
  theme(axis.text.x = element_text(angle = 50, size = 6)) + 
  labs(x = "Biome", y = "Number of populations")
  )

ggsave(LPI_Bargraph, filename = "/Users/Owner/Library/CloudStorage/OneDrive-UniversityofEdinburgh/#00_DSinEES/W3/Course_material/challenge1.jpg", width = 5, height = 7)

#### Class Part 2 (Impress my Nieces) ----

# How are populations changing across the six best monitored biomes?
LPIcs <- LPI.models %>%
  group_by(biome) %>%
  mutate(count = length(unique(id))) %>%
  arrange(desc(count))


# 1 Temperate broadleaf and mixed forests         1355
# 2 Boreal forests/taiga                          1289
# 3 Temperate coastal rivers                       912
# 4 Temperate floodplain rivers and wetlands       637
# 5 Temperate coniferous forests                   430

LPIcs <- LPI_long %>% 
  filter(biome %in% c("Temperate broadleaf and mixed forests", 
                      "Boreal forests/taiga", 
                      "Temperate coastal rivers", 
                      "Temperate floodplain rivers and wetlands", 
                      "Temperate coniferous forests"))

LPIcs %>%  group_by(biome, Class, id, Common.Name)  %>%
  mutate(mean_count = unique(id), sum = unique(id)) %>% 
  ungroup()

# scalepop vs. year, grouped by biome. get the mean observation per year.
(trial <- ggscatter(LPIcs, "year", "mean_count", size = 0.5, alpha = 0.3) + 
    facet_wrap(~biome) + 
    theme.LPI() + 
    theme(axis.text.x = element_text(angle = 45, size = 8)))

colnames(LPIcs)
# HINT: You can use facet_wrap() or facet_grid() from the ggplot2 package to quickly create a graph with multiple panels