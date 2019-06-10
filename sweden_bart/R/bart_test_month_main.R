options(java.parameters = "- Xmx1024m")
source("./utils.R")
source("./bart_model.R")
library(bartMachine)
library(data.tree)
library(matrixStats)
library(dplyr)
# global parameters: dimension
crops <- c("spring_barley")
test.years <- 2017

# global parameters: dimension
if (!file.exists("./predictions/prediction_monthly_2017.csv")) {
  loginfo("Prediction file doesn't exist, generating new file")
  results <- data.frame(matrix(ncol = 7, nrow = 0)) 
  colnames(results) <- c("year", "month", "name", "crop", 
                         "prediction_mean", "prediction_lower_95", 
                         "prediction_upper_95")
  write.csv(results, "./predictions/prediction_monthly_2017.csv", row.names = FALSE)
}


args <- as.double(commandArgs(TRUE))
test.month.beginning <- 2
test.month.end <- 10

loginfo("Overwriting existing prediction file")
results <- read.csv("./predictions/prediction_monthly_2017.csv")

for (crop in crops)
{
  print("Selecting Features")
  features <- c("name", "year", "month", 
                "ndvi_mean", "gvi_mean", "gpp_mean",
                "Minimum_temperature_height_above_ground_6_Hour_Interval_mean",
                "Maximum_temperature_height_above_ground_6_Hour_Interval_mean",
                "Pressure_surface_mean", "total_precipitation", 
                "Volumetric_Soil_Moisture_Content_depth_below_surface_layer_5_cm_mean",
                "Volumetric_Soil_Moisture_Content_depth_below_surface_layer_150_cm_mean",
                "Volumetric_Soil_Moisture_Content_depth_below_surface_layer_25_cm_mean",
                "longitude.x", "latitude.x")
  num_features <- length(features)
  
  ndvi.test <- read.csv("../../data/sweden/sweden_regional_yield_monthly_model_train.csv")
  noaa.test <- read.csv("../../data/sweden/climatic_sweden_regional_yield_monthly_model_train.csv")
  ndvi.test <- ndvi.test[order(ndvi.test$name, ndvi.test$year, ndvi.test$month),]
  
  plc_holder <- merge(ndvi.test, noaa.test, by = c("name", "year", "month"), all = TRUE)
  plc_holder <- select(plc_holder, features)
  
  # filter out and clean data according to month, years and features
  print("num_features %s" %--% c(num_features))
  colnames(plc_holder)[c(num_features-1, num_features)] <- c("longitude", "latitude")
  features[c(num_features-1, num_features)] <- c("longitude", "latitude")
  test.data <- plc_holder
  test.data <- test.data[!is.na(test.data$ndvi_mean),]
  
  for (test.month in test.month.beginning:test.month.end)
  {
    test.data.month <- test.data[test.data$month <= test.month & test.data$month >= 2,]
    test.data.month <- test.data.month[test.data.month$year %in% test.years,]
    
    # stack data
    test.stacked <- stack.test(test.data.month, features)
    
    load("../saved/%s/%s_%s.RData" %--% c(crop, test.years, test.month))
    predictions <- predict.bart.month(model, test.stacked)
    
    tmp <- data.frame(
      test.stacked$year,
      test.month,
      test.stacked$name,
      crop,
      predictions[[2]],
      predictions[[3]]$interval[,1],
      predictions[[3]]$interval[,2]
    )
    
    colnames(tmp) <- c("year", "month", "name", "crop", 
                       "prediction_mean", "prediction_lower_95", 
                       "prediction_upper_95")
    if (test.month %in% results$month & crop %in% results[results$month == test.month,]$crop) {
      results[results$crop == crop & results$month == test.month,] <- tmp
    }
    else {
      results <- rbind(results, tmp)
    }
    
    jpeg("../saved/%s/plots/prediction_%s-%s.jpg" %--% c(crop, test.month, test.years) ,width = 1000, height = 1000)
    plot(c(1:6), predictions[[2]], ylim= c(0,8000), main="2017 Spring Barley RMSE Training: %s"%--%model$rmse_train)
    text(c(1:6), predictions[[2]], labels=predictions[[1]], cex= 0.7, pos=3)
    arrows(x0=c(1:6), y0=predictions[[3]]$interval[,1], 
           x1=c(1:6), y1=predictions[[3]]$interval[,2], length=0.05, angle=90, code=3)
    dev.off()
    
    jpeg("./predictions/importance_monthly_%s-%s.jpg" %--% c(crop, test.month, test.years) ,width = 1000, height = 1000)
    avg_var_props <- investigate_var_importance(model)
    dev.off()  
    
    drivers <- data.frame(
      "variable" = names(avg_var_props$avg_var_props),
      "average_inclusion_proportion" = unname(avg_var_props$avg_var_props),
      "sd_inclusion_proportion" = unname(avg_var_props$sd_var_props)
    )
    write.csv(drivers, "./predictions/importance_monthly_%s-%s.csv" %--% c(crop, test.month, test.years), row.names = FALSE)
  }
}

write.csv(results, "./predictions/prediction_monthly_2017.csv", row.names = FALSE)
