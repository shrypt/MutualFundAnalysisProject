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
library(doParallel)
source("UI.R")
source("Server.R")
source("HomePage.R")
source("ViewFunds.R")
source("ClassifyFunds.R")
source("AnalyseFund.R")
source("TabulateRawData.R")
# Run the application
shinyApp(ui = ui, server = server)