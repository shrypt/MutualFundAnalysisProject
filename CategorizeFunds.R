# Get cumulative NAV from Quandl for list of codes
get_cumul_NAV <- function(FCodes_df,FY_StartLimit,FY_EndLimit,key)
{
  X <- Quandl(FCodes_df$MFCode, start_date=FY_StartLimit, end_date=FY_EndLimit, column_index = '1', api_key=key, collapse = 'annual', transform = 'cumul', limit = 1)
  X <- X[,-c(1)]
  return(X)
}
# Get transpose for better display of results
transpose_results <- function(X){
  X_columns <- colnames(X)
  Y <- as.data.frame(t(X))
  Y$FCode <- X_columns
  Y <- Y[,c(2,1)]
  names(Y)[2] <- "Cumulative_NAV"
  # Extract Fund Code from fund code name
  Y$FCode <- sapply(Y$FCode,function(x) gsub("AMFI.(\\d{6}).*$","\\1",x))
  return(Y)
}
# Get filtered data frame to limit record processing
filter_df <- function(SchemaDetails_df,SelectedFundOption,Start,End,SelectedFundType){
  # If User selected Dividend, limit dataframe to only annual dividend entries
  
  if(SelectedFundOption == "Dividend")
  {
    exclude_pattern <- "half|monthly|weekly|daily|fortnightly|quar|Qtrly"
    df <- SchemaDetails_df[(SchemaDetails_df$Option == SelectedFundOption) &
                                               (SchemaDetails_df$Type == SelectedFundType) &
                                               (SchemaDetails_df$From <= Start) &
                                               (SchemaDetails_df$To >= End),]
    df <- filter(df,(!(grepl(exclude_pattern,df$Scheme,ignore.case = TRUE) | grepl(exclude_pattern,df$Details,ignore.case = TRUE))))
  }
  else{#else include all entries for Growth option
    df <- SchemaDetails_df[(SchemaDetails_df$Option == SelectedFundOption) &
                                               (SchemaDetails_df$Type == SelectedFundType) &
                                               (SchemaDetails_df$From <= Start) &
                                               (SchemaDetails_df$To >= End),]
  }
  return(df)
}
# Process data frame to get NAV from Quandl
process_df <- function(ClassifiedDetails_df,SelectedFundType,Start,End){
  if(SelectedFundType == "Retail"){
    #set max records, cluster size and chunk and frame sizes
    max_records <- 400
    chunk_size <- 2
    cluster_size <- 4
    frame_size <- as.integer(max_records/chunk_size)
    api_keys <- get_key(frame_size)
    
    # Create clusters
    cl = makeCluster(cluster_size)
    registerDoParallel(cl)
    
    # Create list of dataframes based on frame_size
    ClusteredDetails_df <- ClassifiedDetails_df[1:max_records,]
    v_iterator <- 1
    data_list <- list()
    for(frame in 1:frame_size) {
      df<- data.frame(ClusteredDetails_df[v_iterator:(chunk_size*frame),c(1)])
      names(df)[1] <- "FCode"
      df$MFCode <- sapply(df['FCode'],function(x) paste('AMFI/',x,sep=""))
      v_iterator <- v_iterator + chunk_size
      data_list <- append(data_list,list(df))
      remove(df)
    }
    tryCatch({
      #Export functions and data to clusters for parallel processing
      clusterExport(cl,varlist = c("get_cumul_NAV","data_list","Quandl","Start","End","api_keys"),envir = environment())
      withProgress(message = 'Processing...',detail = 'This may take upto 60 secs.Please wait.',
                   value = 0, {
                     # Get cumulative NAV for all rows in all dataframes by cluster processing
                     RatedDetails_df <- foreach(code = 1:frame_size, .combine = cbind) %dopar% {
                       get_cumul_NAV(data.frame(data_list[code]),Start,End,api_keys[code])
                     }
                     for (i in 1:40) {
                       incProgress(1/30)
                       Sys.sleep(0.1)
                     }
                   })
    },
    # Stop all clusters and resume sequential flow
    finally = stopCluster(cl))
  }
  else{ # For Top 5 Institutional selected, Get cumulative NAV for all rows in 1 dataframe by sequential processing
    api_keys <- get_key(1)
    NormalDetails_df <- data.frame(ClassifiedDetails_df[,c(1)])
    NormalDetails_df$MFCode <- sapply(ClassifiedDetails_df['FCode'],function(x) paste('AMFI/',x,sep=""))
    withProgress(message = 'Processing...',detail = 'This may take upto 30 secs.Please wait.',
                 value = 0, {
                   RatedDetails_df <- get_cumul_NAV(NormalDetails_df,Start,End,api_keys[1])
                   for (i in 1:30) {
                     incProgress(1/20)
                     Sys.sleep(0.1)
                   }
                 })
  }
  return(RatedDetails_df)
}