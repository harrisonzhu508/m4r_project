library(sqldf)
results <- read.csv("CV_results.csv")
monthly_RSME <- sqldf("
      SELECT `val.month`, crop, SQRT(SUM(SE)/SUM(n)) as RMSE
      FROM results
      GROUP BY `val.month`, crop
      ")
date <- Sys.Date()

write.csv(monthly_RSME, "validation_monthly_%s.csv" %--% date)
