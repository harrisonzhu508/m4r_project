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
results <- data.frame(matrix(ncol = 5, nrow = 0)) 
colnames(results) <- c("val.year", "val.month", "se", "n", "crop")

args <- as.double(commandArgs(TRUE))
year <- args[1]

#results <- read.csv("CV_results.csv")

for (val.year in year:year)
{
  loginfo("Validation Year %s", val.year)
  for (crop in crops)
  {
    loginfo('Crop: %s ', crop)
    features <- c("name", "year", "month", 
                  "ndvi_mean", "gvi_mean", "gpp_mean",
                  "Minimum_temperature_height_above_ground_6_Hour_Interval_mean",
                  "Maximum_temperature_height_above_ground_6_Hour_Interval_mean",
                  "Pressure_surface_mean", "total_precipitation", 
                  "Volumetric_Soil_Moisture_Content_depth_below_surface_layer_5_cm_mean",
                  "Volumetric_Soil_Moisture_Content_depth_below_surface_layer_150_cm_mean",
                  "Volumetric_Soil_Moisture_Content_depth_below_surface_layer_25_cm_mean",
                  "longitude.y", "latitude.y", "%s_yield.y" %--% crop)
    num_features <- length(features)
    
    ndvi.train <- read.csv("../sweden_regional_yield_monthly_model_train.csv")
    noaa.train <- read.csv("../climatic_sweden_regional_yield_monthly_model_train.csv")
    ndvi.train <- ndvi.train[order(ndvi.train$name, ndvi.train$year, ndvi.train$month),]
    invisible(capture.output(ndvi.train <- fill.missing.month(ndvi.train, year_1=2000, year_2=2018)))
    
    ndvi.train <- ndvi.train[ndvi.train$year == val.year,]
    noaa.train <- noaa.train[noaa.train$year == val.year,]
    
    plc_holder <- merge(ndvi.train, noaa.train, by = c("name", "year", "month"), all = TRUE)
    plc_holder <- select(plc_holder, features)
    
    #print("num_features %s" %--% c(num_features))
    colnames(plc_holder)[c(num_features-2, num_features-1, num_features)] <- c("longitude", "latitude", "yield")
    features[c(num_features-2, num_features-1, num_features)] <- c("longitude", "latitude", "yield")    
    val.data <- plc_holder
    val.data <- val.data[val.data$yield != 0 & !is.na(val.data$ndvi_mean),]
    
    # training
    #cl <- makeCluster(4)
    #registerDoParallel(cl)
    #print("Begin Validation")
    #foreach (val.month=2:5, .packages = c("bartMachine", "matrixStats", "dplyr"), .combine = rbind) %dopar%
    #{
    for (val.month in 2:5)
    {
      
      loginfo("Month: %s", val.month)
      val.data.month <- val.data[val.data$month <= val.month 
                             & val.data$month >= 2,]
      val.data.month <- val.data.month[val.data.month$year %in% val.year,]
      # stack data
      invisible(capture.output(val.stacked <- stack.train(val.data.month, features)))
      val.stacked <- val.stacked[!is.na(val.stacked$Minimum_temperature_height_above_ground_6_Hour_Interval_mean_2),]
      val.x <- val.stacked[,!(names(val.stacked) %in% c("yield"))]
      val.y <- val.stacked$yield
      
      # produce plots
      load("../saved/%s/%s_%s.RData" %--% c(crop, val.year, val.month))
      predictions <- predict.bart.month(model, val.x)
      prediction.rmse <- sqrt(mean((predictions[[2]] - val.stacked$yield)^2))
      se <- sum((predictions[[2]] - val.stacked$yield)^2)
      n <- length(val.stacked$yield)
      results <- rbind(results, data.frame(val.year, val.month, se, n, crop))
      
      jpeg("../saved/%s/plots/validation_%s-%s.jpg" %--% c(crop, val.month, val.year) ,width = 1000, height = 1000)
      plot(val.y, predictions[[2]], ylim= c(0,8000), xlim=c(0,8000),
                    main="2019 %s RMSE Training: %s\n RMSE Prediction: %s" %--% c(crop, model$rmse_train, prediction.rmse))
      abline(a = 0, b=1)
      text(val.y, predictions[[2]], labels=predictions[[1]], cex= 0.7, pos=3)
      arrows(x0=val.y, y0=predictions[[3]]$interval[,1], 
             x1=val.y, y1=predictions[[3]]$interval[,2], length=0.05, angle=90, code=3)
      dev.off()
      
      jpeg("../saved/%s/plots/importance_%s-%s.jpg" %--% c(crop, val.month, val.year) ,width = 1000, height = 1000)
      investigate_var_importance(model)
      dev.off()  
      
    }
    #stopCluster(cl)
  }
}

write.csv(results, "CV_results.csv", row.names = FALSE)
