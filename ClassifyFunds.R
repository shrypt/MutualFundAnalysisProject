# Get cumulative NAV from Quandl for list of codes
get_cumul_NAV <- function(FCodes_df,FY_StartLimit,FY_EndLimit,key)
{
  RatedDetails_df <- FCodes_df
  RatedDetails_df$MFCode <- sapply(FCodes_df['FCode'],function(x) paste('AMFI/',x,sep=""))
  X <- Quandl(RatedDetails_df$MFCode, start_date=FY_StartLimit, end_date=FY_EndLimit,column_index = '1',api_key=key,transform = "cumul",limit = 1)
  X_columns <- colnames(X)
  Y <- as.data.frame(t(X))
  Y$FCode <- X_columns
  Y <- Y[-c(1),]
  Y <- Y[,c(2,1)]
  names(Y)[2] <- paste("Cumulative-NAV as on ",FY_EndLimit,sep = "")
  return(Y)
}