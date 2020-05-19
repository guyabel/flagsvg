## code to prepare `flags_github` dataset goes here
library(tidyverse)

d0 <- read_csv("./flags-github/flags_github.csv")
d1 <- read_csv("./flags-github/repos.csv")

flags_github <- d0 %>%
  rename(details = github_details) %>%
  group_by(github, details) %>%
  mutate("flag_set_n" = n()) %>%
  left_join(d1) %>%
  ungroup() %>%
  mutate(flag_set = paste(github, folder)) %>%
  select(-github, -folder) %>%
  rename(flag_name = flag,
         flag_file = file,
         flag_set_details = details,
         flag_set_url = url) %>%
  select(-contains("commit"), -parent_geo_level) %>%
  select(flag_name, flag_url, flag_set, contains("geo"), contains("flag_set"))

usethis::use_data(flags_github, overwrite = TRUE)
