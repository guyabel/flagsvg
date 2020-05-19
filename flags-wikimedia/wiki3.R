##
## wiki1 scrape category
## wiki2 scrape category pages
## wiki3 scrape flags
## wiki4 scrape flag details
##

library(tidyverse)
library(rvest)

source("./flags-wikimedia/wiki_fn.R")

d0 <- read_csv(file = "./flags-wikimedia/categories_all_pages1.csv")

d1 <- NULL
for(i in 1:nrow(d0)){
  print(i)
  if(d0$files[i] == 0)
    next()
  d2 <- d0$category_url[i] %>%
    wiki_files() %>%
    mutate(category = d0$category[i],
           category_url = d0$category_url[i])
  d1 <- bind_rows(d1, d2)
}
d1 <- read_csv("./flags-wikimedia/flags.csv")
write_excel_csv(d1, "./flags-wikimedia/flags1.csv")
