############################################################
# Example solutions to the data wrangling challenge
# Data Science in Ecological and Environmental Sciences 2025
# 
# The script includes a number of fixes you could have made 
# in the code. It retains most of the starter script code 
# for reference but it has been commented out to prevent 
# issues when running the correct code. 
############################################################

# Libraries ----
library(tidyverse)
library(ggthemes)
library(gridExtra)

# Load Living Planet Data ----
LPI_data <- read.csv("LPI_birds.csv")

# Explore data ----
head(LPI_data)
summary(LPI_data)
summary(LPI_data$Class)
str(LPI_data)

# Reshape data into long form ----
LPI_long <- pivot_longer(data = LPI_data, cols=25:69, names_to = "year", values_to = "pop")

LPI_long_proc <- LPI_long %>%
  mutate(year = parse_number(LPI_long$year), # Extract numeric values from year column
         genus_species = paste(LPI_long$Genus, LPI_long$Species, sep="_"), # Make concatenation of genus and species
         genus_species_id = paste(LPI_long$Genus, LPI_long$Species, LPI_long$id, sep="_") # Make concatenation of genus and species and population id
  ) %>%
  filter(is.finite(pop) & !is.na(pop)) %>% # Only keep rows with numeric values
  group_by(genus_species_id) %>% 
  mutate(maxyear = max(year),  # Create max and min year variables 
         minyear = min(year),  # Here lengthyear could be calculated in a single line as the scalepop variable
         lengthyear = maxyear - minyear,
         scalepop = (pop-min(pop))/(max(pop)-min(pop)), 
  ) %>%
  filter(is.finite(scalepop) & lengthyear > 5) %>% # Only keep rows with numeric values and rows with more than 5 years of data
  ungroup() %>% # Remove any groupings
  dplyr::select(-c(Data.source.citation, Authority)) # Remove unnecessary columns


# Filter out Curlew populations 
Curlew2 <- LPI_long_proc %>% filter(Common.Name == 'Eurasian curlew')

# List the country options
unique(Curlew2$Country.list)

# Pick the countries of interest
CurlewUnitedKingdom <- Curlew2 %>% filter(Country.list=="United Kingdom")


plotCurlewData <- CurlewUnitedKingdom %>% 
  select(Country.list,year,scalepop,id,lengthyear) %>% 
  filter(lengthyear>15)

# Plot Curlew population trends over time 
(f1 <- ggplot(plotCurlewData, 
              aes(x = year, 
                  y = scalepop, 
                  group = id, 
                  colour = Country.list)) +
    geom_line() +
    geom_point() +
    labs(title="Curlew trends") + 
    theme(legend.position = "bottom",
          plot.title=element_text(size=15, hjust=0.5)
    )
)


# Load Site Coordinate Data
site_coords <- read.csv("site_coords.csv")
head(site_coords)

# Merge Curlew data with site coordinates
Curlew_sites <- left_join(plotCurlewData, site_coords, by = "id")

# Make map of where the Curlew populations are located


(f2 <- ggplot(Curlew_sites, 
              aes(x=Decimal.Longitude, 
                  y=Decimal.Latitude, 
                  colour=Country.list)) +
    borders("world", 
            colour = "gray40",
            fill = "gray75", 
            size = 0.3) +
    geom_point(size=4) +
    coord_cartesian(xlim = c(-10, 35),
                    ylim = c(30, 70)) +
    labs(title="Population map")) +
  theme_map() +
  theme(legend.position="none",
        plot.title=element_text(size=15, hjust=0.5))


# Make a panel of the two graphs
curlew_two_panels <- grid.arrange(f1, f2, ncol = 2)

# Remember to save your graphs with code and insert the code in your script

# Fix 14: We can use ggsave() to save our plot with code! 
ggsave(curlew_two_panels,
       filename = 'curlew_trend_and_pop_map.png',
       units = 'in',
       height = 6,
       width = 10)

dev.off()
