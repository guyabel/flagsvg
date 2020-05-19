## code to prepare `flags_wikimedia` dataset goes here
library(tidyverse)

d0 <- read_csv("./flags-wikimedia/categories_all_pages2.csv")
d1 <- read_csv("./flags-wikimedia/flags_all_categories2.csv")
d2 <- read_csv("./flags-wikimedia/flags2.csv") %>%
  select(alt, href, contains("data")) %>%
  distinct() %>%
  rename(flag_url = href,
         flag_name = alt) %>%
  mutate(flag_url = paste0("https://commons.wikimedia.org/", flag_url))

flags_wikimedia <-
  d1 %>%
  filter(category_url %in% d0$category_url) %>%
  group_by(category_url, category) %>%
  mutate(flag_set_n = n(),
         flag_details = str_remove(string = description, pattern = "^\\n"),
         flag_details = paste(flag_details, date, source, author)) %>%
  ungroup() %>%
  rename(flag_set = category,
         flag_set_url = category_url,
         flag_url = file_url) %>%
  left_join(d2) %>%
  select(-description, -date, -source, -author, -class) %>%
  mutate(flag_details = paste(flag_details,
                              "\nwidth: ", `data-file-width`,
                              "\nheight: ", `data-file-height`)) %>%
  select(-contains("data")) %>%
  select(flag_name, flag_url, flag_details, flag_set, contains("flag_set"))

usethis::use_data(flags_wikimedia, overwrite = TRUE)

