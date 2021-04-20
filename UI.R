# Project: MUTUAL FUND CATEGORIZATION, ANALYSIS AND FORECAST (MF-CAF)
# Author: SHREYAS SANJAY PANDIT
# Registration Number: 201906694
# Academic Year: 2019
# Last Updated on: 21-APR-2021

#mentioning libraries and sources again required for shinyapps.io deployment
library(shinydashboard)
library(plotly)
library(fpp2)
library(Quandl)
library(dplyr)
library(stringr)
library(doParallel)
#source("UI.R")
source("Server.R")
source("ViewFunds.R")
source("CategorizeFunds.R")
source("AnalyseFund.R")
source("TabulateRawData.R")
source("Keys.R")
# Define UI for application
ui <- dashboardPage(
  skin = "blue",
  dashboardHeader(
    title = "MF-CAF"
  ),
  dashboardSidebar(
    conditionalPanel(
      condition = "input.tabset == 'View Funds'",
      box( #dummy box for alignment
        background = "black",
        style = "
                  background-color: #222d32 
                ",
        width = '100%',
        height = '100%',
        br()
      ),
      box(
        title = strong("Info:"),
        background = "blue",
        width = 12,
        solidHeader = TRUE,
        em("To see the latest updated entries, click twice on 'To' column. 
            Use the search box or column filter boxes to look for specific fund."),
        style = "
                                    font-size: 14px
                                "
      ),
    ),
    conditionalPanel(
      condition = "input.tabset == 'Categorize'",
      box(
        collapsible = TRUE,
        collapsed = FALSE,
        title = strong("Sampling Filters"),
        background = "blue",
        width = '100%',
        height = '100%',
        solidHeader = TRUE,
        em("Set below filters to Categorize funds:"),
        p(),
        radioButtons("rb_FundOption","Fund Option:",choices = list("Growth","Dividend"),inline = TRUE,width = '100%'),
        selectInput("si_category","Category:",choices = list("Top 10 Retail","Top 10 Institutional"),multiple = FALSE,selected = NULL),
        actionButton("btn_classify","Show Results",icon = icon("send"),style="background-color: orange;"),
        align = "center"
      ),
      box(
        title = strong("Info:"),
        background = "orange",
        width = 12,
        solidHeader = TRUE,
        em("Due to network processing limits on Quandl, a maximum of 400 funds can be fetched currently within a minute. Calculations are based on data available for previous 5 financial years for fetched funds."),
        style = "
                                    font-size: 14px
                                "
      ),
    ),
    conditionalPanel(
      condition = "input.tabset == 'Analyze & Forecast'",
      box(
        collapsible = TRUE,
        collapsed = TRUE,
        title = strong("Sampling Filters"),
        background = "blue",
        width = '100%',
        height = '100%',
        solidHeader = TRUE,
        em("Set below filters to analyze a fund:"),
        p(),
        sliderInput("sld_analyse_TimeFrame","Financial Year:",min = 1,max = 5,step = 2,value = 5,pre = "Last ",post = " Yrs",ticks = FALSE),
        selectizeInput("si_FCodes","FundList:",choices = "Select FCode",multiple = FALSE,selected = NULL),
        actionButton("btn_analyse","Show Results",icon = icon("send"),style="background-color: aqua;"),
        align = "center"
      ),
      box(
        title = strong("Info:"),
        background = "aqua",
        width = 12,
        solidHeader = TRUE,
        em("The Past Performance graph is interactive. Hover over or select an area on graph to zoom in on dates."),
        style = "
                                    font-size: 14px
                                "
      ),
    )
  ),
  dashboardBody(
    fluidRow(
      tabBox(
        id = "tabset",
        width = 12,
        selected ="About",
        tabPanel(
          id = "home_page","About",
          box(
            title = strong("Info:"),
            background = "aqua",
            width = 12,
            solidHeader = TRUE,
            p("This interactive web application assists user to analyze performance of mutual funds.
               Data is updated dynamically using Quandl APIs."),
            br(),
            p("The user can perform following operations:"),
            p("1. View, Search and Sort Funds"),
            p("2. Categorize Funds"),
            p("3. Analyze and Forecast Fund Performance"),
            style = "
                                     font-size: 14px
                                "
          )
        ),
        tabPanel(
          id = "view_funds","View Funds",
          tags$style(HTML('table th {background-color: dodgerblue !important;}')),
          dataTableOutput('SchemeDetailsTable'),
          style = "
                                    font-size: 12px
                                "
        ),
        tabPanel(
          id = "classify_funds","Categorize",
          tags$style(".shiny-notification {top: 50% !important;left: 50% !important;margin-top: -100px !important;margin-left: -250px !important;}"),
          box(
            title = strong("Note:"),
            background = "aqua",
            width = 12,
            solidHeader = TRUE,
            p("Please set filters on left to view results."),
            style = "
                                    font-size: 14px
                                "
          ),
          box(
            width = 6,
            solidHeader = TRUE,
            style = "
                                    background-color: #ECF0F5
                                ",
            plotlyOutput('CategoryPlot', width = "100%", height = "500px")
          ),
          box(
            width = 6,
            solidHeader = TRUE,
            style = "
                                    background-color: #ECF0F5
                                ",
            plotOutput('ClusteredPlot', width = "100%", height = "500px")
          ),
          #tags$style(HTML('table th {background-color: dodgerblue !important;}')),
          #dataTableOutput('ClassifiedTable'),
          style = "
                                    font-size: 12px
                                "
        ),
        tabPanel(
          id = "analyse_fund","Analyze & Forecast",
          box(
            title = strong("Note:"),
            background = "aqua",
            width = 12,
            solidHeader = TRUE,
            p("Please set filters on left to view results."),
            style = "
                                    font-size: 14px
                                "
          ),
          box(
            width = 6,
            solidHeader = TRUE,
            style = "
                                    background-color: #ECF0F5
                                ",
            plotlyOutput('TimeSeriesPlot', width = "100%", height = "500px")
          ),
          box(
            width = 6,
            solidHeader = TRUE,
            style = "
                                    background-color: #ECF0F5
                                ",
            plotOutput('ForcastedPlot', width = "100%", height = "500px")
          )
          #tags$style(HTML('table th {background-color: dodgerblue !important;}')),
          #dataTableOutput('AnalysedTable')
        )
      )
    ),
    tags$footer(
      "|| - An RStudio Project by Shreyas Pandit - Symbiosis Centre for Distance Learning - Copyright 2021 - ||", 
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