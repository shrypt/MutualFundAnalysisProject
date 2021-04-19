# Project: MUTUAL FUND CATEGORIZATION, ANALYSIS AND FORECAST (MF-CAF)
# Author: SHREYAS SANJAY PANDIT
# Registration Number: 201906694
# Academic Year: 2019
# Last Updated on: 21-APR-2021

# Define server logic
server <- function(input, output) {
  # Get all codes
  SchemaDetails_df <- view_funds_content()
  # render table
  # output$ClassifiedTable <- renderDataTable(
  #   Classified_df(),
  #   options = list(pageLength = 10),
  #   searchDelay = 1000
  # )
  # render clustered plot
  output$ClusteredPlot <- renderPlot({
    fig <- Clustered_Plot()
  })
  # render forcasted plot
  output$ForcastedPlot <- renderPlot({
    Items <- Prediction_Plot()
    Items[2]
  })
  # render table for View Funds
  output$SchemeDetailsTable <- renderDataTable(
    SchemaDetails_df,
    options = list(pageLength = 10),
    searchDelay = 1000,
  )
  # render plot for Classify Funds
  output$CategoryPlot <- renderPlotly({
    fig <- Classified_Plot()
  })
  # render plot for Analyze Fund
  output$TimeSeriesPlot <- renderPlotly({
    fig <- Analysed_Plot()
  })
  #Dynamically update FundCode Dropdown
  observe({
    updateSelectizeInput(session = getDefaultReactiveDomain(),"si_FCodes", choices = Analysed_dd_df(),server = TRUE)
  })
  # Helper function to extract Fund Type
  Fund_Type <- reactive(
    {
      # Fetch Retail or Institutional from selected Fund type
      str_extract(input$si_category,'\\b\\w+$')
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
      if(CurrentTab == 'Analyze & Forecast'){
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
  #Helper function to create plot for classify funds
  Classified_Plot <- eventReactive(input$btn_classify,{
    Plot_df <- Classified_df()
    Plot_df <- slice_max(Plot_df,n=10,order_by = Cumulative_NAV)
    if(Fund_Type() == "Institutional" & toString(input$rb_FundOption) == "Dividend")
    {
      SelectedFund <- paste("Top",nrow(Plot_df),"Institutional",toString(input$rb_FundOption),"funds",sep = " ")
    }
    else{
      SelectedFund <- paste(toString(input$si_category),toString(input$rb_FundOption),"funds",sep = " ")
    }
    fig <- plot_ly(data=Plot_df, x= ~FCode, y= ~Cumulative_NAV, type = "bar")
    fig <- layout(fig, bargap = 0.8, title=SelectedFund)
    return(fig)
  })
  #Helper function to create plot for analyze funds
  Analysed_Plot <- eventReactive(input$btn_analyse,{
    Plot_df <- Analysed_df()
    SelectedFund <- paste("Past Performance of fund:",toString(input$si_FCodes),sep = " ")
    fig <- plot_ly(data=Plot_df, x= ~Date, y= ~NAV, mode= "lines+markers", type = "scatter")
    fig <- layout(fig, title=SelectedFund)
    return(fig)
  })
  #Helper function to plot for analyze funds prediction
  Prediction_Plot <- eventReactive(input$btn_analyse,{
    df <- Analysed_df()
    Y <- predict_NAV(df,FY_Start())
    #fit_model <- ets(Y)
    fit_model <- auto.arima(Y,stepwise = FALSE,approximation = FALSE)
    #print(summary(fit_model))
    #checkresiduals(fit_model)
    fc <- forecast(fit_model,h=36)
    fig <- autoplot(fc, include=12) + ggtitle("Predicted Performance") + xlab("Date") + ylab("NAV") +
            theme(plot.title = element_text(hjust = 0.5))
    Items <- list(fc,fig)
    return(Items)
  })
  #Helper function to plot for classify funds prediction
  Clustered_Plot <- eventReactive(input$btn_classify,{
    d <- Classified_df()
    d <- slice_max(d,n=20,order_by = Cumulative_NAV)
    #Normalization
    z <- d[,-c(1)]
    z <- na.omit(z)
    distance <- (dist(z))^2
    #hierarchical clustering
    hc <- hclust(distance,method = "average")
    fig <- plot(hc, hang =-1,labels = d$FCode, xlab="FCode",sub="")
    return(fig)
  })
  # Helper function to extract dataframe for classification
  Classified_df <- eventReactive(input$btn_classify,
    {
      # Initialize Quandl Keys, F.Y. Start Date, F.Y. End Date, Selected: Fund Option & Fund Type 
      Start <- FY_Start()
      End <- FY_End()
      SelectedFundType <- Fund_Type()
      SelectedFundOption <- toString(input$rb_FundOption)
      # Filter All Codes
      ClassifiedDetails_df <- filter_df(SchemaDetails_df,SelectedFundOption,Start,End,SelectedFundType)
      
      # Get NAV processed for all records
      RatedDetails_df <- process_df(ClassifiedDetails_df,SelectedFundType,Start,End)
      
      # Convert data for representation
      New_df <- transpose_results(RatedDetails_df)
      remove(RatedDetails_df)
      return(New_df)
    }
  )
  # Helper function to extract dataframe for analysis
  Analysed_df <- eventReactive(input$btn_analyse,
    {
       FCode <- toString(input$si_FCodes)
       FCode <- paste('AMFI/',FCode,sep = "")
       withProgress(message = 'Processing...',detail = 'This may take upto 30 secs.Please wait.',
                    value = 0, {
                      FCode_df <- get_NAV(FCode,FY_Start(),FY_End())
                      for (i in 1:40) {
                        incProgress(1/30)
                        Sys.sleep(0.1)
                      }
                    })
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
}