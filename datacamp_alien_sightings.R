#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(ggplot2)
library(dplyr)
library(lubridate)

# Read in complete dataset
data <- read.csv("https://query.data.world/s/pgcgsk36intv4dgunw6k5y73tl7cjc", header=TRUE, stringsAsFactors=FALSE);
glimpse(data)
head(data)

# Clean and transform
data <- data %>% 
  mutate(
    date_time = as.POSIXct(date_time, tz = "UTC", "%Y-%m-%dT%H:%M:%S"), 
    posted = as.POSIXct(posted, tz = "UTC", "%Y-%m-%dT%H:%M:%S"))
glimpse(data)

# Subset to only USA data
data_usa <- data %>% filter(country == "USA")
glimpse(data_usa)
head(data_usa)

# Define UI for application that draws a histogram
ui <- fluidPage(

    # Application title
    titlePanel("USA UFO Sightings Data"),

    # Sidebar with dropdown and date selectors 
    sidebarLayout(
        sidebarPanel(
          # CODE BELOW: One input to select a U.S. state
          # And one input to select a range of dates
          selectInput('state', 'Select a State:', choices = unique(data_usa$state)),
          dateRangeInput('dates', 'Select a Date Range:', 
                         start = min(data_usa$date_time),
                         end = max(data_usa$date_time))
          ),

        # Show a plot and table
        mainPanel(
          plotOutput('shapes'),
          tableOutput('duration_table')
        )
    )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
  # Plot number of sightings by shape
  output$shapes <- renderPlot({
    data_usa %>%
      filter(state == input$state) %>%
      filter(input$dates[1] <= date_time & input$dates[2] >= date_time) %>%
      ggplot(aes(x = shape, y = n)) + geom_col()
  })
  
  # Function to create a data frame of sights by shape and duration metrics
  sightings_by_duration <- function(){
    data_usa %>%
      group_by(shape) %>%
      summarize(num_sightings = n(),
                min_duration = min(duration),
                max_duration = max(duration),
                avg_duration = mean(duration),
                median_duration = median(duration))
  }
  
  # Output complete table of number of sightings by shape, min/max/median/mean duration
  output$duration_table <- renderTable({
    sightings_by_duration()
  }) 
}


# Run the application 
shinyApp(ui = ui, server = server)
