options(java.parameters = "- Xmx1024m")
source("./utils.R")
source("./bart_model.R")
library(bartMachine)
library(matrixStats)
library(dplyr)
library(doParallel)
library(logging)
basicConfig()

crops <- c("spring_barley","winter_wheat")

args <- as.double(commandArgs(TRUE))
year <- args[1]
week_beginning <- args[2]
week_end <- args[3]


for (omit.year in year:year)
{
  loginfo("Omitting year: %s", omit.year)
  for (crop in crops)
  {
    loginfo("Crop: %s", crop)
    #print("Selecting Features")
    features <- c("name", "year", "week", 
                  "Minimum_temperature_height_above_ground_6_Hour_Interval_mean",
                  "Maximum_temperature_height_above_ground_6_Hour_Interval_mean",
                  "Pressure_surface_mean", "total_precipitation", 
                  "Volumetric_Soil_Moisture_Content_depth_below_surface_layer_5_cm_mean",
                  "Volumetric_Soil_Moisture_Content_depth_below_surface_layer_150_cm_mean",
                  "Volumetric_Soil_Moisture_Content_depth_below_surface_layer_25_cm_mean",
                  "longitude", "latitude",
                  "%s_yield")%--%crop
    num_features <- length(features)
    
    noaa.train <- read.csv("../climatic_sweden_regional_yield_weekly_model_train.csv")
    noaa.train$total_precipitation <- noaa.train$Precipitation_rate_surface_6_Hour_Average_mean*3600*24*7
    
    # omit year
    noaa.train <- noaa.train[noaa.train$year != omit.year,]
    
    plc_holder <- select(noaa.train, features)
    
    
    colnames(plc_holder)[num_features] <- "yield"
    train.data <- plc_holder
    train.data <- train.data[train.data$yield != 0,]
    
    loginfo("num_features %s", num_features)
    # training
    
    cl <- makeCluster(4)
    registerDoParallel(cl)
    loginfo("Begin Training in Parallel Year: %s", omit.year)
    foreach (week=2:30, .packages = c("bartMachine", "matrixStats", "dplyr", "logging")) %dopar%
    {
      #loginfo("Week %s", week)
      invisible(capture.output(
        model <- train.model.week(week, omit.year, 
                  train.data, features = features, save_flag=TRUE)))
    }
    stopCluster(cl)
  }
  
}
