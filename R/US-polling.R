library(jsonlite)
library("dplyr")
library("tidyr")

data <- jsonlite::fromJSON("https://projects.fivethirtyeight.com/polls/president-general/2024/national/polling-average.json")

data_biden <- fromJSON("https://projects.fivethirtyeight.com/polls/president-general/2024/national/biden-trump/polling-average.json")

# pivot wider for line chart

data <- data %>%
  select(!party) %>%
  pivot_wider(names_from = candidate, values_from = c(pct_estimate, hi, lo)) %>%
  mutate(pct_estimate_Biden = 0) %>%
  mutate(hi_Biden = 0) %>%
  mutate(lo_Biden = 0)

data_biden <- data_biden %>%
  select(!party) %>%
  pivot_wider(names_from = candidate, values_from = c(pct_estimate, hi, lo)) %>%
  mutate(pct_estimate_Harris = 0) %>%
  mutate(hi_Harris = 0) %>%
  mutate(lo_Harris = 0)

# merge files
data_all = rbind(data_biden, data)
  
# write to csv
write.csv(data_all, file = "data/538-president-polling.csv")

# US generic ballot (for scatter)

average <- jsonlite::fromJSON("https://projects.fivethirtyeight.com/polls/generic-ballot/2024/polling-average.json")
polls <- jsonlite::fromJSON("https://projects.fivethirtyeight.com/polls/generic-ballot/2024/polls.json")

average <- average[-c(4:6)]

polls <- polls[-c(1:2,4:5,10:11,13:23)]
polls <- unnest(polls, answers)

polls <- polls %>%
  rename(
    date = endDate,
    party = choice,
    pct_estimate = pct
  ) %>%
  relocate(date, party, pct_estimate, pollster)  %>%
  mutate(size = 20) %>% 
  mutate(line = "") 

polls$party = gsub("Dem", "Democrats", polls$party)
polls$party = gsub("Rep", "Republicans", polls$party)

average <- average %>%
  rename(
    party = candidate
  ) %>%
  relocate(date, party, pct_estimate) %>%
  mutate(size = 1) %>%
  mutate(line = paste("line", party, sep = " ")) %>%
  mutate(pollster = "") %>%
  mutate(sampleSize = "") %>%
  mutate(created_at = "") %>%
  mutate(startDate = "") 

polls_average <- rbind(average, polls)

polls_average <- polls_average %>%
  rename(
    Kennedy = pct_estimate_Kennedy,
    Trump = pct_estimate_Trump,
    Biden = pct_estimate_Biden,
    Harris = pct_estimate_Harris
  )

# write to csv
write.csv(polls_average, file = "data/538-generic-ballot-scatter.csv")
