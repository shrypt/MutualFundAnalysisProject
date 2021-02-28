#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(shinydashboard)
library(Quandl)
library(dplyr)
source("HomePage.R")
source("ViewFunds.R")
source("ClassifyFunds.R")
source("AnalyseFund.R")
source("TabulateRawData.R")

# Define UI for application
ui <- dashboardPage(
        skin = "red",
        dashboardHeader(
            title = "Mutual Fund Analysis"
        ),
        dashboardSidebar(),
        dashboardBody(
            fluidRow(
              tabBox(
                  title = "",
                  id = "tabset",
                  width = 12,
                  selected ="Home Page",
                  tabPanel(id = "home_page","Home Page",
                        home_page_content()
                    ),
                  tabPanel(id = "view_funds","View Funds",
                           dataTableOutput('SchemeDetailsTable'),
                           style = "
                                    font-size: 12px
                                "
                    ),
                  tabPanel(id = "classify_funds","Classify Funds",classify_funds_content()),
                  tabPanel(id = "analyse_fund","Analyse Fund Performance",analyse_fund_content())
                )
            ),
            tags$footer(
                    "Version 0.4 @Copyright Symbiosis Centre for Distance Learning 2021", 
                    align = "center",
                    style = "
                        background-color: red;
                        bottom:0;
                        position:absolute;
                        padding: 5px;
                        color: white;
                        width: 100%;
                        font-size: 14px
                    "
            )
        )
    )

# Define server logic
server <- function(input, output) {
    output$SchemeDetailsTable <- renderDataTable(
        view_funds_content(),
        options = list(pageLength = 10),
        searchDelay = 1000
        )
}

# Run the application 
shinyApp(ui = ui, server = server)
