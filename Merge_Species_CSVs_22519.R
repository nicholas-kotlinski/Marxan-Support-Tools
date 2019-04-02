rm(list=ls())

library(snowfall);library(reshape);library(dplyr);library(tibble);library(maptools);library(raster);library(sp);library(rgdal);library(spatialEco);library(foreign);library(purrr)

##################################
#Combine species CSVs to dataframe
##################################

#After extracting all abundance information to individual CSVs, merge them to a single file
#You will have to do this for both SDM and IUCN folders unless they have been combined already

# Where do the csv files live?
wd <- setwd("E:/Guyana Priority Areas - Backup/Distribution Models/North_Rupununi/IUCN_Tables_22119")

readDBA <- function(file){
  df <- read.csv(file, as.is=TRUE)
  df$fileName <- file
  return(df)}

# Combine the csvs into a single dataframe
file.names <- list.files(pattern="*\\.csv")
combinedData <- file.names %>% map_dfr(readDBA)
head(combinedData)

# Get rid of unnecessary columns [OID, COUNT, AREA]
combinedData[1] <- NULL
head(combinedData)
combinedData[2:3] <- NULL

# Check one more time to make sure you deleted the right columns and not the useful ones [PU_ID, SUM, fileName]
head(combinedData)

# Now change the column headers to something useful - "value" is needed instead of Cost to make the cast function work below
names(combinedData)[1] <- "ID"
names(combinedData)[2] <- "value"
names(combinedData)[3] <- "SPECIES"

# Good to go?
head(combinedData)

# This should reformat the table so that species names are column headers and PU_ID are row headers
formedData <- cast(combinedData, ID ~ SPECIES)

# Delete NA values. This may, or may not, work. You can always delete NAs in Excel...
formedData$value[is.na(formedData$value)] <- 0

# Mutliply values by pixel size (IF NEEDED!)
#combinedData$SUM <- combinedData$SUM * 1000

write.csv(formedData, file="E:/Guyana Priority Areas - Backup/Distribution Models/North_Rupununi/DELETEME.csv")

# NOW CHANGE YOUR WORKING DIRECTORY (WD) TO THE FOLDER WITH IUCN CSVs AND RUN THE CODE AGAIN

# After you're done, open both of the merged CSVs and combine them. Save the file as "Abundance_Merged_Date.csv", etc.
# Make a copy and stash it away for future reference to species names in the column headers
# In the copied file:
# 1) Delete the first row with no column header
# 2) Highlight all of the values and find/replace "NA" and replace with "0"
# 3) Change column header names to numerical values starting with "1"
# 4) Do a final search and make sure there are no special characters hiding in the data (".", " ", "/", "_", etc.)
#
#
#
#
#
#
####################################################################
# IGNORE: USE IF YOU WANT TO MAKE YOUR OWN SPDV2.dat TABLE - I THINK
###################################################################

wd <- setwd("E:/Guyana Priority Areas - Backup/Distribution Models/North_Rupununi/IUCN_Tables_22119")
cD.IUCN <- file.names %>% map_dfr(readDBA)
head(cD.IUCN)

wd <- setwd("E:/Guyana Priority Areas - Backup/Distribution Models/North_Rupununi/SDM_Tables_22119")
readDBA <- function(file){
  df <- read.csv(file, as.is=TRUE)
  df$fileName <- file
  return(df)}

file.names <- list.files(pattern="*\\.csv")
cD.SDM <- file.names %>% map_dfr(readDBA)
head(cD.SDM)

write.csv(cD.IUCN, file="E:/Guyana Priority Areas - Backup/Distribution Models/North_Rupununi/IUCN_SPDV2_Tables_31419.csv")
write.csv(cD.SDM, file="E:/Guyana Priority Areas - Backup/Distribution Models/North_Rupununi/SDM_SPDV2_Tables_31419.csv")

#reshape(combinedData, idvar="State", timevar="Year", direction="wide")
#newdf<- combinedData %>% rownames_to_column("fileName")
#head(newdf)

#multmerge <- function(mypath){
#  filenames=list.files(path=mypath, full.names=TRUE)
#  datalist = lapply(filenames, function(x){read.csv(file=x,header=T)})
#  Reduce(function(x,y) {merge(x,y)}, datalist)}
#mymergeddata = multmerge("E:/test/All_SDMs_Rename_CSVs")