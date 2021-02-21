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
source("HomePage.R")
source("ViewFunds.R")
source("ClassifyFunds.R")
source("AnalyseFund.R")

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
                  id = "tabset1",
                  width = 12,
                  selected ="Home Page",
                  tabPanel(id = "home_page","Home Page",home_page_content()),
                  tabPanel(id = "view_funds","View Funds",view_funds_content()),
                  tabPanel(id = "classify_funds","Classify Funds",classify_funds_content()),
                  tabPanel(id = "analyse_fund","Analyse Fund Performance",analyse_fund_content())
                )
            ),
            tags$footer(
                    "Version 0.2 @Copyright Symbiosis Centre for Distance Learning 2021", 
                    align = "center",
                    style = "
                        background-color: red;
                        bottom:0;
                        position:absolute;
                        padding: 5px;
                        color: white;
                        width: 100%;
                        font-size: 12px
                    "
            )
        )
    )

# Define server logic
server <- function(input, output) {
output$tabset1Selected <- renderText({
    input$tabset1
})   

}

# Run the application 
shinyApp(ui = ui, server = server)
