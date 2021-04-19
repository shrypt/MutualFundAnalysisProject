# Project: MUTUAL FUND CATEGORIZATION, ANALYSIS AND FORECAST (MF-CAF)
# Author: SHREYAS SANJAY PANDIT
# Registration Number: 201906694
# Academic Year: 2019
# Last Updated on: 21-APR-2021

# Get NAV for selected Fund and time limits from Quandl
get_NAV <- function(FCode,FY_StartLimit,FY_EndLimit)
{
  key <- get_key(1)
  X <- Quandl(FCode, start_date=FY_StartLimit, end_date=FY_EndLimit,column_index = '1',api_key=key[1],collapse = 'monthly')
  names(X)[2] <- "NAV"
  return(X)
}
# Analyse time series
predict_NAV <- function(data_df,start_date){
  year <- as.numeric(format(as.Date(start_date),"%Y"))
  month <- as.numeric(format(as.Date(start_date),"%m"))
  data_df <- data_df[order(data_df$Date),]
  Y <- ts(data_df[,2],start = c(year,month), frequency = 12)
  return(Y)
}