# Created: 25/09/2025 
# Author: Mako Shibata (s2471259@ed.ac.uk)
# Created: 02/10/2025
# Aim: Cleaning the Code Script Below

# load libraries ----
library(dplyr)
library(tidyverse)
library(beepr)
library(ggthemes)
library(gridExtra)
library(ggplot2)
library(ggpubr)

# load themes ----
theme.LPI <- function(){
  theme_bw()+
    theme(axis.text.x=element_text(size=12, angle=90, vjust=1, hjust=1, color="black"), 
          axis.text.y=element_text(size=12, color="black"), 
          axis.title.x=element_text(size=12, face="plain", color="black"), 
          axis.title.y=element_text(size=12, face="plain", color="black"), 
          panel.grid.major.x=element_blank(), 
          panel.grid.minor.x=element_blank(), 
          panel.grid.minor.y=element_blank(), 
          panel.grid.major.y=element_blank(), 
          plot.margin=unit(c(0.5, 0.5, 0.5, 0.5), units= , "cm"), 
          plot.title = element_text(size=14, vjust=1, hjust=0.5), 
          legend.text = element_text(size=12, face="italic", color="black"), 
          legend.title = element_blank(),
          legend.background = element_rect(fill='transparent'), 
          legend.position=c(0.9,0.9))
}

#woah awesome add ins for the theme!Looks great :)

# Set working directory ---- 
setwd("/Users/Owner/Library/CloudStorage/OneDrive-UniversityofEdinburgh/#00_DSinEES/W2/clean-that-code_formative/clean-that-code")

# Load Living Planet Data
LPI_data <- read.csv("LPI_birds.csv")

# Explore data
summary(LPI_data)
str(LPI_data)
View(LPI_data)

# Reshape data into long form
LPI_long <- gather(LPI_data, year, pop, c(25:69))

#nice reworking of the long format, I did this as well!

# Extract numeric values from year column
LPI_long$year <- gsub("X", "", LPI_long$year)

#nice switch to the gsub

# Data relocation
LPI_long <- LPI_long %>% 
  relocate(Data.source.citation, .after = pop) %>% 
  relocate(year, .before = Authority) %>%
  relocate(pop, .after = year)

View(LPI_long)

# I haven't seen the use of relocate so I am not sure how it works, but is there potentially a way for you to combine the three commands for relocate into one?


# Make concatenation of genus and species and population id <= what for? 
LPI_long$genus_species_id <- paste(LPI_long$Genus, LPI_long$Species, LPI_long$id, sep="_")

# For this I used the dlpry funtions select() and bind_cols() function, which made a little more sense for me.

# Only keep rows with numeric populations 
LPI_long <- filter(LPI_long, is.numeric(pop)) %>% 
  filter(!is.na(pop))


# Create columns for the first and most recent years that data were collected
LPI_long <- LPI_long %>% 
  group_by(genus_species_id) %>% 
  mutate(maxyear=max(year), minyear = min(year)) 

#nice job recognizing the repetition of the og code and trimming it down.

# Change the column types of max and min years as numeric 
LPI_long$maxyear <- as.numeric(LPI_long$maxyear)
LPI_long$minyear <- as.numeric(LPI_long$minyear)

# Create a column for the length of time data available
# This is the duration of monitoring for each population
LPI_long <- LPI_long %>%
  mutate(length_y = maxyear - minyear)

# Normalising proportion of population to 0-1
LPI_long <- LPI_long %>% 
  mutate(scalepop = (pop-min(pop)) / (max(pop)-min(pop))) %>% 
  relocate(scalepop, .after = pop)



# Only keep rows with numeric values
LPI_long <- LPI_long %>% 
  filter(is.numeric(scalepop)) %>%
  filter(!is.na(scalepop))


View(LPI_long)

# Only keep rows with more than 5 years of data
LPI_long <- LPI_long %>% 
  filter(length_y > 5) %>% 
  ungroup()

# Remove unnecessary columns
LPI_long <- LPI_long %>%
  select(-Data.source.citation, -Authority)

#nice job continuing to combine repetitive code

# Filter out Curlew populations in the UK
Curlew <- LPI_long %>% 
  filter(Genus == "Numenius") %>%
  filter(Country.list == "United Kingdom")

#I think for this code, you could combine the command for filter into one instead of two separate ones, as it gets repetitive as we have seen in the other codes.

# Data for plotting, get only the populations with more than 15 years of data 
# from those locations 
plot <- Curlew %>% 
  select(Country.list,　year,　scalepop,　id,　length_y) %>% 
  group_by(id) %>%
  filter(length_y > 15)


# Plot Curlew populations over time
# You can beautify this graph if you want, but don't change the graph code so much that you produce a totally different graph
(f1 <- ggplot(plot, 
              aes(x=year, y=scalepop, group = id, colour=Country.list)) + 
    geom_line() + 
    geom_point() + 
    theme.LPI() + 
    labs(title="Curlew trends") + 
    theme(plot.title=element_text(size=14, hjust=0.5), 
          legend.position = c(0.8, 0.1))
  )

unique(plot$id)
# 3 populations with ids = 6028, 5154, 8510, but only one population
# that has been monitored longer than 15 years 

# Load Site Coordinate Data
site_coords <- read.csv("site_coords.csv")
head(site_coords)
str(site_coords)
print(site_coords[site_coords$id %in% c(6028, 5154, 8510), ])


# Merge Curlew data with site coordinates
Curlew_sites <- left_join(plot, site_coords, by = "id")
View(Curlew_sites)

# Make map of where the Curlew populations are located
# You can beautify this map if you want, but don't change the map code so much that you produce a totally different graph
(f2 <- ggplot(Curlew_sites, aes(x=Decimal.Longitude, y=Decimal.Latitude)) + 
    borders("world", colour = "gray40", fill = "gray75", size = 0.1) + 
    coord_cartesian(xlim = c(-8, 2), ylim = c(50, 60)) + 
    theme_map() + 
    geom_point(size=2)  + 
    theme.LPI() + 
    labs(title="Population map"))

# Make a panel of the two graphs
curlew_trends <- ggarrange(f1, f2, ncol=2,nrow=1, widths = c(1.2, 0.5))
curlew_trends

# Remember to save your graphs with code and insert the code in your script
ggsave("curlew_trends.jpg", curlew_trends, width = 8, height = 3, dpi = 300)
dev.off()

#great job signing everything off and saving! you seem very confident in the coding language so well done!