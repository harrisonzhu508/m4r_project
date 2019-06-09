# compute agriculture district centroids
stateFIPS <- read.csv("../../data/state_county_info/countyFIPS.csv")
df2 <- read.csv("../../data/state_county_info/ag_district_county_mapping.csv")

df_merged <- merge(stateFIPS, df2, by.x = c("County", "State"), by.y = c("County", "USPS_Code"), all.x = TRUE)

df_merged_nona<-df_merged[complete.cases(df_merged), ]

library(sqldf)

colnames(df_merged_nona)[10] <- "AgDistrict"
df_merged_nona <- sqldf("
      SELECT *, AVG(Latitude), AVG(Longtitude)
      FROM df_merged_nona
      GROUP BY df_merged_nona.State, df_merged_nona.AgDistrict
")

colnames(df_merged_nona)
df_merged_nona <- df_merged_nona[, c(1,2,10,11,12)]
head(df_merged_nona)
write.csv(df_merged_nona, "ag_district_centroids.csv")

