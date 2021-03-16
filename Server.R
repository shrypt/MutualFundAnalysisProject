# Define server logic
server <- function(input, output) {
  SchemaDetails_df <- view_funds_content()
  Fund_Type <- reactive(
    {
      # Fetch Retail or Institutional from selected Fund type
      str_extract(input$si_Fund,'\\b\\w+$')
    }
  )
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
      Option <- toString(input$sld_classify_TimeFrame)
      switch(Option,
             "1" = begin_date <- paste(start_Year,start_date,sep = ""),
             "3" = begin_date <- paste(start_Year-2,start_date,sep = ""),
             "5" = begin_date <- paste(start_Year-4,start_date,sep = ""))
      return(begin_date)
    }
  )
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
  Classified_df <- reactive(
    {
      # Construct metadata as per filters
      ClassifiedDetails_df <- SchemaDetails_df[(SchemaDetails_df$Option == input$rb_FundOption) &
                                                 (SchemaDetails_df$Type == Fund_Type()) &
                                                 (SchemaDetails_df$From <= FY_Start()) &
                                                 (SchemaDetails_df$To >= FY_End()),]
      classify_funds_content(ClassifiedDetails_df['F-Code'],FY_Start(),FY_End())
      return(ClassifiedDetails_df)
    }
    
  )
  output$SchemeDetailsTable <- renderDataTable(
    SchemaDetails_df,
    options = list(pageLength = 10),
    searchDelay = 1000
  )
  output$ClassifiedTable <- renderDataTable(
    Classified_df(),
    options = list(pageLength = 10),
    searchDelay = 1000
  )
}