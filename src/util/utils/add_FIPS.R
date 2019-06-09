library(sqldf)

centroids <- read.csv("../../data/state_county_info/ag_district_centroids.csv")
state_USPS <- read.csv("../../data/state_county_info/stateUSPS.csv")

df_merged <- merge(centroids, state_USPS, by.x = c("State"), by.y = c("USPS_Code"), all.x = TRUE)

df_merged <- df_merged[, c(1,3,4,5,6,9)]
colnames(df_merged)

write.csv(df_merged, "../../data/state_county_info/ag_district_centroids.csv")

# add in fips code to district mapping
dist_mapping <- read.csv("../../data/state_county_info/ag_district_county_mapping.csv")
head(dist_mapping)
head(state_USPS)
df_merged_mapping <- merge(dist_mapping, state_USPS, by.x = c("USPS_Code"), by.y = c("USPS_Code"), all.x = TRUE)
df_merged_mapping <- df_merged_mapping[,-c(2,7,8)]
head(df_merged_mapping)
write.csv(df_merged_mapping, "../../data/state_county_info/ag_district_county_mapping.csv")



