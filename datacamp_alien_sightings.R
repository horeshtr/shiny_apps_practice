#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

if(!require(shiny)) install.packages("shiny", repos = "http://cran.us.r-project.org")
if(!require(ggplot2)) install.packages("ggplot2", repos = "http://cran.us.r-project.org")
if(!require(dplyr)) install.packages("dplyr", repos = "http://cran.us.r-project.org")
if(!require(lubridate)) install.packages("lubridate", repos = "http://cran.us.r-project.org")
if(!require(stringr)) install.packages("stringr", repos = "http://cran.us.r-project.org")

library(shiny)
library(ggplot2)
library(dplyr)
library(lubridate)
library(stringr)

# Read in complete dataset
data <- read.csv(file = "https://query.data.world/s/pgcgsk36intv4dgunw6k5y73tl7cjc", 
                 header=TRUE, stringsAsFactors=FALSE,
                 na.strings = c("", " ")
                 )
glimpse(data)
head(data)

# Remove all rows with NAs
data <- data %>% filter_all(~!is.na(.))

# Clean and transform date_time
data <- data %>% 
  mutate(
    date_time = as.POSIXct(date_time, tz = "UTC", "%Y-%m-%dT%H:%M:%S"),
    date = as.Date(date_time),
    time = format(as.POSIXct(date_time), format = "%H:%M:%S"),
    posted = as.POSIXct(posted, tz = "UTC", "%Y-%m-%dT%H:%M:%S")
    )
glimpse(data)
head(data)

# Clean and transform duration

# Extract numeric value and format into consistent number of digits
# Extract unit of time and format consistently
# Align all durations into minutes ?

# unique(data$duration)
# sample(unique(data$duration), 100, replace = FALSE)
# 
# time_units <- c("sec", "second", "seconds", "min", "minute", "minutes", "hour", "hours")
# 
# duration_num <- regmatches(data$duration, gregexpr("[[:digit:]]+", data$duration))
# duration_text <- regmatches(data$duration, gregexpr("[[:digit:]]+",data$duration, ignore.case = TRUE), invert = TRUE)

  

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
          selectInput("state", "Select a State:", choices = unique(data_usa$state)),
          dateRangeInput("dates", "Select a Date Range:", 
                         start = min(data_usa$date),
                         end = max(data_usa$date))
          ),

        # Show a plot and table
        mainPanel(
          tabsetPanel(
            tabPanel("Plot", plotOutput("shapes")),
            tabPanel("Table", tableOutput("duration_table"))
          )
        )
    )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
  # Plot number of sightings by shape
  output$shapes <- renderPlot({
    data_usa %>%
      filter(state == input$state,
             date >= input$dates[1], 
             date <= input$dates[2]
             ) %>%
      ggplot(aes(shape)) + 
      geom_col() +
      labs(
        x = "Shape",
        y = "Number Sighted"
      )
  })

  # Output complete table of number of sightings by shape, min/max/median/mean duration
  output$duration_table <- renderTable({
    data_usa %>%
      filter(state == input$state,
             date >= input$dates[1], 
             date <= input$dates[2]
      ) %>%
      group_by(shape) %>%
      summarize(num_sightings = n(),
                #min_duration = min(duration),
                #max_duration = max(duration),
                #avg_duration = mean(duration),
                #median_duration = median(duration)
                )
  }) 
}

# Run the application 
shinyApp(ui = ui, server = server)
