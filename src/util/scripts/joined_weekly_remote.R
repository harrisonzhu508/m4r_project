#modify this script to clean the remote sensing data

`%--%` <- function(x,y)
# https://stackoverflow.com/questions/46085274/is-there-a-string-formatting-operator-in-r-similar-to-pythons
{
  do.call(sprintf, c(list(x), y))
}

# 
library(dplyr)
library(sqldf)

path <- "../../data/processed/noaa"

country_code <- read.csv("../../data/country_codes.csv")
influenza <- read.csv("../../data/influenza_activity.csv")
influenza <- influenza[,c(1,2,3,4,5,20)]
coords <- read.csv("../../data/processed/country-capitals.csv")
colnames(influenza)

files <- list.files(path = path, pattern = ".csv", 
                    all.files = FALSE, full.names = FALSE,
                    recursive = FALSE, ignore.case = FALSE,
                    include.dirs = FALSE, no.. = FALSE)
plc_holder <- data.frame(Date=as.Date(character()),
                         File=character(), 
                         User=character(), 
                         stringsAsFactors=FALSE) 
for (file in files) 
# insert code to process dataframe
{ 
  print("Processing %s" %--% file)
  data <- read.csv("%s/%s" %--% c(path, file))
  
  
  head(data)
  #head(country_code)
  head(plc_holder)
  #head(coords)
  plc_holder <- rbind(plc_holder, data)
  
}

write.csv(plc_holder, "../../data/processed/noaa/%s" %--% c("joined_remote.csv"))
