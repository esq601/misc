library(httr)
library(tidyverse)
library(jsonlite)

df1 <- fromJSON(toJSON(
  content(GET("https://apps.bea.gov/api/data?&UserID=D9875AD5-1222-4801-A298-A3A3BC843519&method=GETDATASETLIST&"))
))

df1$BEAAPI$Results$Dataset

#### Regional parameters

search_df <- fromJSON(toJSON(
  content(GET("https://apps.bea.gov/api/data?&UserID=D9875AD5-1222-4801-A298-A3A3BC843519&method=GetParameterValues&DataSetName=Regional&ParameterName=LineCode"))
))[["BEAAPI"]][["Results"]][["ParamValue"]]

table_name <- "SQGDP9"
geo_fips <- "STATE"
line_code <- "1"

search_df1 <- search_df %>%
  mutate_all(as.character) %>%
  filter(str_detect(Desc, table_name) == T)

df_final <- data.frame()

for(i in unique(search_df1$Key)) {
  print(i)
  
  line_code <- i
  
  results <- fromJSON(toJSON(
    content(GET(paste0("https://apps.bea.gov/api/data?&UserID=D9875AD5-1222-4801-A298-A3A3BC843519&method=GetData&DataSetName=Regional&TableName=",table_name,
                       "&GeoFips=",geo_fips,"&LineCode=",line_code))
    )))
  
  df1 <- results$BEAAPI$Results$Data
  
  df1$key <- line_code
  
  df_final <- bind_rows(df_final, df1)

}

str(df_final1)
df_final1 <- df_final %>%
  mutate_all(as.character) %>%
  left_join(search_df1, by = c("key"="Key")) %>%
  distinct()

write_csv(df_final1, path = "gdp_state_30jul.csv")


df_final2 <- df_final1 %>%
  mutate(year = str_sub(TimePeriod,1,4),qtr = str_sub(TimePeriod,-1))

