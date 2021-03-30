# Get NAV for selected Fund and time limits from Quandl
get_NAV <- function(FCode,FY_StartLimit,FY_EndLimit,key)
{
  FCode <- paste('AMFI/',FCode,sep = "")
  X <- Quandl(FCode, start_date=FY_StartLimit, end_date=FY_EndLimit,column_index = '1',api_key=key)
  names(X)[2] <- "NAV"
  return(X)
}