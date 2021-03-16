source("HomePage.R")
source("AnalyseFund.R")
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