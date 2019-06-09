CV_results <- read.csv("CV_results.csv")
spring_barley_avg <-read.csv("spring_barley_avg.csv")
winter_wheat_avg <- read.csv("winter_wheat_avg.csv")
spring_barley <- read.csv("../spring_barley.csv")
winter_wheat <- read.csv("../winter_wheat.csv")

spring_barley <- spring_barley[spring_barley$yield!=0,]
winter_wheat <- winter_wheat[winter_wheat$yield!=0,]

spring_barley_pred <- merge(spring_barley, spring_barley_avg, by = "region")
spring_barley_pred$se <- (spring_barley_pred$average_yield - spring_barley_pred$yield)^2

winter_wheat_pred <- merge(winter_wheat, winter_wheat_avg, by = "region")
winter_wheat_pred$se <- (winter_wheat_pred$average_yield - winter_wheat_pred$yield)^2

winter_wheat_result <- sqldf("
                SELECT SQRT(AVG(se)) as rmse
                FROM winter_wheat_pred
                ")
spring_barley_result <- sqldf("
                              SELECT SQRT(AVG(se)) as rmse
                              FROM spring_barley_pred
                              ")

results <- data.frame(winter_wheat_result, spring_barley_result)
colnames(results) <- c("rmse_winter_wheat", "rmse_spring_barley")
write.csv(results, "rmse_benchmark_avg.csv",row.names = FALSE)
