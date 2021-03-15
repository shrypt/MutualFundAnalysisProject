#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
# Test
#    http://shiny.rstudio.com/
#

library(shiny)
library(shinydashboard)
library(Quandl)
library(dplyr)
library(stringr)
source("HomePage.R")
source("ViewFunds.R")
source("ClassifyFunds.R")
source("AnalyseFund.R")
source("TabulateRawData.R")
# Define UI for application
ui <- dashboardPage(
        skin = "black",
        dashboardHeader(
            title = "Mutual Fund Analysis"
        ),
        dashboardSidebar(
            conditionalPanel(
                condition = "input.tabset == 'Classify Funds'",
                box(
                    collapsible = TRUE,
                    collapsed = TRUE,
                    title = strong("Filters"),
                    background = "blue",
                    width = '100%',
                    height = '100%',
                    solidHeader = TRUE,
                    em("Set the below filters to classify funds:"),
                    p(),
                    sliderInput("sld_classify_TimeFrame","Financial Year:",min = 1,max = 5,step = 2,value = 5,pre = "Last ",post = " Yrs",ticks = FALSE),
                    radioButtons("rb_FundOption","Fund Option:",choices = list("Growth","Dividend"),inline = TRUE,width = '100%'),
                    selectInput("si_Fund","Category:",choices = list("Top 5 Retail","Top 5 Institutional"),multiple = FALSE,selected = NULL)
                )
            ),
            conditionalPanel(
                condition = "input.tabset == 'Analyse Fund Performance'",
                box(
                    collapsible = TRUE,
                    collapsed = TRUE,
                    title = strong("Filters"),
                    background = "blue",
                    width = '100%',
                    height = '100%',
                    solidHeader = TRUE,
                    em("Set the below filters to analyse a fund:"),
                    p(),
                    sliderInput("sld_analyse_TimeFrame","Financial Year:",min = 1,max = 5,step = 2,value = 5,pre = "Last ",post = " Yrs",ticks = FALSE),
                    textInput("FundCode","F-Code:",placeholder = "e.g. 100034"),
                    em("Hint: To know F-Code click 'View Funds' top tab.")
                )
            )
        ),
        dashboardBody(
            fluidRow(
              tabBox(
                  id = "tabset",
                  width = 12,
                  selected ="Home Page",
                  tabPanel(id = "home_page","Home Page",home_page_content()),
                  tabPanel(id = "view_funds","View Funds",
                           tags$style(HTML('table th {background-color: dodgerblue !important;}')),
                           dataTableOutput('SchemeDetailsTable'),
                           style = "
                                    font-size: 14px
                                "
                    ),
                  tabPanel(id = "classify_funds","Classify Funds",
                           tags$style(HTML('table th {background-color: dodgerblue !important;}')),
                           dataTableOutput('ClassifiedTable'),
                           style = "
                                    font-size: 14px
                                "
                    ),
                  tabPanel(id = "analyse_fund","Analyse Fund Performance",analyse_fund_content())
                )
            ),
            tags$footer(
                    "Version 0.7 @Copyright Symbiosis Centre for Distance Learning 2021", 
                    align = "center",
                    style = "
                        background-color: crimson;
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
    SchemaDetails_df <- view_funds_content()
    Fund_Type <- reactive(
        {
            # Fetch Retail or Institutional from selected Fund type
            str_extract(input$si_Fund,'\\b\\w+$')
        }
    )
    FY_Start <- reactive(
        {
            # Set Financial Year start date
            start_date <- "-04-01"
            current_Month <- as.numeric(format(Sys.Date(),"%m"))
            if(current_Month > 3){
                start_Year <- as.numeric(format(Sys.Date(),"%Y"))-1    
            }
            else{
                start_Year <- as.numeric(format(Sys.Date(),"%Y"))-2
            }
            Option <- toString(input$sld_classify_TimeFrame)
            switch(Option,
                   "1" = begin_date <- paste(start_Year,start_date,sep = ""),
                   "3" = begin_date <- paste(start_Year-2,start_date,sep = ""),
                   "5" = begin_date <- paste(start_Year-4,start_date,sep = ""))
            return(begin_date)
        }
    )
    FY_End <- reactive(
        {
            # Set Financial Year end date
            end_date <- "-03-31"
            current_Month <- as.numeric(format(Sys.Date(),"%m"))
            if(current_Month > 3){
                end_Year <- as.numeric(format(Sys.Date(),"%Y"))
            }
            else{
                end_Year <- as.numeric(format(Sys.Date(),"%Y"))-1
            }
            closing_date <- paste(end_Year,end_date,sep = "")
            return(closing_date)
        }
    )
    output$SchemeDetailsTable <- renderDataTable(
        SchemaDetails_df,
        options = list(pageLength = 10),
        searchDelay = 1000
        )
    output$ClassifiedTable <- renderDataTable(
        ClassifiedDetails_df <- SchemaDetails_df[(SchemaDetails_df$Option == input$rb_FundOption) &
                                                 (SchemaDetails_df$Type == Fund_Type()) &
                                                 (SchemaDetails_df$From <= FY_Start()) &
                                                 (SchemaDetails_df$To >= FY_End()),],
        options = list(pageLength = 10),
        searchDelay = 1000
    )
}

# Run the application 
shinyApp(ui = ui, server = server)
