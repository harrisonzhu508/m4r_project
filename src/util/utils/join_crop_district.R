###
# datasets:
# - 
# - 
# join and process the dataframes so that
# 1. We obtain corn data dataframe with crop data reduced with sum, grouped by agriculture districts, year
# and state
# also add in FIPS code for each state (since each agriculture district may have the same name)
# 2.  
###
dir <- getwd()
print(dir)
setwd(dir)

# load required packages
library(sqldf)
source("./data_process.R")

corn_data <- read.csv("../../data/corn_data/1979-2018_corn.csv")
state_fips <- read.csv("../../data/state_county_info/stateUSPS.csv")

# capitalise state_fips
state_fips <- sapply(state_fips, toupper) 

length(unique(corn_data[corn_data$Year == 1979,]$Ag_District))
length(unique(corn_data[corn_data$Year==2016,]$Ag_District))

length(unique(corn_data_reduced$Ag_District))
#colnames(corn_data)[c(1,2,3,4)] <- c("Year", "State", "Ag_District", "Crop_Yield")

# sum up agriculture yield
#corn_data_reduced <- sqldf("
#      SELECT *, AVG(Value) AS Crop_Yield
#      FROM corn_data AS c
#      GROUP BY c.State, c.Ag_District, c.Year
#")
#
#corn_data_reduced <- corn_data_reduced[, -c(6,7,9)]

# outer join with state fips code
corn_data_reduced <- merge(x = corn_data, y = state_fips[,c(2,3,4)], 
                           by.x = "State", by.y = "Name", all = TRUE)
corn_data_reduced <- corn_data_reduced[order(corn_data_reduced$Year),]
head(corn_data_reduced)
write.csv(corn_data_reduced, "../../data/corn_data/ag_district_corn_processed.csv")
