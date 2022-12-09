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

# Read in complete dataset
data <- read.csv("https://query.data.world/s/pgcgsk36intv4dgunw6k5y73tl7cjc", header=TRUE, stringsAsFactors=FALSE);
glimpse(data)
head(data)

# Clean and transform


# Subset to only USA data
data_usa <- data %>% filter(country == "USA")
glimpse(data_usa)
head(data_usa)

# Define UI for application that draws a histogram
ui <- fluidPage(

    # Application title
    titlePanel("USA UFO Sightings Data"),

    # Sidebar with a slider input for number of bins 
    sidebarLayout(
        sidebarPanel(
          # CODE BELOW: One input to select a U.S. state
          # And one input to select a range of dates
          selectInput('state', 'Select a State:', choices = unique(data_usa$state)),
          dateRangeInput('dates', 'Select a Date Range:', 
                         min = min(data_usa$date_time),
                         max = max(data_usa$date_time))
          ),

        # Show a plot of the generated distribution
        mainPanel()
    )
)

# Define server logic required to draw a histogram
server <- function(input, output) {}

# Run the application 
shinyApp(ui = ui, server = server)
