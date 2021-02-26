# Restructure and tabulate Raw Meta Data for display
tabulate_meta_Data <- function(RawMetaData){
  MF_Family <- sapply(strsplit(as.character(RawMetaData[,2]),split = "\\s*-\\s*"),"[",1)
  MF_Scheme <- sapply(strsplit(as.character(RawMetaData[,2]),split = "\\s*-\\s*"),"[",2)
  MF_Details <- sapply(strsplit(as.character(RawMetaData[,2]),split = "\\s*-\\s*"),"[",-1:-2)
  RawMetaData$MF_Family <- MF_Family
  RawMetaData$MF_Scheme <- MF_Scheme
  RawMetaData$MF_Details <- sapply(MF_Details,toString)
  RawMetaData$MF_Details[RawMetaData$MF_Details == ""] <- RawMetaData$MF_Scheme[RawMetaData$MF_Details == ""]
  RawMetaData$MF_Option <- sapply(RawMetaData$MF_Details,function(x) identify_fund_plan(x))
  RawMetaData <- RawMetaData[-c(2)]
  names(RawMetaData)[1] <- "Code"
  names(RawMetaData)[2] <- "From_Date"
  names(RawMetaData)[3] <- "To_Date"
  return(RawMetaData)
}
identify_fund_plan <- function(x){
  Pattern1 <- "\\b(g|growth|appreciation|gro|cumulative|cum)\\b"
  Pattern2 <- "^$"
  MF_Details <- tolower(x)
  if (grepl(Pattern1,MF_Details) == TRUE){
    return("Growth")
  }
  else if(grepl(Pattern2,MF_Details) == TRUE){
    return("UnClassified")
  }
  else{
    return("Dividend")
  }
}