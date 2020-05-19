##
## wiki1 scrape category
## wiki2 scrape category pages
## wiki3 scrape flags
## wiki4 scrape flag details
##

library(tidyverse)
library(rvest)

source("./flags-wikimedia/wiki_fn.R")

d0 <- read_csv(file = "./flags-wikimedia/flags1.csv")

d1 <- d0 %>%
  mutate(flag_url = str_remove_all(string = src, pattern = ".svg(.*)"),
         flag_url = str_remove(string = flag_url, pattern = "/thumb"),
         flag_url = paste0(flag_url, ".svg"),
         file_url = paste0("https://commons.wikimedia.org/", href)) %>%
  select(alt, flag_url, file_url) %>%
  distinct()

# d <- list()
for(i in 30896:nrow(d1)){
  d[[i]] <- wiki_file_detail(u = d1$file_url[i])
  if(i %% 10 == 0)
    print(i)
}
d2 <- bind_rows(d)
write_excel_csv(d2, "./flags-wikimedia/flags_all_categories1.csv")
