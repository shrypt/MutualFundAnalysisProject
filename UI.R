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
        em("Set below filters to classify funds:"),
        p(),
        radioButtons("rb_FundOption","Fund Option:",choices = list("Growth","Dividend"),inline = TRUE,width = '100%'),
        selectInput("si_Fund","Category:",choices = list("Top 5 Retail","Top 5 Institutional"),multiple = FALSE,selected = NULL),
        actionButton("btn_classify","Submit",icon = icon("send"),style="background-color: orange;"),
        align = "center"
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
        em("Set below filters to analyse a fund:"),
        p(),
        sliderInput("sld_analyse_TimeFrame","Financial Year:",min = 1,max = 5,step = 2,value = 5,pre = "Last ",post = " Yrs",ticks = FALSE),
        selectizeInput("si_FCodes","FundList:",choices = "Select FCode",multiple = FALSE,selected = NULL),
        actionButton("btn_analyse","Submit",icon = icon("send"),style="background-color: orange;"),
        align = "center"
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
                 box(
                   title = strong("Note:"),
                   background = "orange",
                   width = 12,
                   solidHeader = TRUE,
                   em("*Due to network processing limits on Quandl, a maximum of 600 funds can be fetched."),
                   style = "
                                    font-size: 14px
                                ",
                   #br(),
                   #em("*Funds are ranked based on calculations using data for previous 5 financial years.")
                 ),
                 tags$style(HTML('table th {background-color: dodgerblue !important;}')),
                 dataTableOutput('ClassifiedTable'),
                 style = "
                                    font-size: 14px
                                "
        ),
        tabPanel(id = "analyse_fund","Analyse Fund Performance",
                 tags$style(HTML('table th {background-color: dodgerblue !important;}')),
                 dataTableOutput('AnalysedTable'),
                 style = "
                                    font-size: 14px
                                "
                 )
      )
    ),
    tags$footer(
      "Version 1.0 @Copyright Symbiosis Centre for Distance Learning 2021", 
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