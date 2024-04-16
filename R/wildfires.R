# packages
library("jsonlite")
library("lubridate")

# load data

raw = fromJSON("https://api.ourworldindata.org/v1/indicators/821434.data.json")

metadata = fromJSON("https://api.ourworldindata.org/v1/indicators/821434.metadata.json")

countries = metadata$dimensions$entities$values

data <- as.data.frame(raw)

data = merge(data,countries, by.x = "entities", by.y = "id")

data$date = as_date(data$years)
data$dateCorrected = as_date(data$date + 10957.5)

world = subset(data, data$name == "World")

## filter for different time periods
last30d = subset(world, world$dateCorrected >= as.Date(today()-30))
last30d$TimePeriod = "Last 30 days"
last90d = subset(world, world$dateCorrected >= as.Date(today()-90))
last90d$TimePeriod = "Last 90 days"
last6m = subset(world, world$dateCorrected >= as.Date(today()-182.625))
last6m$TimePeriod = "Last 6 months"
last12m = subset(world, world$dateCorrected >= as.Date(today()-365.25))
last12m$TimePeriod = "Last 12 months"
last5y = subset(world, world$dateCorrected >= as.Date(today()-1826.25))
last5y$TimePeriod = "Last 5 years"

world$TimePeriod = "All"

forest_fires_world = rbind(world,last30d,last90d, last6m,last12m,last5y)

write.csv(forest_fires_world, file = "data/forest_fires_world.csv")

