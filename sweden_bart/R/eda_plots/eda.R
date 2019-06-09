source("./utils.R")
library(dplyr)

crop <- "spring_barley"
print(crop)
print("Selecting Features")
features <- c("name", "year", "month", 
              "ndvi_mean", "gvi_mean", "gpp_mean",
              "Minimum_temperature_height_above_ground_6_Hour_Interval_mean",
              "Maximum_temperature_height_above_ground_6_Hour_Interval_mean",
              "Pressure_surface_mean", "Precipitation_rate_surface_6_Hour_Average_mean", 
              "Volumetric_Soil_Moisture_Content_depth_below_surface_layer_5_cm_mean",
              "Volumetric_Soil_Moisture_Content_depth_below_surface_layer_150_cm_mean",
              "Volumetric_Soil_Moisture_Content_depth_below_surface_layer_25_cm_mean",
              "longitude.x", "latitude.x",
              "%s_yield.x")%--%crop
num_features <- length(features)

ndvi.train <- read.csv("../sweden_regional_yield_monthly_model_train.csv")
noaa.train <- read.csv("../climatic_sweden_regional_yield_monthly_model_train.csv")


ndvi.train <- fill.missing.month(ndvi.train, year_1=2000, year_2=2018)

ndvi.train <- ndvi.train[order(ndvi.train$name, ndvi.train$year, ndvi.train$month),]
plc_holder <- merge(ndvi.train, noaa.train, by = c("name", "year", "month"), all = TRUE)
plc_holder <- select(plc_holder, features)

print("num_features %s" %--% c(num_features))
colnames(plc_holder)[c(num_features-2, num_features-1, num_features)] <- c("longitude", "latitude", "yield")
features[c(num_features-2, num_features-1, num_features)] <- c("longitude", "latitude", "yield")
train.data <- plc_holder
train.data <- train.data[train.data$yield != 0 & !is.na(train.data$ndvi_mean),]

subset <- train.data[train.data$name == "Skåne",]

# Get some colors
library(corrplot)
corrplot(cor(subset[,-c(1,2,3, ncol(subset)-1, ncol(subset))]))

corrplot(cor(subset[,-c(1,2,3, ncol(subset))]))

par(mfrow = c(2,3))
for (region in sort(unique(train.data$name)))
{
  yield_study <- train.data[train.data$name == region,]
  plot(yield_study$year,  yield_study$yield, type = "l", main = region)
  points(yield_study$year, yield_study$yield)
}

#drought analysis
for (month in unique(train.data$month))
{
  jpeg("./precipitation_month_%s.jpg" %--% c(month) ,width = 700, height = 700)
  par(mfrow = c(2,3))
  for (region in sort(unique(train.data$name)))
  {
    yield_study <- train.data[train.data$name == region & train.data$month==month,]
    plot(yield_study$year, yield_study$Precipitation_rate_surface_6_Hour_Average_mean*3600*24*30, type = "l", main = region,
         ylab="Precipitation")
    points(yield_study$year, yield_study$Precipitation_rate_surface_6_Hour_Average_mean*3600*24*30)
  }
  dev.off()
}

 #drought analysis
par(mfrow = c(3,3))
for (year in 2010:2018)
{
  yield_study <- data[data$region == "Skåne" & data$year == year,]
  yield_study <- yield_study[order(yield_study$month),]
  plot(yield_study$month,  yield_study$Rainf_tavg, type = "l", main = year)
}