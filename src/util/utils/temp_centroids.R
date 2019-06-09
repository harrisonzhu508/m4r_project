# load required packages
library(sqldf)
library(dplyr)
source("./data_process.R")
corn_data <- read.csv("../../data/corn_data/ag_district_corn_processed.csv")
centroids <- read.csv("../../data/state_county_info/ag_district_centroids.csv")
head(corn_data)
# outer join with longitudinal data
corn_data_reduced <- merge(x = corn_data, y = centroids, 
                           by.x = c("USPS_Code", "Ag_District"), by.y = c("State", "AgDistrict"), all = TRUE)

corn_data_reduced <- corn_data_reduced[, c(1,2,4,5,6,7,10,11)]

head(corn_data)
head(centroids)
head(corn_data_reduced)

corn_data_reduced <- corn_data_reduced[complete.cases(corn_data_reduced),]
colnames(corn_data_reduced) <- c("USPS_Code", "Ag_District", "State", "Year", "Crop_Yield", "State_FIPS" , "Lat", "Long")
write.csv(corn_data_reduced, "../../data/corn_data/corn_with_coords.csv")

# temperature and precipitation wrangling
covariates <- c("erc", "tmmx", "tmmn", "rmin", "pr")
#covariates <- c("ee_mean_evap")
dist_mapping <- read.csv("../../data/state_county_info/ag_district_county_mapping.csv")
path <- "../../data_weekly"

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
    data$name <- toupper(data$NAME)
    #head(data)
    data_merged <- merge(data, dist_mapping, by.x = c("name", "STATEFP"), by.y = c("County", "State_FIPS"))
    #head(data_merged)
    # sum up agriculture yield
    data_merged <- select(data_merged, c("State", "STATEFP","USPS_Code","Ag.District", "Year.x", "mean"))
    colnames(data_merged) <- c("State", "STATEFP", "USPS_Code", "Ag_District", "Year", "data")
    data_merged <- sqldf("
                       SELECT *, SUM(data)/COUNT(data) AS data
                       FROM data_merged AS t
                       GROUP BY t.State, t.Ag_district, t.Year
    ")
    #head(data_merged)
    data_merged <- data_merged[,-6]
    colnames(data_merged)[6] <- covariate
    write.csv(data_merged, "%s/%s/district/district_%s" %--% c(path, covariate, file))
  }
}

# concatinate all data
for (covariate in covariates)
{
  print("Processing: %s" %--% covariate)
  files <- list.files(path = "%s/%s/district" %--% c(path, covariate), pattern = ".csv", all.files = FALSE,
                      full.names = FALSE, recursive = FALSE,
                      ignore.case = FALSE, include.dirs = FALSE, no.. = FALSE)
  final_data <- read.csv("%s/%s/district/%s" %--% c(path, covariate, files[1]))
  for (file in files[2:length(files)]) 
  {
    print("Processing:%s"%--%file)
    data <- read.csv("%s/%s/district/%s" %--% c(path, covariate, file))
    final_data <- rbind(final_data, data)
  }
  write.csv(final_data, "%s/%s/all/concat_%s.csv" %--% c(path, covariate, covariate))
}

#join up with corn data 

corn_data <- read.csv("../../data/corn_data/corn_with_coords.csv")
covariate <- covariates[1]
files <- list.files(path = "%s/%s/all" %--% c(path, covariate), pattern = ".csv", all.files = FALSE,
                    full.names = FALSE, recursive = FALSE,
                    ignore.case = FALSE, include.dirs = FALSE, no.. = FALSE)
crop_climate <- read.csv("%s/%s/all/%s" %--% c(path, covariate, files[1]))
crop_climate <- sqldf("
            SELECT cd.Crop_Yield, cd.USPS_Code, cd.Ag_District, cd.Year, cd.Lat, cd.Long, cc.%s
            FROM corn_data cd
            INNER JOIN crop_climate cc ON cc.USPS_Code = cd.USPS_Code 
            AND cc.Ag_district = cd.Ag_District AND cc.Year = cd.Year
            GROUP BY cd.USPS_Code, cd.Ag_District, cd.Year
" %--% covariate)
head(crop_climate)

for (covariate in covariates[2:length(covariates)])
{
  print("Processing: %s" %--% covariate)
  files <- list.files(path = "%s/%s/all" %--% c(path, covariate), pattern = ".csv", all.files = FALSE,
                      full.names = FALSE, recursive = FALSE,
                      ignore.case = FALSE, include.dirs = FALSE, no.. = FALSE)
  data <- read.csv("%s/%s/all/%s" %--% c(path, covariate, files[1]))
  crop_climate <- sqldf("
                SELECT cc.*, data.%s
                FROM crop_climate cc
                LEFT JOIN data ON data.USPS_Code = cc.USPS_Code 
                AND data.Ag_district = cc.Ag_District AND data.Year = cc.Year
                GROUP BY cc.USPS_Code, cc.Ag_District, cc.Year
  " %--% covariate)
}

head(crop_climate)
write.csv(crop_climate, "%s/crop_climate.csv" %--% path)
