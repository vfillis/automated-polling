library(jsonlite)
library("dplyr")
library("tidyr")

data <- jsonlite::fromJSON("https://www.politico.eu/wp-json/politico/v1/poll-of-polls/GB-parliament")

polls <- data$polls
trends <- data$trends$kalmanSmooth

polls_parties = polls$parties
full_polls = cbind(polls, polls_parties)
full_polls = full_polls[-c(2)]

working_polls = full_polls %>%
  pivot_longer(cols = c("Con":"ChUK"), names_to = "parties", values_to = "value")

trends_parties = trends$parties
full_trends = cbind(trends, trends_parties)
full_trends = full_trends[-c(2)]

working_trends = full_trends %>%
  pivot_longer(cols = c("Con":"ChUK"), names_to = "parties", values_to = "value")

## add final formatting in here too 

working_trends$size = 1
working_trends$name = paste("line",working_trends$parties, sep = " ")
working_trends$firm = ""
working_trends$date_from = ""
working_trends$sample_size = ""

working_polls$size = 20
working_polls$name = ""

col_order = c("date", "parties", "value", "size", "name", "firm", "date_from", "sample_size")

working_polls = working_polls[, col_order]

all = rbind(working_trends, working_polls)

all_last3years = subset(all, all$date < Sys.Date() & all$date > (Sys.Date() - (3*365)))

write.csv(all_last3years, file = "data/last3Y_polling.csv")
