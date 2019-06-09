library(logging)
basicConfig()

# define string formatting
`%--%` <- function(x, y)
# string formatting tools
{
  do.call(sprintf, c(list(x), y))
}

stack.train <- function(data, features)
# stacks rows to columns
{
  stacked.data <- data.frame(stringsAsFactors=FALSE) 
  for (data.year in unique(data$Year))
  {
    for (data.region in unique(data$State))
    {
      
      for (data.district in unique(data[data$State == data.region,]$Ag_District))
      {
        plc_hold <- data[data$State == data.region & data$Year == data.year
                       & data$Ag_District == data.district,]
        if (NROW(plc_hold) != 0)
        {
          result <- data.frame(matrix(ncol = 7, nrow = 0)) 
          colnames(result) <- c("State", "Ag_District", "Year", "month", "Lat", "Long", "Crop_Yield")
          result <- plc_hold[plc_hold$month == unique(plc_hold$month)[1],]
          result <- select(result, c("State", "Ag_District", "Year", "month", "Lat", "Long", "Crop_Yield"))[1,]
          
          for (data.month in 2:max(plc_hold$month))
          {
            loginfo("Month: %s, State: %s, Ag_District: %s, Year: %s", data.month, data.region, data.district, data.year)
            plc_hold.month <- plc_hold[plc_hold$month == data.month,]
            colnames(plc_hold.month) <- paste(colnames(plc_hold.month), "%s" %--% data.month, sep = "_")
            plc_hold.month <- plc_hold.month[,!(names(plc_hold.month) %in% c("month_%s" %--% data.month,
                                                                             "Year_%s" %--% data.month,
                                                                             "State_%s" %--% data.month,
                                                                             "Ag_District_%s" %--% data.month,
                                                                             "Crop_Yield_%s" %--% data.month,
                                                                             "Long_%s"%--% data.month,
                                                                             "Lat_%s"%--% data.month))]
            
            result <- cbind(result, plc_hold.month)
          }
          stacked.data <- rbind(stacked.data, result)
        }
      }
    }
  }
  return (stacked.data)
}

stack.test <- function(data, features)
  # stacks rows to columns
{
  stacked.data <- data.frame(stringsAsFactors=FALSE) 
  for (data.year in unique(data$Year))
  {
    for (data.region in unique(data$State))
    {
      for (data.district in unique(data[data$State == data.region,]$Ag_District))
      {

        plc_hold <- data[data$State == data.region & data$Year == data.year
                       & data$Ag_District == data.district,]
        if (NROW(plc_hold) != 0)
        {
          
          result <- data.frame(matrix(ncol = 6, nrow = 0)) 
          colnames(result) <- c("State", "Ag_District", "Year", "month", "Lat", "Long")
          result <- plc_hold[plc_hold$month == unique(plc_hold$month)[1],]
          result <- select(result, c("State", "Ag_District", "Year", "month", "Lat", "Long"))[1,]
          
          for (data.month in 2:max(plc_hold$month))
          {
            loginfo("Month: %s, State: %s, Ag_District: %s, Year: %s", data.month, data.region, data.district, data.year)
            plc_hold.month <- plc_hold[plc_hold$month == data.month,]
            colnames(plc_hold.month) <- paste(colnames(plc_hold.month), "%s" %--% data.month, sep = "_")
            plc_hold.month <- plc_hold.month[,!(names(plc_hold.month) %in% c("month_%s" %--% data.month,
                                                                             "Year_%s" %--% data.month,
                                                                             "State_%s" %--% data.month,
                                                                             "Ag_District_%s" %--% data.month,
                                                                             "Long_%s"%--% data.month,
                                                                             "Lat_%s"%--% data.month))]
            
            result <- cbind(result, plc_hold.month)
          }
          stacked.data <- rbind(stacked.data, result)
        }
      }
    }
  }
  return (stacked.data)
}