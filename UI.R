source("HomePage.R")
source("AnalyseFund.R")
# Define UI for application
ui <- dashboardPage(
  skin = "blue",
  dashboardHeader(
    title = "Mutual Fund Analysis"
  ),
  dashboardSidebar(
    conditionalPanel(
      condition = "input.tabset == 'Categorize Funds'",
      box(
        collapsible = TRUE,
        collapsed = FALSE,
        title = strong("Filters"),
        background = "blue",
        width = '100%',
        height = '100%',
        solidHeader = TRUE,
        em("Set below filters to classify funds:"),
        p(),
        radioButtons("rb_FundOption","Fund Option:",choices = list("Growth","Dividend"),inline = TRUE,width = '100%'),
        selectInput("si_category","Category:",choices = list("Top 5 Retail","Top 5 Institutional"),multiple = FALSE,selected = NULL),
        actionButton("btn_classify","Show Results",icon = icon("send"),style="background-color: orange;"),
        align = "center"
      ),
      box(
        title = strong("Info:"),
        background = "orange",
        width = 12,
        solidHeader = TRUE,
        em("Due to network processing limits on Quandl, a maximum of 600 funds can be fetched currently. Calculations are based on data available for previous 5 financial years."),
        style = "
                                    font-size: 12px
                                "
      ),
    ),
    conditionalPanel(
      condition = "input.tabset == 'Analyse Fund Performance'",
      box(
        collapsible = TRUE,
        collapsed = FALSE,
        title = strong("Filters"),
        background = "blue",
        width = '100%',
        height = '100%',
        solidHeader = TRUE,
        em("Set below filters to analyse a fund:"),
        p(),
        sliderInput("sld_analyse_TimeFrame","Financial Year:",min = 1,max = 5,step = 2,value = 5,pre = "Last ",post = " Yrs",ticks = FALSE),
        selectizeInput("si_FCodes","FundList:",choices = "Select FCode",multiple = FALSE,selected = NULL),
        actionButton("btn_analyse","Show Results",icon = icon("send"),style="background-color: aqua;"),
        align = "center"
      )
    )
  ),
  dashboardBody(
    #fluidRow(
      tabBox(
        id = "tabset",
        width = 12,
        selected ="Home Page",
        tabPanel(id = "home_page","Home Page",home_page_content()),
        tabPanel(id = "view_funds","View Funds",
                 tags$style(HTML('table th {background-color: dodgerblue !important;}')),
                 dataTableOutput('SchemeDetailsTable'),
                 style = "
                                    font-size: 12px
                                "
        ),
        tabPanel(
          id = "classify_funds","Categorize Funds",
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
            plotlyOutput('CategoryPlot', width = "100%", height = "400px")
          ),
          box(
            width = 6,
            solidHeader = TRUE,
            style = "
                                    background-color: #ECF0F5
                                ",
            plotOutput('ClusteredPlot', width = "100%", height = "400px")
          ),
          #tags$style(HTML('table th {background-color: dodgerblue !important;}')),
          #dataTableOutput('ClassifiedTable'),
          style = "
                                    font-size: 12px
                                "
        ),
        tabPanel(
          id = "analyse_fund","Analyse Fund Performance",
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
            plotlyOutput('TimeSeriesPlot', width = "100%", height = "400px")
          ),
          box(
            width = 6,
            solidHeader = TRUE,
            style = "
                                    background-color: #ECF0F5
                                ",
            plotOutput('ForcastedPlot', width = "100%", height = "400px")
          )
          #tags$style(HTML('table th {background-color: dodgerblue !important;}')),
          #dataTableOutput('AnalysedTable')
        )
      ),
    tags$footer(
      "#Version 1.2 | Shreyas Pandit | Symbiosis Centre for Distance Learning 2021", 
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