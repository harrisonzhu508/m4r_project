options(java.parameters = "- Xmx1024m")
source("./utils.R")
source("./bart_model.R")
library(bartMachine)
library(data.tree)
library(matrixStats)
library(dplyr)
# global parameters: dimension
test.years <- c(2017, 2018)

# global parameters: dimension
if (!file.exists("./predictions/BART_prediction_monthly_2019.csv")) {
  loginfo("Prediction file doesn't exist, generating new file")
  results <- data.frame(matrix(ncol = 7, nrow = 0)) 
  colnames(results) <- c("Year", "month", "State", "Ag_District",
                        "prediction_mean", "prediction_lower_95", 
                        "prediction_upper_95")
  write.csv(results, "./predictions/BART_prediction_monthly_2019.csv", row.names = FALSE)
}

test.month.beginning <- 2
test.month.end <- 10

loginfo("Overwriting existing prediction file")
results <- read.csv("./predictions/BART_prediction_monthly_2019.csv")

print("Selecting Features")
features <- c("State", "Ag_District", "Year", "month", 
              "erc", "pr", "rmin", "tmmx", 
              "etr", "eto", "NDVI", 
              "Lat", "Long")
num_features <- length(features)

data <- read.csv("../../data/usa/data.csv")

plc_holder <- select(data, features)

# filter out and clean data according to month, years and features
print("num_features %s" %--% c(num_features))
test.data <- plc_holder
test.data <- test.data[!is.na(test.data$NDVI),]

for (test.month in test.month.beginning:test.month.end)
{
  test.data.month <- test.data[test.data$month <= test.month & test.data$month >= 2,]
  test.data.month <- test.data.month[test.data.month$Year %in% test.years,]
  
  # stack data
  test.stacked <- stack.test(test.data.month, features)
  
  load("./predictions/BART_%s.RData" %--% c(test.month))
  predictions <- predict.bart.month(model, test.stacked)
  
  tmp <- data.frame(
    test.stacked$Year,
    test.month,
    test.stacked$State,
    test.stacked$Ag_District,
    predictions[[2]],
    predictions[[3]]$interval[,1],
    predictions[[3]]$interval[,2]
  )
  
  colnames(tmp) <- c("Year", "month", "State", "Ag_District",
                      "prediction_mean", "prediction_lower_95", 
                      "prediction_upper_95")
  if (test.month %in% results$month) {
    results[results$month == test.month,] <- tmp
  }
  else {
    results <- rbind(results, tmp)
  }
  
  jpeg("./predictions/BART_prediction_%s-%s.jpg" %--% c(test.month, test.years) ,width = 1000, height = 1000)
  #plot(c(1:6), predictions[[2]], ylim= c(0,8000), main="2017-2018 RMSE Training: %s"%--%model$rmse_train)
  #text(c(1:6), predictions[[2]], labels=predictions[[1]], cex= 0.7, pos=3)
  #arrows(x0=c(1:6), y0=predictions[[3]]$interval[,1], 
  #       x1=c(1:6), y1=predictions[[3]]$interval[,2], length=0.05, angle=90, code=3)
  #dev.off()

  jpeg("./predictions/BART_importance_monthly_%s-%s.jpg" %--% c(test.month, test.years) ,width = 1000, height = 1000)
  avg_var_props <- investigate_var_importance(model)
  dev.off()  
  
  drivers <- data.frame(
    "variable" = names(avg_var_props$avg_var_props),
    "average_inclusion_proportion" = unname(avg_var_props$avg_var_props),
    "sd_inclusion_proportion" = unname(avg_var_props$sd_var_props)
  )
  write.csv(drivers, "./predictions/BART_importance_monthly_%s-%s.csv" %--% c(test.month, test.years), row.names = FALSE)
}


write.csv(results, "./predictions/BART_prediction_monthly_2019.csv", row.names = FALSE)
