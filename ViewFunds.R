# Project: MUTUAL FUND CATEGORIZATION, ANALYSIS AND FORECAST (MF-CAF)
# Author: SHREYAS SANJAY PANDIT
# Registration Number: 201906694
# Academic Year: 2019
# Last Updated on: 21-APR-2021

# View Fund Content and functions
view_funds_content <- function()
{
#Set File Parameters to fetch meta-data csv and store locally
  currentDir <- getwd()
  FileLocation <- "C:/temp" #/srv/connect/apps/MutualFundAnalysisProject/temp on server
  ZipName <- "SOURCEDATA.zip"
  if(dir.exists(FileLocation) == FALSE)
  {
    dir.create(FileLocation)  
  }
  setwd(FileLocation)
  AbsoluteFilePath <- paste(FileLocation,"/",ZipName,sep = "")
  FileAPI <- "AMFI/metadata?"
  key <- get_key(1)
#If file already exist, delete if not latest file
  if(file.exists(ZipName) == TRUE)
  {
    File_create_day <- as.numeric(format(file.mtime("SOURCEDATA.zip"),"%d"))
    to_day <- as.numeric(format(Sys.time(),"%d"))
    if(File_create_day < to_day){#Remove old files
      file.remove(dir())
      #file.remove(ZipName)
    }
  }#If file does not already exist, download and extract into data frame
  if(file.exists(ZipName) == FALSE)
  {
    Quandl.database.bulk_download_to_file(FileAPI, AbsoluteFilePath, api_key=key[1])
  }
  
  fname <- as.character(unzip(AbsoluteFilePath, list = TRUE)$Name)
  RawMetaData <- read.csv(unzip(AbsoluteFilePath,fname))[,c(1,2,5,6)]
  setwd(currentDir)
  SchemeMetaData <- tabulate_meta_Data(RawMetaData)
  return(SchemeMetaData)
}