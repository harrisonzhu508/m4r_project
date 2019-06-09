options(java.parameters = "- Xmx1024m")
source("./utils.R")
source("./bart_model.R")
library(bartMachine)
library(data.tree)
library(matrixStats)
library(dplyr)
library(logging)
basicConfig()

# global parameters: dimension
if (!file.exists("./predictions/prediction_weekly_2019.csv")) {
  loginfo("Prediction file doesn't exist, generating new file")
  results <- data.frame(matrix(ncol = 7, nrow = 0)) 
  colnames(results) <- c("year", "week", "name", "crop",
                        "prediction_mean", "prediction_lower_95", 
                        "prediction_upper_95")
  write.csv(results, "./predictions/prediction_weekly_2019.csv", row.names = FALSE)
}

loginfo("Overwriting existing prediction file")
results <- read.csv("./predictions/prediction_weekly_2019.csv")

args <- as.double(commandArgs(TRUE))
test.week.beginning <- args[1]
test.week.end <- args[2]

crops <- c("spring_barley","winter_wheat")
test.years <- 2019

for (crop in crops)
{
  loginfo(crop)
  loginfo("Selecting Features")
  features <- c("name", "year", "week", 
                "Minimum_temperature_height_above_ground_6_Hour_Interval_mean",
                "Maximum_temperature_height_above_ground_6_Hour_Interval_mean",
                "Pressure_surface_mean", "total_precipitation", 
                "Volumetric_Soil_Moisture_Content_depth_below_surface_layer_5_cm_mean",
                "Volumetric_Soil_Moisture_Content_depth_below_surface_layer_150_cm_mean",
                "Volumetric_Soil_Moisture_Content_depth_below_surface_layer_25_cm_mean",
                "longitude", "latitude")
  num_features <- length(features)
  
  noaa.test <- read.csv("../climatic_sweden_regional_yield_weekly_model_test.csv")
  noaa.test$total_precipitation <- noaa.test$Precipitation_rate_surface_6_Hour_Average_mean*3600*24*7
  
  # filter out and clean data according to week, years and features
  loginfo("num_features %s", num_features)
  test.data <- select(noaa.test, features)
  
  for (test.week in test.week.beginning:test.week.end)
  {
    test.data.week <- test.data[test.data$week <= test.week
                                 & test.data$week >= 1,]
    test.data.week <- test.data.week[test.data.week$year %in% test.years,]
    
    # stack data
    test.stacked <- stack.test.week(test.data.week, features)
    
    load("../saved/%s/weekly_%s_%s.RData" %--% c(crop, test.years, test.week))
    predictions <- predict.bart.week(model, test.stacked)

    tmp <- data.frame(
      test.stacked$year,
      test.week,
      test.stacked$name,
      crop,
      predictions[[2]],
      predictions[[3]]$interval[,1],
      predictions[[3]]$interval[,2]
    )
    colnames(tmp) <- c("year", "week", "name", "crop", 
                        "prediction_mean", "prediction_lower_95", 
                        "prediction_upper_95")
    if (test.week %in% results$week & crop %in% results[results$week == test.week,]$crop) {
      results[results$crop == crop & results$week == test.week,] <- tmp
    }
    else {
      results <- rbind(results, tmp)
    }

    jpeg("../saved/%s/plots/prediction_%s-%s.jpg" %--% c(crop, test.week, test.years) ,width = 1000, height = 1000)
    plot(c(1:6), predictions[[2]], ylim= c(0,8000), main="2019 %s RMSE Training: %s"%--% c(crop, model$rmse_train))
    text(c(1:6), predictions[[2]], labels=predictions[[1]], cex= 0.7, pos=3)
    arrows(x0=c(1:6), y0=predictions[[3]]$interval[,1], 
           x1=c(1:6), y1=predictions[[3]]$interval[,2], length=0.05, angle=90, code=3)
    dev.off()

    jpeg("../saved/%s/plots/importance_weekly_%s-%s.jpg" %--% c(crop, test.week, test.years) ,width = 1000, height = 1000)
    avg_var_props <- investigate_var_importance(model)
    dev.off()  
    
    drivers <- data.frame(
      "variable" = names(avg_var_props$avg_var_props),
      "average_inclusion_proportion" = unname(avg_var_props$avg_var_props),
      "sd_inclusion_proportion" = unname(avg_var_props$sd_var_props)
    )
    write.csv(drivers, "../saved/%s/plots/importance_weekly_%s-%s.csv" %--% c(crop, test.week, test.years), row.names = FALSE)
  }
}

write.csv(results, "./predictions/prediction_weekly_2019.csv", row.names = FALSE)