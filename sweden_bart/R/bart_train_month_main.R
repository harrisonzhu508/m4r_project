options(java.parameters = "- Xmx1024m")
source("./utils.R")
source("./bart_model.R")
library(bartMachine)
library(matrixStats)
library(dplyr)
library(doParallel)
library(logging)
basicConfig()

args <- as.double(commandArgs(TRUE))
year <- args[1]

crops <- c("spring_barley")
for (omit.year in year:year)
{
  loginfo("Omitting year: %s", omit.year)
  for (crop in crops)
  {
    loginfo("Crop: %s", crop)
    #print("Selecting Features")
    features <- c("name", "year", "month",
                  "ndvi_mean", "gvi_mean", "gpp_mean",
                  "Minimum_temperature_height_above_ground_6_Hour_Interval_mean",
                  "Maximum_temperature_height_above_ground_6_Hour_Interval_mean",
                  "Pressure_surface_mean", "total_precipitation",
                  "Volumetric_Soil_Moisture_Content_depth_below_surface_layer_5_cm_mean",
                  "Volumetric_Soil_Moisture_Content_depth_below_surface_layer_150_cm_mean",
                  "Volumetric_Soil_Moisture_Content_depth_below_surface_layer_25_cm_mean",
                  "longitude.x", "latitude.x",
                  "%s_yield.x")%--%crop
    num_features <- length(features)
    
    ndvi.train <- read.csv("../../data/sweden/sweden_regional_yield_monthly_model_train.csv")
    noaa.train <- read.csv("../../data/sweden/climatic_sweden_regional_yield_monthly_model_train.csv")
    noaa.train$total_precipitation <- noaa.train$Precipitation_rate_surface_6_Hour_Average_mean*3600*24*30
    
    invisible(capture.output(ndvi.train <- fill.missing.month(ndvi.train, year_1=2000, year_2=2018)))
    
    # omit year
    ndvi.train <- ndvi.train[ndvi.train$year != omit.year,]
    noaa.train <- noaa.train[noaa.train$year != omit.year,]
    
    ndvi.train <- ndvi.train[order(ndvi.train$name, ndvi.train$year, ndvi.train$month),]
    plc_holder <- merge(ndvi.train, noaa.train, by = c("name", "year", "month"), all = TRUE)
    plc_holder <- select(plc_holder, features)
    
    loginfo("num_features %s", num_features)
    colnames(plc_holder)[c(num_features-2, num_features-1, num_features)] <- c("longitude", "latitude", "yield")
    features[c(num_features-2, num_features-1, num_features)] <- c("longitude", "latitude", "yield")
    train.data <- plc_holder
    train.data <- train.data[train.data$yield != 0 & !is.na(train.data$ndvi_mean),]
    train.data <- train.data[train.data$year!= 2018,]
    
    # training
    cl <- makeCluster(4)
    registerDoParallel(cl)
    loginfo("Begin Training in Parallel")
    foreach (month=2:10, .packages = c("bartMachine", "matrixStats", "dplyr", "logging")) %dopar%
    {
      loginfo("Month %s", month)
      invisible(capture.output(model <- train.model.month(month, omit.year, train.data, features = features, save_flag=TRUE)))
    }
    stopCluster(cl)
  }
  
}
