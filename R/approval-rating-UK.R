library(jsonlite)
library("dplyr")
library("tidyr")

data <- jsonlite::fromJSON("https://www.politico.eu/wp-json/politico/v1/poll-of-polls/GB-leadership-approval")

polls <- data$polls
trends <- data$trends$kalmanSmooth

trends_parties = trends$parties
full_trends = cbind(trends, trends_parties)
full_trends = full_trends[-c(2)]

approval_trends = full_trends %>%
  pivot_longer(cols = starts_with("approve"), names_to = "candidates", values_to = "Approve") %>%
  select(-c(2:5))

approval_trends$candidates = gsub("approve_johnson", "Boris Johnson", approval_trends$candidates)
approval_trends$candidates = gsub("approve_truss", "Liz Truss", approval_trends$candidates)
approval_trends$candidates = gsub("approve_sunak", "Rishi Sunak", approval_trends$candidates)

disapproval_trends = full_trends %>%
  pivot_longer(cols = starts_with("disapprove"), names_to = "candidates", values_to = "Disapprove") %>%
  select(-c(2:5))

disapproval_trends$candidates = gsub("disapprove_johnson", "Boris Johnson", approval_trends$candidates)
disapproval_trends$candidates = gsub("disapprove_truss", "Liz Truss", approval_trends$candidates)
disapproval_trends$candidates = gsub("disapprove_sunak", "Rishi Sunak", approval_trends$candidates)

all_trends = cbind(approval_trends, disapproval_trends)
all_trends = all_trends[-c(4,5)]

all_trends = all_trends %>%
  drop_na() %>%
  arrange(desc(candidates))

write.csv(all_trends, file = "data/approval-rating-UK.csv")
