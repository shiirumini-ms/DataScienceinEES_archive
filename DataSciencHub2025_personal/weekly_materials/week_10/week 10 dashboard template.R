##########################################
# GBIF Vulpes vulpes Dashboarding
# Author: James Watt 19/08/25 & 17/11/2025
# In class activity Data Sci for EES - Week 10
#
#Remember if you need to re run the app, close the app window then either click 'run app' on the top right
#of the R studio script window or you can press crtl + shift + enter (windows) or cmd + shift + enter (Mac OS)
# set wd
# setwd("/Users/Owner/Library/CloudStorage/OneDrive - University of Edinburgh/#00_DSinEES/W3/Course_material/week_10")
# -----------------------------
# Load required packages - you may have to update to R v4.5.2 to get this working
# -----------------------------
library(shiny)
library(tidyverse)
library(leaflet)
library(lubridate)
library(patchwork)
library(grid)
library(png)
library(shinydashboard)

# -----------------------------
# 1. Load pre-cleaned GBIF RDS data
# -----------------------------
fox_all <- readRDS("vulpes_2000_2025_clean.Rds") %>%
  mutate(
    date = as.Date(substr(eventDate, 1, 10)),
    month = month(date, label = TRUE, abbr = TRUE),
    decimalLatitude = as.numeric(decimalLatitude),
    decimalLongitude = as.numeric(decimalLongitude),
    year = as.integer(year)
  ) %>%
  filter(!is.na(date), !is.na(decimalLatitude), !is.na(decimalLongitude))

fox_all <- fox_all %>% 
  group_by(fox_all$decimalLatitude, year) %>% 
  mutate(pop = count())


# -----------------------------
# 2. Load images to be used in dashboard
# -----------------------------
image <- "fox.png"
# -----------------------------
# 3. UI
# -----------------------------
ui <- fluidPage(
  titlePanel("Vulpes vulpes Dashboard"),
  sidebarLayout(
    sidebarPanel(
      sliderInput(inputId = "bin", 
                  label = "Slide the bar to see annual population changes", 
                  min = 2020, max = 2025, value = c(25), sep = "")
    ), 
    mainPanel(
      imageOutput("picture", height = "auto")
    )
  )
)

#    plotOutput("myhist"), 
#    tableOutput("mytable"), 
#    textOutput("mytext"),
#    tags$div(style="color:red",
#             tags$p("Visit us at:"),
#             tags$a(href = "https://ourcodingclub.github.io", "Coding Club")

# This is where you can define your input widgets like slider etc. and outputs - these can be then passed to the server section to be rendered as maps, graphs etc.

# -----------------------------
# 4. Server
# -----------------------------
# test out interactive map 
leaflet(fox_all) %>%
  addCircles(lng = ~lon, lat = ~lat, radius = ~value)
server <- function(input, output, session) {
  
  output$picture <- renderImage({
    return(list(src = "fox.png", contentType = "image/png",alt = "Alignment"))
  }, deleteFile = FALSE) #where the src is wherever you have the picture
  
}
# -----------------------------
# 5. Run App
# -----------------------------
shinyApp(ui = ui, server = server)
