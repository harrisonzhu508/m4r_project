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
  for (data.year in unique(data$year))
  {
    for (data.region in unique(data$name))
    {
      plc_hold <- data[data$name == data.region & data$year == data.year,]
      if (NROW(plc_hold) != 0)
      {
          
        result <- data.frame(matrix(ncol = 6, nrow = 0)) 
        colnames(result) <- c("name", "year", "month", "latitude", "longitude","yield")
        result <- plc_hold[plc_hold$month == unique(plc_hold$month)[1],]
        result <- select(result, c("name", "year", "month", "latitude", "longitude","yield"))[1,]
        
        for (data.month in 2:max(plc_hold$month))
        {
          loginfo("Month: %s, Region: %s, Year: %s", data.month, data.region, data.year)
          plc_hold.month <- plc_hold[plc_hold$month == data.month,]
          colnames(plc_hold.month) <- paste(colnames(plc_hold.month), "%s" %--% data.month, sep = "_")
          plc_hold.month <- plc_hold.month[,!(names(plc_hold.month) %in% c("month_%s" %--% data.month,
                                                                           "year_%s" %--% data.month,
                                                                           "name_%s" %--% data.month,
                                                                           "yield_%s" %--% data.month,
                                                                           "longitude_%s"%--% data.month,
                                                                           "latitude_%s"%--% data.month))]
          
          result <- cbind(result, plc_hold.month)
        }
        stacked.data <- rbind(stacked.data, result)
        
      }
    }
  }
  return (stacked.data)
}

stack.test <- function(data, features)
  # stacks rows to columns
{
  stacked.data <- data.frame(stringsAsFactors=FALSE) 
  for (data.year in unique(data$year))
  {
    for (data.region in unique(data$name))
    {
      plc_hold <- data[data$name == data.region & data$year == data.year,]
      if (NROW(plc_hold) != 0)
      {
        
        result <- data.frame(matrix(ncol = 5, nrow = 0)) 
        colnames(result) <- c("name", "year", "month", "latitude", "longitude")
        result <- plc_hold[plc_hold$month == unique(plc_hold$month)[1],]
        result <- select(result, c("name", "year", "month", "latitude", "longitude"))[1,]
        
        for (data.month in 2:max(plc_hold$month))
        {
          loginfo("Month: %s, Region: %s, Year: %s", data.month, data.region, data.year)
          plc_hold.month <- plc_hold[plc_hold$month == data.month,]
          colnames(plc_hold.month) <- paste(colnames(plc_hold.month), "%s" %--% data.month, sep = "_")
          plc_hold.month <- plc_hold.month[,!(names(plc_hold.month) %in% c("month_%s" %--% data.month,
                                                                           "year_%s" %--% data.month,
                                                                           "name_%s" %--% data.month,
                                                                           "longitude_%s"%--% data.month,
                                                                           "latitude_%s"%--% data.month))]
          
          result <- cbind(result, plc_hold.month)
        }
        stacked.data <- rbind(stacked.data, result)
        
      }
    }
  }
  return (stacked.data)
}


stack.train.week <- function(data, features)
# stacks rows to columns 
# weekly stacking
{
  stacked.data <- data.frame(stringsAsFactors=FALSE) 
  for (data.year in unique(data$year))
  {
    for (data.region in unique(data$name))
    {
      plc_hold <- data[data$name == data.region & data$year == data.year,]
      if (NROW(plc_hold) != 0)
      {
          
        result <- data.frame(matrix(ncol = 6, nrow = 0)) 
        colnames(result) <- c("name", "year", "week", "latitude", "longitude","yield")
        result <- plc_hold[plc_hold$week == unique(plc_hold$week)[1],]
        result <- select(result, c("name", "year", "week", "latitude", "longitude","yield"))[1,]
        
        for (data.week in max(2, max(plc_hold$week) - 8):max(plc_hold$week))
        {
          loginfo("Week: %s, Region: %s, Year: %s", data.week, data.region, data.year)
          plc_hold.week <- plc_hold[plc_hold$week == data.week,]
          colnames(plc_hold.week) <- paste(colnames(plc_hold.week), "%s" %--% data.week, sep = "_")
          plc_hold.week <- plc_hold.week[,!(names(plc_hold.week) %in% c("week_%s" %--% data.week,
                                                                           "year_%s" %--% data.week,
                                                                           "name_%s" %--% data.week,
                                                                           "yield_%s" %--% data.week,
                                                                           "longitude_%s"%--% data.week,
                                                                           "latitude_%s"%--% data.week))]
          
          result <- cbind(result, plc_hold.week)
        }
        stacked.data <- rbind(stacked.data, result)
        
      }
    }
  }
  return (stacked.data)
}

stack.test.week <- function(data, features)
  # stacks rows to columns
{
  stacked.data <- data.frame(stringsAsFactors=FALSE) 
  for (data.year in unique(data$year))
  {
    for (data.region in unique(data$name))
    {
      plc_hold <- data[data$name == data.region & data$year == data.year,]
      if (NROW(plc_hold) != 0)
      {
        
        result <- data.frame(matrix(ncol = 5, nrow = 0)) 
        colnames(result) <- c("name", "year", "week", "latitude", "longitude")
        result <- plc_hold[plc_hold$week == unique(plc_hold$week)[1],]
        result <- select(result, c("name", "year", "week", "latitude", "longitude"))[1,]
        


        for (data.week in max(2, max(plc_hold$week) - 8):max(plc_hold$week))
        {
          loginfo("Week: %s, Region: %s, Year: %s", data.week, data.region, data.year)
          plc_hold.week <- plc_hold[plc_hold$week == data.week,]
          colnames(plc_hold.week) <- paste(colnames(plc_hold.week), "%s" %--% data.week, sep = "_")
          plc_hold.week <- plc_hold.week[,!(names(plc_hold.week) %in% c("week_%s" %--% data.week,
                                                                           "year_%s" %--% data.week,
                                                                           "name_%s" %--% data.week,
                                                                           "longitude_%s"%--% data.week,
                                                                           "latitude_%s"%--% data.week))]
          
          result <- cbind(result, plc_hold.week)
        }
        stacked.data <- rbind(stacked.data, result)
        
      }
    }
  }
  return (stacked.data)
}


fill.missing.month <- function(train, year_1=2000, year_2=2016)
#function to fill in missing satellite data
{
  for (year in year_1:year_2)
  {
    for (region in unique(train$name))
    {
      place <- train[train$year==year & train$name == region,]
      
      for (month in 2:11)
      {
        if (month %in% place$month == FALSE)
        {
          loginfo("Missing month %s. Year: %s. Region: %s.", month, year, region)
          loginfo("Current months %s", place$month)
          
          if ((month-1) %in% unique(place$month)) {
            replacement <- place[place$month == (month-1),]
          } else if ((month-2) %in% unique(place$month)) {
            replacement <- place[place$month == (month-2),]
          } else if ((month-3) %in% unique(place$month)) {
            replacement <- place[place$month == (month-3),]
          } else if ((month-4) %in% unique(place$month)) {
            replacement <- place[place$month == (month-4),]
          } else if ((month+1) %in% unique(place$month)) {
            replacement <- place[place$month == (month+1),]
          } else if ((month+2) %in% unique(place$month)) {
            replacement <- place[place$month == (month+2),]
          } else if ((month+3) %in% unique(place$month)) {
            replacement <- place[place$month == (month+3),]
          } else if ((month+4) %in% unique(place$month)) {
            replacement <- place[place$month == (month+4),]
          }
          replacement$month <- month
          train <- rbind(train, replacement)
        }
      }
    }
  }
  return (train)
}

