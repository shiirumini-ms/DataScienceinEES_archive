##########################################
# GBIF Vulpes vulpes Dashboarding
# Author: James Watt 19/08/25 & 17/11/2025
# In class activity Data Sci for EES - Week 10 
#
#Remember if you need to re run the app, close the app window then either click 'run app' on the top right 
#of the R studio script window or you can press crtl + shift + enter (windows) or cmd + shift + enter (Mac OS)
#
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

# -----------------------------
# 1. Load pre-cleaned GBIF RDS data
# -----------------------------
fox_all <- readRDS("\\DataScienceHub2025\\weekly_materials\\week_10\\vulpes_2000_2025_clean.Rds") %>%
  mutate(
    date = as.Date(substr(eventDate, 1, 10)),
    month = month(date, label = TRUE, abbr = TRUE),
    decimalLatitude = as.numeric(decimalLatitude),
    decimalLongitude = as.numeric(decimalLongitude),
    year = as.integer(year)
  ) %>%
  filter(!is.na(date), !is.na(decimalLatitude), !is.na(decimalLongitude))

# -----------------------------
# 2. Load images to be used in dashboard
# -----------------------------
fox_img <- readPNG("fox.png")
fox_grob <- rasterGrob(fox_img, width = unit(1,"npc"), height = unit(1,"npc")) # Convert image to a graphical object for plotting
# -----------------------------
# 3. UI
# -----------------------------
ui <- fluidPage(
  
  tags$style("
  #mapPlot {
    height: calc(100vh - 150px) !important;   /* full window height minus header */
  }
"),
  
 
  # ---------------------------------------
  #Define panels, sliders, tick boxes etc.
  #----------------------------------------
  
  titlePanel("Vulpes vulpes Dashboard (2020–2025)"),
  
  sidebarLayout(
    sidebarPanel(
      sliderInput(
        "yrs",
        "Select year range:",
        min = 2020,
        max = 2025,
        value = c(2020, 2025),
        step = 1,
        sep = ""
      ),
      
      # checkboxes only on time-series tab
      conditionalPanel("input.tabs == 'Time Series'",
        checkboxInput("show_annual", "Show Annual plot", value = TRUE),
        checkboxInput("show_monthly", "Show Monthly plot", value = TRUE),
        checkboxInput("show_cumulative", "Show Cumulative plot", value = TRUE),
        checkboxInput("show_basis", "Show Basis of Record plot", value = TRUE)
      ),
      
      # country selection only on map tab
      conditionalPanel(
        "input.tabs == 'Map'",
        selectInput(
          "selected_countries",
          "Select countries to display on map:",
          choices = sort(unique(fox_all$countryCode)),
          selected = character(0),
          multiple = TRUE
        )
      )
    ),
    
    mainPanel(
      tabsetPanel(id = "tabs",
                  tabPanel("Time Series", plotOutput("timePlot", height = "800px")),
                  tabPanel("Map",leafletOutput("mapPlot", height = "100%")),
                  tabPanel("Summary", tableOutput("summaryTable"))
      )
    )
  ),
  
  # ---- FIXED PICTURE PANEL (bottom-left) ----
  tags$style("
    #fox_fixed {
      position: fixed;
      bottom: 20px;
      left: 20px;
      width: 320px;      
      height: 320px;    
      background: white;
      border: 1px solid #ccc;
      padding: 5px;
      z-index: 2000;
      box-shadow: 0px 0px 8px rgba(0,0,0,0.25);
    }
  "),
  
  absolutePanel(
    id = "fox_fixed",
    plotOutput("foxPlot", height = "320px", width = "320px")
  ),
)

# -----------------------------
# 4. Server
# -----------------------------
server <- function(input, output, session) {
  
  # Render fox image
  output$foxPlot <- renderPlot({
    grid.newpage()
    grid.draw(fox_grob)
  })
  
  # Filtered dataset for map
  filtered_map_data <- reactive({
    df <- fox_all %>%
      filter(year >= input$yrs[1], year <= input$yrs[2])
    
    if(length(input$selected_countries) > 0){
      df <- df %>% filter(countryCode %in% input$selected_countries)
    } else {
      df <- df[0,]  # No selection → empty map
    }
    
    df
  })
  
  # -----------------------------
  # 4a. Time Series Panel (2×2 grid)
  # -----------------------------
  output$timePlot <- renderPlot({
    df <- fox_all %>%
      filter(year >= input$yrs[1], year <= input$yrs[2])
    
    # --- 1. Annual ---
    annual_plot <- if(input$show_annual){
      df %>%
        group_by(year) %>%
        summarise(n = n(), .groups="drop") %>%
        ggplot(aes(x = year, y = n)) +
        geom_line(color = "blue") +
        geom_point(color = "darkblue") +
        scale_x_continuous(breaks = input$yrs[1]:input$yrs[2]) +
        labs(x="Year", y="Records", title="Annual Records") +
        theme_minimal()
    } else { ggplot() + theme_void() + labs(title="Annual plot disabled") }
    
    # --- 2. Monthly ---
    monthly_plot <- if(input$show_monthly & nrow(df)>0){
      df %>%
        group_by(year, month) %>%
        summarise(n=n(), .groups="drop") %>%
        ggplot(aes(x=month, y=n, fill=factor(year))) +
        geom_bar(stat="identity", position="dodge") +
        labs(x="Month", y="Records", fill="Year", title="Monthly Trends") +
        theme_minimal()
    } else { ggplot() + theme_void() + labs(title="Monthly plot disabled") }
    
    # --- 3. Cumulative ---
    cumulative_plot <- if(input$show_cumulative & nrow(df)>0){
      df %>%
        arrange(date) %>%
        mutate(cumulative=row_number()) %>%
        ggplot(aes(x=date, y=cumulative)) +
        geom_line(color="darkgreen") +
        labs(x="Date", y="Cumulative Records", title="Cumulative Records Over Time") +
        theme_minimal()
    } else { ggplot() + theme_void() + labs(title="Cumulative plot disabled") }
    
    # --- 4. Basis of Record ---
    methods_plot <- if(input$show_basis & nrow(df)>0){
      df %>%
        group_by(year, basisOfRecord) %>%
        summarise(n=n(), .groups="drop") %>%
        ggplot(aes(x=year, y=n, fill=basisOfRecord)) +
        geom_bar(stat="identity", position="stack") +
        labs(x="Year", y="Records", fill="Basis of Record", title="Basis of Record") +
        theme_minimal()
    } else { ggplot() + theme_void() + labs(title="Basis plot disabled") }
    
    (annual_plot | monthly_plot) / (cumulative_plot | methods_plot)
  })
  
  # -----------------------------
  # 4b. Map with clustering
  # -----------------------------
  output$mapPlot <- renderLeaflet({
    df <- filtered_map_data()
    
    map <- leaflet() %>% addTiles()
    
    if(nrow(df)==0){
      map <- map %>% addControl("No observations for selected countries/year range", position="topright")
    } else {
      map <- map %>%
        addCircleMarkers(
          data=df,
          lng=~decimalLongitude,
          lat=~decimalLatitude,
          radius=4,
          fillOpacity=0.6,
          popup=~paste("Date:", format(date, "%Y-%m-%d"), "<br>",
                       "Country:", countryCode),
          clusterOptions = markerClusterOptions()
        )
    }
    
    map
  })
  
  # -----------------------------
  # 4c. Summary table
  # -----------------------------
  output$summaryTable <- renderTable({
    df <- fox_all %>%
      filter(year >= input$yrs[1], year <= input$yrs[2])
    
    tibble(
      Records = nrow(df),
      Earliest = ifelse(nrow(df)>0, format(min(df$date), "%Y-%m-%d"), NA),
      Latest = ifelse(nrow(df)>0, format(max(df$date), "%Y-%m-%d"), NA),
      YearsCovered = length(unique(df$year))
    )
  })
}

# -----------------------------
# 5. Run App
# -----------------------------
shinyApp(ui = ui, server = server)
