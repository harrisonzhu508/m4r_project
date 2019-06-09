#load utils
source("./data_process.R")
library(sqldf)
library(dplyr)

# temperature and precipitation wrangling
covariates <- c("erc", "pr", "rmin", "tmmx", "tmmn", "etr", "eto")
#covariates <- c("etr", "eto")
#covariates <- c("ee_mean_evap")
dist_mapping <- read.csv("../../data/state_county_info/ag_district_county_mapping_2017.csv")
path <- "../../data_weekly"


#first filter the dates
# skip if already done
for (covariate in covariates)
{
  print("Processing: %s" %--% covariate)
  files <- list.files(path = "%s/%s" %--% c(path, covariate), pattern = ".csv", all.files = FALSE,
                      full.names = FALSE, recursive = FALSE,
                      ignore.case = FALSE, include.dirs = FALSE, no.. = FALSE)
  for (file in files) 
  {
    print("Processing:%s"%--%file)
    data <- read.csv("%s/%s/%s" %--% c(path, covariate, file))
    
    #fix the column names and data values
    data$name <- toupper(data$name)
    data$month <- as.character(data$month)
    data$year <- substr(data$month, 1, 4)
    data$month <- substr(data$month, 6, 7)
    head(data)
    
    #rename column names
    colnames(data) <- c(covariate, "month", "name", "STATEFP", "year")
    write.csv(data, "%s/%s/%s" %--% c(path, covariate, file))
  }
}

#put the years together
for (covariate in covariates)
{
  print("Processing: %s" %--% covariate)
  files <- list.files(path = "%s/%s" %--% c(path, covariate), pattern = ".csv", all.files = FALSE,
                      full.names = FALSE, recursive = FALSE,
                      ignore.case = FALSE, include.dirs = FALSE, no.. = FALSE)
  data_plcholder <- data.frame(Date=as.Date(character()),
                               File=character(), 
                               User=character(), 
                               stringsAsFactors=FALSE) 
  for (file in files) 
  {
    print("Processing:%s"%--%file)
    data <- read.csv("%s/%s/%s" %--% c(path, covariate, file))
    
    head(data)
    head(dist_mapping_2017)
    #fix the column names and data values
    data_merged <- merge(data, dist_mapping_2017, by.x = c("name", "STATEFP"), by.y = c("County", "State_FIPS"))
    head(data_merged)
    
    # sum up agriculture yield
    data_merged <- select(data_merged, c("State", "STATEFP","USPS_Code","Ag.District", "year", "month", covariate))
    colnames(data_merged) <- c("State", "STATEFP", "USPS_Code", "Ag_District", "Year", "month", "value_tmp")
    data_merged <- sqldf("
                         SELECT *, SUM(value_tmp)/COUNT(value_tmp) AS value
                         FROM data_merged AS t
                         GROUP BY t.State, t.Ag_district, t.Year
                         ")    
    data_merged <- data_merged[,-7]
    data_plcholder <- rbind(data_plcholder, data_merged)
  }
  write.csv(data_plcholder, "%s/%s/district/%s.csv" %--% c(path, covariate, covariate))
}


data_merged <- read.csv("%s/erc/district/erc.csv" %--% c(path, covariate))[,-1]
colnames(data_merged)[7] <- "erc"
# Merges features together
for (covariate in covariates[-1])
{
  print("Processing: %s" %--% covariate)
  file <- list.files(path = "%s/%s/district" %--% c(path, covariate), pattern = ".csv", all.files = FALSE,
                      full.names = FALSE, recursive = FALSE,
                      ignore.case = FALSE, include.dirs = FALSE, no.. = FALSE)
  print("Processing:%s"%--%file)
  data <- read.csv("%s/%s/district/%s" %--% c(path, covariate, file))
  
  data_merged <- cbind(data_merged, data$value)
  colnames(data_merged)[ncol(data_merged)] <- covariate
}

# finally merge the NVDI in 
data_ndvi <- read.csv("%s/NDVI/district/NDVI.csv" %--% c(path))
data_merged <- merge(data_merged, data_ndvi, by.x = c("USPS_Code", "Ag_District", "Year", "month"), by.y = c("USPS_Code", "Ag_District", "Year", "month"),
                     all = TRUE)
data_merged <- select(data_merged, c("State.x", "STATEFP.x","USPS_Code","Ag_District", "Year", "month", covariates, "value"))
colnames(data_merged) <- c("State", "STATEFP", "USPS_Code", "Ag_District", "Year", "month", covariates, "NDVI")
write.csv(data_merged, "%s/clean_data.csv" %--% c(path))

#join up with corn data 
corn_data <- read.csv("../../data/corn_data/corn_with_coords.csv")
corn_data <- corn_data[corn_data$Year>=1980,]
data_merged <- read.csv("%s/clean_data.csv" %--% c(path))
data_merged <- merge(corn_data, data_merged, by.x = c("USPS_Code", "Ag_District", "Year"), by.y = c("USPS_Code", "Ag_District", "Year"),
                     all = TRUE)
data_merged <- select(data_merged, c("State.x", "State_FIPS","USPS_Code","Ag_District","Lat","Long", "Year", "month", covariates, "NDVI", "Crop_Yield"))
colnames(data_merged) <- c("State", "STATE_FIPS", "USPS_Code", "Ag_District", "Lat", "Long", "Year", "month", covariates, "NDVI", "Crop_Yield")

head(corn_data)
head(data_merged)
write.csv(data_merged, "%s/clean_data_corn.csv" %--% c(path))

