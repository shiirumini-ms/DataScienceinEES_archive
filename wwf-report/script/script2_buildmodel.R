# Author: B241110 (s2471259@ed.ac.uk)
# Date created: 02/11/2025 
# Aim: Script for exploring data, building model, interpreting, and visualising. 
# Research Question: 
# How does population change in rabies free vs. rabies present area between 1970-2000?

## ---- Set WD ---- 
setwd("/Users/Owner/Library/CloudStorage/OneDrive-UniversityofEdinburgh/#00_DSinEES/WWF/wwf-report")

## ---- Libraries ----  
# tidying / data wrangling
library(tidyverse)      
library(broom.mixed)    

# model construction / analysis
library(lme4)           
library(DHARMa)         
library(performance)    
library(StatisticalModels)

# formatting / visualization
library(ggthemes)      
library(ggeffects)     
library(stargazer)  
    

## ---- Load Data ---- 
fox <- read.csv("data/fox.csv")

## ---- Data Cleaning ----
pre_2000 <- fox %>% 
  filter(is.finite(pop) & !is.na(pop)) %>%           # numeric pop only
  filter(year < 2000) %>%  # keep pre-2000 only
  filter(Units != "Number of foxes seen on carcasses/100 hours") %>%  # remove unwanted Units
  mutate(yearscale = year - min(year), # get relative year 
    region2 = case_when(
    Region %in% c("Asia", "Europe") ~ "Europe", # include Belarus as Europe
    TRUE ~ "North America"), 
    rabies = case_when(
      Country.list %in% c("United States", "United Kingdom", "Spain") ~ "Absent",
      TRUE ~ "Present")) %>% # define rabies-absent/present regions
  group_by(id) %>% 
  filter(n() >= 5) %>%    # populations with ≥5 years of obs
  ungroup() %>%
  mutate(across(where(is.character), as.factor)) %>%  # convert chars to factors
  dplyr::select(pop_id = id,
                yearscale,
                pop,
                biome,
                region = region2,
                country = Country.list,
                rabies) %>%
  mutate(pop = round(pop * 10))                      # scale pop

pre_2000$pop_id <- as.factor(pre_2000$pop_id)
 

# plot for study site visualisation 
thismap <- map_data("world") %>% 
  # set colours 
  mutate(rabies = case_when(
    region %in% c("USA", "UK", "Spain") ~ "Absent", 
    region %in% c("Finland", "Belarus") ~ "Present",
    TRUE ~ "NA")
  ) 
thismap$rabies <- factor(thismap$rabies, 
                         levels = c("Absent", "Present", "NA"))

# Use scale_fiil_manual to set correct colors
studysite <- 
  ggplot(thismap, aes(long, lat, fill=rabies, group=group)) + 
  geom_polygon(colour = "black") + 
  coord_cartesian(xlim = c(-125, 35),
                  ylim = c(25, 70)) + 
  scale_fill_manual(
    values = c(
      "Present" = "#00BFC4",
      "Absent" = "#F8766D",
      "NA" = "white"
    ),
    na.value = "white",     # ensures regions with NA are white
    name = "Rabies"  # legend title
  ) +
  labs(x = "Longitude", y = "Latitude") +
  annotate("text", x = 24, y = 25, label = "CRS:WGS84", color = "black", 
           size = 3) +
  theme_classic() +
  theme(
    axis.line = element_blank(),
    panel.border = element_rect(colour = "black", fill = NA, linewidth = 1.0)
  )
studysite
ggsave("/Users/Owner/Library/CloudStorage/OneDrive-UniversityofEdinburgh/#00_DSinEES/WWF/wwf-report/figure/studysitemap.png",
       plot = studysite, width = 7, height = 5, dpi = 300)

## ---- Model Selection ----
hist(pre_2000$pop)

# positive count data. 
# likely data structure = exponential (population)

## ---- MODEL ----
## Pre-2000 ##

# 1) Fit poisson (log) generalised mixed effects model
md_pre <- glmer(pop ~ yearscale * rabies + 
                  (yearscale|pop_id), 
                data = pre_2000, 
                family = "poisson")

# realm, biome, and country are not considered because 
# no enough levels for each class per category is avaialble. 

# 2) Plot prediction 
pred_pre <- data.frame(
  ggpredict(md_pre, terms = c("yearscale [all]", "rabies"), type = "fixed", 
            bias_correction = TRUE))

ggplot() + 
  geom_jitter(data = pre_2000, 
             aes(x = yearscale, 
                 y = pop, 
                 color = rabies, 
                 fill = rabies), 
             alpha = 0.8) + 
  geom_line(data = pred_pre, 
            aes(x = x, 
                y = predicted, 
                color = group)) + 
  geom_ribbon(data = pred_pre, 
              aes(x = x, 
                  ymin = conf.low, 
                  ymax = conf.high, 
                  fill = group), alpha = 0.2) +
  labs(x = "Year", 
       y = "Predicted abundance", 
       color = "Rabies", fill = "Rabies") +
  theme_classic()
dev.off()

## ---- ASSUMPTION CHECK ----
sim_res <- simulateResiduals(fittedModel = md_pre, n = 1000)  
png("/Users/Owner/Library/CloudStorage/OneDrive-UniversityofEdinburgh/#00_DSinEES/WWF/wwf-report/figure/diagnostics.png")
plot(sim_res)
dev.off()

# significant deviation p < 0.05, in qqplot
# residuals are not normally distributed 

# non-uniform distribution of scaled individuals
# residuals near 0, and 1, likely overdispersion
# due to model misfit

# residual vs. predicted
testDispersion(sim_res)
# dispersion = 0.035097, p-value = 0.308
# non-dispersed 


# slightly overdispersed
# missing parameters 
# clustered structures (within geographically similar
# location, habitat similarity)
# interaction 
# non-linearities!! 
# fluctuation in data

## ---- ACCURACY ASSESSMENT ----
## PRE-2000 ##

R2GLMER(md_pre)
# marginal : r2 = 17.30%
# conditional : r2 = 71.79% 

# get RMSE per Rabies-group 
rmse <- pre_2000 %>%
  mutate(pred = predict(md_pre, type = "response")) %>% 
  group_by(rabies) %>%
  summarise(
    RMSE = sqrt(mean((pop - pred)^2))) %>%
  ungroup() %>% 
  mutate(label = paste0("RMSE == ", round(RMSE, 1)))
    
# RMSE for rabies present: 64.83315
# RMSE for rabies absent: 73.79909
64.83315/800 
# 8.1% difference between actual points from predicted
73.79909/800
# 9.2% deviation of actual points from predicted 

summary(md_pre)
1 - exp(0.017934-0.041243)
# pop id does not impact the slope but does impact the intercept 

coef_pre <- tidy(md_pre, effects = "fixed", 
                 conf.int = TRUE, exponentiate = TRUE)

1 - 0.9595962*1.0180955
# 2.3% decrease in rabies affected regions per year
1.0180955 - 1
# 1.7% increase in rabies non-affected regions per year

# Intercepts are both 108, no significant difference
# slightly less in rabies affected region (table.2)

performance::check_singularity(md_pre)
# non-sigularity confirmed.

## ---- VISUALISE ----
## plot
### define function
theme.LPI <- function(){
  theme_bw()+
    theme(axis.text.x=element_text(size=12, angle=0, vjust=0.5, hjust=0.5, 
                                   color = "black"), 
          axis.text.y=element_text(size=12, color = "black"), 
          axis.title.x=element_text(size=14, face="plain"), 
          axis.title.y=element_text(size=14, face="plain"), 
          panel.grid.major.x=element_blank(), 
          panel.grid.minor.x=element_blank(), 
          panel.grid.minor.y=element_blank(), 
          panel.grid.major.y=element_blank(), 
          plot.margin=unit(c(0.5, 0.5, 0.5, 0.5), units= , "cm"), 
          plot.title = element_text(size=20, vjust=1, hjust=1), 
          legend.text = element_text(size=12, face="italic"), 
          legend.title = element_text(size=12), 
          legend.position= "right")
}

model_output <- 
  ggplot() + 
  geom_jitter(data = pre_2000, 
              aes(x = yearscale + 1970, 
                  y = pop, 
                  color = rabies, 
                  fill = rabies), 
              alpha = 0.8) + 
  geom_line(data = pred_pre, 
            aes(x = x + 1970, 
                y = predicted, 
                color = group)) + 
  geom_ribbon(data = pred_pre, 
              aes(x = x + 1970, 
                  ymin = conf.low, 
                  ymax = conf.high, 
                  fill = group), alpha = 0.2) +
  labs(x = "Year", 
       y = "Population Abundance", 
       color = "Rabies", fill = "Rabies") +
  annotate("text", x = 1970.5, y = 840, 
           label = "RMSE = 73.8", 
           color = "#F8766D", hjust = 0, size = 5) +
  annotate("text", x = 1970.5, y = 800, 
           label = "RMSE = 64.8", 
           color = "#00BFC4", hjust = 0, size = 5) +
  xlim(1970, 2000) + 
  theme.LPI()

model_output

ggsave("/Users/Owner/Library/CloudStorage/OneDrive-UniversityofEdinburgh/#00_DSinEES/WWF/wwf-report/figure/model_output.png",
       plot = model_output, width = 7, height = 5, dpi = 300)
dev.off()
# exp equation 
108.643 - 0.4126493 

## table 
stargazer(md_pre, 
          coef = list(coef_pre$estimate), 
          se = list(coef_pre$std.error), 
          type = "text",
          digits = 3,
          star.cutoffs = c(0.05, 0.01, 0.001),
          digit.separator = "")


## ---- Test with other models ----
# Fit poisson GLMM with biome and country as random effects
md_pre1 <- glmer(pop ~ yearscale * rabies + 
                  (yearscale|pop_id) + (1|biome) + (1|country), 
                data = pre_2000, 
                family = "poisson")
# suffers from singularity 

# Fit poisson GLMM with biome as random effects
md_pre1 <- glmer(pop ~ yearscale * rabies + 
                   (yearscale|pop_id) + (1|biome), 
                 data = pre_2000, 
                 family = "poisson")
# suffers from singularity 

# Fit poisson GLMM with biome as random effects
md_pre1 <- glmer(pop ~ yearscale * rabies + 
                   (yearscale|pop_id) + (1|country), 
                 data = pre_2000, 
                 family = "poisson")
# suffers from singularity 

