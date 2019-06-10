options(java.parameters = "- Xmx1024m")
source("./utils.R")
source("./bart_model.R")
library(bartMachine)
library(matrixStats)
library(dplyr)
library(doParallel)
library(logging)
basicConfig()

omit.years <- c(2014, 2017, 2018)
#print("Selecting Features")
features <- c("State", "Ag_District", "Year", "month", 
              "erc", "pr", "rmin", "tmmx", 
              "etr", "eto", "NDVI",
              "Lat", "Long", "Crop_Yield")
num_features <- length(features)

data <- read.csv("../../data/usa/data.csv")

# omit year
data <- data[!(data$Year %in% omit.years),]
data <- data[order(data$State, data$Ag_District, data$Year, data$month),]
data <- select(data, features)

loginfo("num_features %s", num_features)
train.data <- data

# training
cl <- makeCluster(4)
registerDoParallel(cl)
loginfo("Begin Training in Parallel")
foreach (month=2:10, .packages = c("bartMachine", "matrixStats", "dplyr", "logging")) %dopar%
{
  #loginfo("Month %s", month)
  invisible(capture.output(model <- train.model.month(month, train.data, features = features, save_flag=TRUE)))
}
stopCluster(cl)
