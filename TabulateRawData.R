# Restructure and tabulate Raw Meta Data for display
tabulate_meta_Data <- function(RawMetaData){
  MF_Family <- sapply(strsplit(as.character(RawMetaData[,2]),split = "\\s*-\\s*"),"[",1)
  MF_Scheme <- sapply(strsplit(as.character(RawMetaData[,2]),split = "\\s*-\\s*"),"[",2)
  MF_Details <- sapply(strsplit(as.character(RawMetaData[,2]),split = "\\s*-\\s*"),"[",-1:-2)
  RawMetaData$Family <- MF_Family
  RawMetaData$Scheme <- MF_Scheme
  RawMetaData$Details <- sapply(MF_Details,toString)
  RawMetaData$Details[RawMetaData$Details == ""] <- RawMetaData$Scheme[RawMetaData$Details == ""]
  RawMetaData$Option <- sapply(RawMetaData$Details,function(x) identify_fund_plan(x))
  RawMetaData$Type <- sapply(RawMetaData[,2],function(x) identify_fund_type(x))
  RawMetaData <- RawMetaData[-c(2)]
  names(RawMetaData)[1] <- "FCode"
  names(RawMetaData)[2] <- "From"
  names(RawMetaData)[3] <- "To"
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
identify_fund_type <- function(x){
  Pattern1 <- "(?i)\\b(inst)"
  Pattern2 <- "^$"
  MF_Details <- tolower(x)
  if (grepl(Pattern1,MF_Details) == TRUE){
    return("Institutional")
  }
  else if(grepl(Pattern2,MF_Details) == TRUE){
    return("UnClassified")
  }
  else{
    return("Retail")
  }
}