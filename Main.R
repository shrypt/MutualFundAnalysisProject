# Project: MUTUAL FUND CATEGORIZATION, ANALYSIS AND FORECAST (MF-CAF)
# Author: SHREYAS SANJAY PANDIT
# Registration Number: 201906694
# Academic Year: 2019
# Last Updated on: 21-APR-2021

#Load all required packages and source files
library(shinydashboard)
library(plotly)
library(fpp2)
library(Quandl)
library(dplyr)
library(stringr)
library(doParallel)
source("UI.R")
source("Server.R")
source("ViewFunds.R")
source("CategorizeFunds.R")
source("AnalyseFund.R")
source("TabulateRawData.R")
source("Keys.R")
# Run the application
shinyApp(ui = ui, server = server)