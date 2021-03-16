# View Fund Content and functions
view_funds_content <- function()
{
#Set File Parameters to fetch and store locally
  currentDir <- getwd()
  FileLocation <- "C:/temp"
  ZipName <- "SOURCEDATA.zip"
  if(dir.exists(FileLocation) == FALSE)
  {
    dir.create(FileLocation)  
  }
  setwd(FileLocation)
  AbsoluteFilePath <- paste(FileLocation,"/",ZipName,sep = "")
  FileAPI <- "AMFI/metadata?"
  Quandl.api_key("kxgRDGkKCSyyTRRNduxQ")
#If file does not already exist, download and extract into data frame
  if(file.exists(ZipName) == FALSE)
  {
    Quandl.database.bulk_download_to_file(FileAPI,AbsoluteFilePath)
  }
  fname <- as.character(unzip(AbsoluteFilePath, list = TRUE)$Name)
  RawMetaData <- read.csv(unzip(AbsoluteFilePath,fname))[,c(1,2,5,6)]
  #file.remove(ZipName)
  #file.remove(fname)
  setwd(currentDir)
  SchemeMetaData <- tabulate_meta_Data(RawMetaData)
  return(SchemeMetaData)
}