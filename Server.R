# Define server logic
server <- function(input, output) {
  # Get all codes
  SchemaDetails_df <- view_funds_content()
  # Set Quandl keys to use
  key <- c("kxgRDGkKCSyyTRRNduxQ","6aTL3KgB6NoRZjDQWAR_","1yNXyvZrtMs6ZdoJGqnq","pZ1hhKssK7Aw7YXWrgHz")
  # Helper function to extract Fund Type
  Fund_Type <- reactive(
    {
      # Fetch Retail or Institutional from selected Fund type
      str_extract(input$si_Fund,'\\b\\w+$')
    }
  )
  # Helper function to extract Start Date
  FY_Start <- reactive(
    {
      # Set Financial Year start date
      start_date <- "-04-01"
      current_Month <- as.numeric(format(Sys.Date(),"%m"))
      if(current_Month > 3){
        start_Year <- as.numeric(format(Sys.Date(),"%Y"))-1    
      }
      else{
        start_Year <- as.numeric(format(Sys.Date(),"%Y"))-2
      }
      # Set Financial Year start date as per user selected value for Analyze Fund Performance tab
      CurrentTab <- toString(input$tabset)
      if(CurrentTab == 'Analyse Fund Performance'){
        Option <- toString(input$sld_analyse_TimeFrame)
        switch(Option,
                "1" = begin_date <- paste(start_Year,start_date,sep = ""),
                "3" = begin_date <- paste(start_Year-2,start_date,sep = ""),
                "5" = begin_date <- paste(start_Year-4,start_date,sep = ""))
      }
      else{ # Set Financial Year start date default
        begin_date <- paste(start_Year-4,start_date,sep = "")
      }
      return(begin_date)
    }
  )
  # Helper function to extract End Date
  FY_End <- reactive(
    {
      # Set Financial Year end date
      end_date <- "-03-31"
      current_Month <- as.numeric(format(Sys.Date(),"%m"))
      if(current_Month > 3){
        end_Year <- as.numeric(format(Sys.Date(),"%Y"))
      }
      else{
        end_Year <- as.numeric(format(Sys.Date(),"%Y"))-1
      }
      closing_date <- paste(end_Year,end_date,sep = "")
      return(closing_date)
    }
  )
  # Helper function to extract dataframe for classification
  Classified_df <- eventReactive(input$btn_classify,
    {
      # Initialize Quandl Keys, F.Y. Start Date, F.Y. End Date, Selected: Fund Option & Fund Type 
      Start <- FY_Start()
      End <- FY_End()
      SelectedFundOption <- toString(input$rb_FundOption)
      SelectedFundType <- Fund_Type()
      # If User selected Dividend, limit dataframe to only annual dividend entries 
      if(SelectedFundOption == "Dividend")
      {
        exclude_pattern <- "half|monthly|weekly|daily|fortnightly|quar|Qtrly"
        ClassifiedDetails_df <- SchemaDetails_df[(SchemaDetails_df$Option == input$rb_FundOption) &
                                                   (SchemaDetails_df$Type == Fund_Type()) &
                                                   (SchemaDetails_df$From <= FY_Start()) &
                                                   (SchemaDetails_df$To >= FY_End()),]
        ClassifiedDetails_df <- filter(ClassifiedDetails_df,
                                       (!(grepl(exclude_pattern,ClassifiedDetails_df$Scheme,ignore.case = TRUE) | 
                                            grepl(exclude_pattern,ClassifiedDetails_df$Details,ignore.case = TRUE)
                                       )
                                       )
        )
      }
      else{#else include all entries for Growth option
        ClassifiedDetails_df <- SchemaDetails_df[(SchemaDetails_df$Option == input$rb_FundOption) &
                                                   (SchemaDetails_df$Type == Fund_Type()) &
                                                   (SchemaDetails_df$From <= FY_Start()) &
                                                   (SchemaDetails_df$To >= FY_End()),]
      }
      
      # If Top 5 Retail selected, limit dataframe to only first 600 entries to handle real time network processing Quandl limit
      # Divide dataframe into list of 4 dataframes each containing 150 rows 
      if(SelectedFundType == "Retail"){
        # Create 4 clusters
        cl = makeCluster(detectCores(logical = FALSE))
        registerDoParallel(cl)
        
        ClassifiedDetails_df <- ClassifiedDetails_df[1:600,]
        v_iterator <- 1
        data_list <- list()
        for(frame in 1:4) {
          df<- data.frame(ClassifiedDetails_df[v_iterator:(150*frame),c(1)])
          names(df)[1] <- "FCode"
          v_iterator <- v_iterator + 150
          data_list <- append(data_list,list(df))
          remove(df)
        }
        tryCatch({
          #Export functions and data to clusters for parallel processing
          clusterExport(cl,varlist = c("get_cumul_NAV","data_list","Quandl","Start","End","key"),envir = environment())
          # Get cumulative NAV for all rows in 4 dataframes by cluster processing
          RatedDetails_df <- foreach(code = 1:4, .combine = rbind) %dopar% {
            get_cumul_NAV(data.frame(data_list[code]),Start,End,key[code])
          }
        },
        # Stop all clusters and resume sequential flow
        finally = stopCluster(cl))
      }
      else{ # For Top 5 Institutional selected, Get cumulative NAV for all rows in 1 dataframe by sequential processing
        RatedDetails_df <- get_cumul_NAV(ClassifiedDetails_df['FCode'],Start,End,key[1])
      }
      # Extract Fund Code from returned fund code name
      RatedDetails_df$FCode <- sapply(RatedDetails_df$FCode,function(x) gsub("AMFI.(\\d{6}).*$","\\1",x))
      return(RatedDetails_df)
    }
  )
  # Helper function to extract dataframe for analysis
  Analysed_df <- eventReactive(input$btn_analyse,
    {
       FCode <- toString(input$si_FCodes)                          
       FCode_df <- get_NAV(FCode,FY_Start(),FY_End(),key[1])  
       return(FCode_df)
    }
  )
  # Dynamic DropDown List values
  Analysed_dd_df <- reactive(
    {
       Analysed_dd_df <- SchemaDetails_df[(SchemaDetails_df$From <= FY_Start()) &
                                       (SchemaDetails_df$To >= FY_End()),]
       Analysed_dd_df <- Analysed_dd_df[,c(1)]
       return(Analysed_dd_df)
    }
  )
  #Dynamically update FundCode Dropdown
  observe({
    updateSelectizeInput(session = getDefaultReactiveDomain(),"si_FCodes", choices = Analysed_dd_df(),server = TRUE)
    
    
  })
  # render table for View Funds
  output$SchemeDetailsTable <- renderDataTable(
    SchemaDetails_df,
    options = list(pageLength = 10),
    searchDelay = 1000
  )
  # render table for Classify Funds
  output$ClassifiedTable <- renderDataTable(
    Classified_df(),
    options = list(pageLength = 10),
    searchDelay = 1000
  )
  # render table for Classify Funds
  output$AnalysedTable <- renderDataTable(
    Analysed_df(),
    options = list(pageLength = 10),
    searchDelay = 1000
  )
}