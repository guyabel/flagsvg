library(tidyverse)
library(rvest)
library(devtools)

d0 <- read_csv("./flags-github/repos.csv")

d <- list()
for(i in 1:nrow(d0)){
  print(i)
  u <- paste0(d0$url[i], "/tree/master/", d0$folder[i])
  h <- read_html(u)
  d[[i]] <- html_table(h) %>%
    .[[1]] %>%
    as_tibble() %>%
    filter(str_detect(string = Name, pattern = ".svg")) %>%
    rename(file = Name) %>%
    mutate(flag = str_remove(string = file, pattern = ".svg"),
           geo_level = d0$geo_level[i],
           geo_level_parent = d0$parent_geo_level[i],
           github = d0$github[i],
           github_details = d0$details[i],
           flag_url = str_replace(string = d0$url[i], pattern = "github.com", replacement = "raw.githubusercontent.com"),
           flag_url = paste0(flag_url, "/master/", d0$folder[i], "/", file)) %>%
    select(-Type) %>%
    select(flag, flag_url, contains("geo_level"), contains("github"), everything())
}
flags_gitub <- bind_rows(d)
write_excel_csv(flags_gitub, "./flags-github/flags_github.csv")

# use_data_raw(name = "flags_github")
