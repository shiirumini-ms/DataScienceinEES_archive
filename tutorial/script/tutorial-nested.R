# Nested data frames, multiple models 
# Tutorial Script 
# To build multiple linear models to different subsets of a data set 
# all at once 

# map function at purrr package within tidyverse 
# model data, purrr, 
# broom <- tidying linear model data sets 
# set wd ----
setwd("/Users/Owner/Library/CloudStorage/OneDrive-UniversityofEdinburgh/#00_DSinEES/Tutorial")

# load library ----
library(tidyverse)
library(broom)


# load a data frame ----
data(iris)

# glipmse a data 
glimpse(iris)

# 1. Nesting ----
# nest by species 
iris_nested <- iris %>% 
  group_by(Species) %>% 
  nest()
# collapse the rest of the data frame into one column 
# it is called a list column.
# each including the rest of the data frame that has 
# Sepal.Length, Sepal.Width, Petal.Length, and Petal.Width. 

# 1. View the nested data frame (i.e., the nested list) ----
# so how does this look like? 
View(iris_nested[[2]][[1]])
View(iris_nested$data[[1]])
View(pluck(iris_nested, 2, 1))
# to find the first item in the data column, 
# we use double brackets 

# 2. Buil Multiple Models ----
# So here, we are interested in modelling how petal length of a flower is explained by sepal length. 
# We want to build this model per species. 

# Conventionally, we can do something like this. 
lm_setosa <- lm(Petal.Length ~ Sepal.Length, data = iris[iris$Species=="setosa", ])
lm_versicolor <- lm(Petal.Length ~ Sepal.Length, data = iris[iris$Species=="versicolor", ])
lm_virginica <- lm(Petal.Length ~ Sepal.Length, data = iris[iris$Species=="virginica", ])

# But this can be lengthy especially the group you are interested in (here it is Species) are more than 100s etc. 

# This is where nested data frame shines. 
# Using map() function from purrr package in tidyverse, 
# we can apply all sorts of functions to all these different data frames. 

# now, you may have realised, not only linear models, but you can use map() to apply 
# all sorts of functions (i.e., caluclations) to a different data frame.
# not only linear models, but any functions 

iris_lm <- function(df) { 
  lm(Petal.Length ~ Sepal.Length, data = df)
  }

# let's create a new column in a iris_nested data set that 
iris_nested <- iris_nested %>% 
  mutate(model = map(data, iris_lm))

View(iris_nested)  

# Glance at summary of a model for Species: setosa 
summary(iris_nested$model[[1]]) # R-squared 0.05 
summary(iris_nested$model[[2]]) # R-squared 0.56
summary(iris_nested$model[[3]]) # R-squared 0.74 


# 3. Tidy model output ----

## Glance and Tidy in broom package ----
iris_nested <- iris_nested %>% 
  mutate(model_glance = map(model, glance)) # get r-squared, adjusted r-squared, and p-value for each model 

## View(iris_nested$model_glance[[1]])
## View(iris_nested$model_tidy[[1]])
## tidy gives the p-value, intercept and slope for the model with std
## glance gives r-squared, adjusted-r-squared, p-value, and degrees of freedom etc.

## RMSE ---- 
library(yardstick) # tidymodels package 
#syntax: rmse(data = my_data, truth = actual, estimate = predicted)

iris_nested <- iris_nested %>%
  mutate(
    augmented = map(model, ~ augment(.x, interval = "confidence")),   
    rmse_val  = map_dbl(augmented, ~ 
                          rmse(data = .x, truth = Petal.Length, estimate = .fitted)$.estimate
    )
  )
## augment() adds columns of predicted values + residuals 
## map_dbl make sure the output is stored in numbers, not a list 
## .estimate gets RMSE output  
## ~ is a short hand for function() {} in purrr package. Below is exactly the same code as the above. 
## map(augmented, function(x) {
##   rmse(data = x, truth = Sepal.Length, estimate = x$.fitted)
## })

## Summarise model fit ----
# want to summarise model fit, and create a new list column. 
iris_nested <- iris_nested %>%
  mutate(
    model_fit = map2(model_glance, rmse_val, ~ {
      tibble( # create a data frame 
        r_squared = .x$r.squared, # .x is model_glance 
        adj_r2    = .x$adj.r.squared, 
        p_value   = .x$p.value,
        rmse      = .y # .y is rmse_val
      )
    })
  )

# want to visualise this into a new data frame for your inspection and reporting
Fit_report <- iris_nested %>% 
  select(Species, model_fit) %>% 
  unnest(cols = c(model_fit))

View(Fit_report)
# It is intereseting to see here -- virginica has quite high r-squared with significance, 
# whilst setosa does not seem to have a reation between petal length and sepal length at all!! (0.5% of variance in petal length explained by sepal length)
View(iris_nested$model_fit)

# 4. Generate Multiple Plots in One-Go ----

## Diagnostic plot ---- 
iris_nested <- iris_nested %>% 
  mutate(d_plot = map(model, plot))

# save a snapshot of the current plot into .png 
save_diag_plot <- function(model, species) {
  outfile <- file.path("asset", "output", paste0("diagnostic_", species, ".png"))
  
  png(outfile, width = 1600, height = 1600, res = 200)
  par(mfrow = c(2, 2))
  
  plot(model, which = 1)
  plot(model, which = 2)
  plot(model, which = 3)
  plot(model, which = 4)
  
  dev.off()
}

# apply function 
walk2(iris_nested$model, iris_nested$Species, save_diag_plot)


## Output ----
# We want to plot 
#### raw data point 
#### modeled linear line 
#### confident intervals 

# To do so, we first create an unnested data frame that contains 
#### raw data point
#### predicted data point 
#### confident interals 
###### for all species. 
plot_df <- iris_nested %>% 
  select(Species, augmented) %>% 
  unnest(c(augmented))

View(plot_df)
# augmented already contains the raw data point too. Thanks to augment() function 
model_output <- ggplot() +
  # raw data jitter
  geom_jitter(
    data = plot_df,
    aes(
      x = Sepal.Length,
      y = Petal.Length,
      color = Species
    ),
    alpha = 0.8, 
  ) +
  
  # confidence intervals
  geom_ribbon(
    data = plot_df,
    aes(
      x = Sepal.Length,
      ymin = .lower,
      ymax = .upper,
      fill = Species
    ),
    alpha = 0.2
  ) +
  
  # regression line (fitted values)
  geom_line(
    data = plot_df,
    aes(
      x = Sepal.Length,
      y = .fitted,
      color = Species
    ),
    linewidth = 1
  ) +  
  labs(
    x = "Sepal length (cm)",
    y = "Petal length (cm)",
    color = "Species",
    fill = "Species"
  ) +
  theme_classic() 

model_output
ggsave("/Users/Owner/Library/CloudStorage/OneDrive-UniversityofEdinburgh/#00_DSinEES/Tutorial/asset/output/model_output.png",
       plot = model_output, width = 5, height = 5, dpi = 300)
dev.off()


model_facet <- ggplot() +
  # raw data jitter
  geom_jitter(
    data = plot_df,
    aes(
      x = Sepal.Length,
      y = Petal.Length,
      color = Species
    ),
    alpha = 0.8, 
  ) +
  
  # confidence intervals
  geom_ribbon(
    data = plot_df,
    aes(
      x = Sepal.Length,
      ymin = .lower,
      ymax = .upper,
      fill = Species
    ),
    alpha = 0.2
  ) +
  
  # regression line (fitted values)
  geom_line(
    data = plot_df,
    aes(
      x = Sepal.Length,
      y = .fitted,
      color = Species
    ),
    linewidth = 1
  ) +
  facet_wrap(~ Species, scales = "free") +   # ← The key part 
  labs(
    x = "Sepal length (cm)",
    y = "Petal length (cm)",
    color = "Species",
    fill = "Species"
  ) +
  theme_classic() + 
  theme(
    legend.position = "none",   # remove duplicated legends
  )

model_facet
ggsave("/Users/Owner/Library/CloudStorage/OneDrive-UniversityofEdinburgh/#00_DSinEES/Tutorial/asset/output/model_facet.png",
       plot = model_facet, width = 10, height = 5, dpi = 300)

dev.off()

# Challenge ----

iris_nested <- iris_nested %>% 
  mutate(model_tidy = map(model, tidy)) # Call for a broom package function `tidy` and iterate it over models


Coef_report <- iris_nested %>% 
  select(Species, model_tidy) %>% # select grouping column (Species) and tidy output
  unnest(c(model_tidy)) %>% # unnest by tidy
  select(Species, term, estimate, std.error, p.value) # select variables of intersest

# ouptut
View(Coef_report)    



