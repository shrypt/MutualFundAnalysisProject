# Home Page Content and functions
home_page_content <- function()
{
  box(
    title = strong("Summary"),
    background = "blue",
    width = 12,
    solidHeader = TRUE,
    p("This web application serves to assist in rating performance of mutual funds
       and to predict probable NAVs based on historical data. Data is collected 
       dynamically using Quandl APIs."),
    style = "
        font-size: 14px
    ",
    br(),
    p("The user can perform following operations:"),
    p("1.View, Search and Sort Funds"),
    p("2.Categorize Funds"),
    p("3.Analyse Fund Performance"),
    style = "
        font-size: 14px
    "
  )
}
