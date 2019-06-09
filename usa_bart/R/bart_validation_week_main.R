#options(java.parameters = "- Xmx1024m")
options(java.parameters = "-Xmx5g")
source("./utils.R")
source("./bart_model.R")
library(bartMachine)
library(matrixStats)
library(dplyr)
library(doParallel)
library(logging)
basicConfig()

crops <- c("spring_barley","winter_wheat")

#save MSEs
#results <- data.frame(matrix(ncol = 5, nrow = 0)) 
#colnames(results) <- c("val.year", "val.week", "se", "n", "crop")

args <- as.double(commandArgs(TRUE))
year <- args[1]

for (val.year in year:year)
{
  loginfo("Validation Year %s", val.year)
  for (crop in crops)
  {
    loginfo('Crop: %s ', crop)
    features <- c("name", "year", "week", 
                  "Minimum_temperature_height_above_ground_6_Hour_Interval_mean",
                  "Maximum_temperature_height_above_ground_6_Hour_Interval_mean",
                  "Pressure_surface_mean", "total_precipitation", 
                  "Volumetric_Soil_Moisture_Content_depth_below_surface_layer_5_cm_mean",
                  "Volumetric_Soil_Moisture_Content_depth_below_surface_layer_150_cm_mean",
                  "Volumetric_Soil_Moisture_Content_depth_below_surface_layer_25_cm_mean",
                  "longitude", "latitude", "%s_yield" %--% crop)
    num_features <- length(features)
    
    noaa.train <- read.csv("../climatic_sweden_regional_yield_weekly_model_train.csv")
    noaa.train$total_precipitation <- noaa.train$Precipitation_rate_surface_6_Hour_Average_mean*3600*24*7
    
    noaa.train <- noaa.train[noaa.train$year == val.year,]
    
    plc_holder <- select(noaa.train, features)
    
    #print("num_features %s" %--% c(num_features))
    colnames(plc_holder)[num_features] <- "yield"
    val.data <- plc_holder
    val.data <- val.data[val.data$yield != 0,]
    val.data <- val.data[!is.na(val.data),]
    
    for (val.week in 2:30)
    {
      
      loginfo("Year %s, Week: %s", val.year, val.week)
      val.data.week <- val.data[val.data$week <= val.week 
                                 & val.data$week >= 1,]
      val.data.week <- val.data.week[val.data.week$year %in% val.year,]
      # stack data
      invisible(capture.output(val.stacked <- stack.train.week(val.data.week, features)))
      val.x <- val.stacked[,!(names(val.stacked) %in% c("yield"))]
      val.y <- val.stacked$yield
      
      # produce plots
      load("../saved/%s/weekly_%s_%s.RData" %--% c(crop, val.year, val.week))
      predictions <- predict.bart.week(model, val.x)
      prediction.rmse <- sqrt(mean((predictions[[2]] - val.stacked$yield)^2))
      #se <- sum((predictions[[2]] - val.stacked$yield)^2)
      #n <- length(val.stacked$yield)
      #results <- rbind(results, data.frame(val.year, val.week, se, n, crop))
      
      jpeg("../saved/%s/plots/weekly_validation_%s-%s.jpg" %--% c(crop, val.week, val.year) ,width = 1000, height = 1000)
      plot(val.y, predictions[[2]], ylim= c(0,8000), xlim=c(0,8000),
                    main="%s: Year %s RMSE Training: %s\n RMSE Prediction: %s" %--% c(crop, val.year, model$rmse_train, prediction.rmse))
      abline(a = 0, b=1)
      text(val.y, predictions[[2]], labels=predictions[[1]], cex= 0.7, pos=3)
      arrows(x0=val.y, y0=predictions[[3]]$interval[,1], 
             x1=val.y, y1=predictions[[3]]$interval[,2], length=0.05, angle=90, code=3)
      dev.off()
      
      #jpeg("../saved/%s/plots/weekly_importance_%s-%s.jpg" %--% c(crop, val.week, val.year) ,width = 1000, height = 1000)
      #investigate_var_importance(model)
      #dev.off()  
      rm(model)
    }
  }
}

#write.csv(results, "CV_results_weekly.csv", row.names = FALSE)