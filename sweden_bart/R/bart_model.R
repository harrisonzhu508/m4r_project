source("./utils.R")
library(matrixStats)
library(logging)
basicConfig()

train.model.month <- function(model.month,
                              model.year,
                              train.data, 
                              features,
                              save_flag=FALSE
                              )
# function to train BART for a specific month, year and data
# Args:
#
#   month
#   year
#   data
#
# Returns:
# 
#   model: trained BART model
{
  train.data <- train.data[train.data$month <= model.month 
                     & max(2, model.month - 8),]
  
  # stack dimensions
  train.stacked <- stack.train(train.data, features)
  train.stacked <- train.stacked[!is.na(train.stacked$Minimum_temperature_height_above_ground_6_Hour_Interval_mean_2),]
  train.x <- train.stacked[,!(names(train.stacked) %in% c("name", "year", "month", "yield"))]
  train.y <- train.stacked$yield
  
  
  
  if (NROW(train.x) != 0)
  {
    
    sink("/dev/null")
    model <- bartMachine(train.x, train.y, num_trees = 50, k=2, 
                         serialize = save_flag, num_iterations_after_burn_in = 2000, num_burn_in = 500)
    #model <- bart(train.x, train.y$yield, keeptrees=TRUE, keepevery=20L, nskip=1000, ndpost=2000, ntree=200, k=2)
    sink()
    if (save_flag == TRUE) {
      loginfo("Saving model")
      save(model, file = "../saved/%s/%s_%s.RData" %--% c(crop, model.year, model.month))
    }
  }
  return (model)
}

train.model.week <- function(model.week,
                              model.year,
                              train.data, 
                              features,
                              save_flag=FALSE
                              )
# function to train BART for a specific week, year and data
# Args:
#
#   week
#   year
#   data
#
# Returns:
# 
#   model: trained BART model
{
  train.data <- train.data[train.data$week <= model.week
                     & train.data$week >= 1,]
  
  # stack dimensions
  train.stacked <- stack.train.week(train.data, features)
  train.x <- train.stacked[,!(names(train.stacked) %in% c("name", "year", "week", "yield"))]
  train.y <- train.stacked$yield
  
  
  if (NROW(train.x) != 0)
  {
    
    invisible(capture.output(model <- bartMachine(train.x, train.y, num_trees = 50, k=2, 
                         serialize = save_flag,num_iterations_after_burn_in = 2000, num_burn_in = 500)))
    #model <- bart(train.x, train.y$yield, keeptrees=TRUE, keepevery=20L, nskip=1000, ndpost=2000, ntree=200, k=2)
    if (save_flag == TRUE) {
      loginfo("Saving model")
      save(model, file = "../saved/%s/weekly_%s_%s.RData" %--% c(crop, model.year, model.week))
    }
  }
  return (model)
}



predict.bart.month <- function(model, test.stacked)
{
  test.x <- subset(test.stacked, select = -c(name, year, month))
  posterior.mean <- predict(model, test.x)
  posterior.variance <- calc_prediction_intervals(model, test.x)
  
  return (list(test.stacked$name, posterior.mean, posterior.variance))
}

predict.bart.week <- function(model, test.stacked)
{
  test.x <- subset(test.stacked, select = -c(name, year, week))
  posterior.mean <- predict(model, test.x)
  posterior.variance <- calc_prediction_intervals(model, test.x)
  
  return (list(test.stacked$name, posterior.mean, posterior.variance))
}

#if (plot == TRUE) {
#  jpeg("../saved/%s/plots/%s-%s.jpg" %--% c(crop, month, year) ,width = 700, height = 583)
#  par(mfrow = c(1, 1), pty = "s")
#  plot(val.y$yield, posterior_mean, pch=19, xlim = c(2000,8000), 
#       ylim = c(2000, 8000), main = "%s-%s" %--% c(month, year))
#  text(val.y$yield, posterior_mean, labels=places, cex= 0.7, pos=3)
#  abline(a = 0, b=1)
#  # plot in 95% credible intervals (Normally distributed errors)
#  arrows(x0=val.y$yield, y0=posterior_mean - 2*posterior_std, 
#         x1=val.y$yield, y1=posterior_mean + 2*posterior_std, length=0.05, angle=90, code=3)
#  dev.off()  
#}