##Linear Models 3 - Interpreting Model Output
##A worksheet for Data Science. Written by Hannah Wauchope
##29th Oct, 2025

#Set wd ----
setwd("/Users/Owner/Library/CloudStorage/OneDrive-UniversityofEdinburgh/#00_DSinEES/W3/Course_material/weekly_materials")

#Load Libraries ----
library(tidyverse)
library(data.table)
library(lme4)
library(DHARMa)
library(ggeffects)
library(stargazer)
library(StatisticalModels)
library(performance)

#Load Data ----
Falcon <- read_csv("/week_07/data/Falcons.csv") 

#### Exercise 1 - Visualise Data ----

#### Exercise 2 - Model ----

#### Exercise 3 - Plot ----

#### Exercise 4 - Intercept Estimates ----

#### Exercise 5 - Year Slope Estimates ----

#### Exercise 6 - Accounting for groups ----
#No Code
#### Exercise 7 - Build GLMM ----

#### Exercise 8 - Visualise GLMM ----

#### Exercise 9 - Check Model Representation of Data (WWF REPORT HINT) ----
FitDat <- data.frame(ggpredict(Mod2, terms=c("YearScale", "Site"), type="re")) %>%
  rename(Site = group, YearScale=x, Count = predicted)

(PlotRibbons <- ggplot()+
    geom_ribbon(data=FitDat, aes(x=YearScale, ymin = conf.low, ymax=conf.high), alpha=0.2)+
    geom_point(data=Falcon, aes(x=YearScale, y=Count, group=Species, colour=Species))+
    geom_line(data=FitDat, aes(x=YearScale, y=Count))+
    facet_wrap(. ~ Site, scales="free")+
    theme_classic()+
    theme(text=element_text(size=8)))

#### Exercise 10 - Model with Interaction ----

#### Exercise 11 - Interaction Output ----

#### Exercise 12 - Interaction Output Pt 2 ----

#### Exercise 13 - Interaction Output Pt 3 ----

#### Extension 1 (OPTIONAL) - Random Slopes ----

#### Extension 2 (OPTIONAL) - Patchy Data ----

