source("./utils.R")
library(matrixStats)
library(logging)
basicConfig()

train.model.month <- function(model.month,
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
  train.stacked <- train.stacked[!is.na(train.stacked$Crop_Yield),]
  train.x <- train.stacked[,!(names(train.stacked) %in% c("State", "Ag_District", "month", "Year", "Crop_Yield"))]
  train.y <- train.stacked$Crop_Yield
  
  if (NROW(train.x) != 0)
  {
    
    sink("/dev/null")
    model <- bartMachine(train.x, train.y, num_trees = 50, k=2, 
                         serialize = save_flag, num_iterations_after_burn_in = 2000, num_burn_in = 500)
    #model <- bart(train.x, train.y$yield, keeptrees=TRUE, keepevery=20L, nskip=1000, ndpost=2000, ntree=200, k=2)
    sink()
    if (save_flag == TRUE) {
      loginfo("Saving model")
      save(model, file = "./predictions/BART_%s.RData" %--% c( model.month))
    }
  }
  return (model)
}

predict.bart.month <- function(model, test.stacked)
{
  test.x <- subset(test.stacked, select = -c(State, Ag_District, month, Year))
  posterior.mean <- predict(model, test.x)
  posterior.variance <- calc_prediction_intervals(model, test.x)
  
  return (list(test.stacked$name, posterior.mean, posterior.variance))
}
