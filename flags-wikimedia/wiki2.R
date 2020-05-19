##
## wiki1 scrape category
## wiki2 scrape category pages
## wiki3 scrape flags
## wiki4 scrape flag details
##

library(tidyverse)
library(rvest)

source("./flags-wikimedia/wiki_fn.R")

d0 <- read_csv(file = "./flags-wikimedia/categories.csv")

d1 <- d0 %>%
  select(-round) %>%
  distinct()

d1 %>%
  arrange(desc(files))

d2 <- d1 %>%
  filter(files > 200) %>%
  mutate(category_url_next = category_url,
         id = 1:n())

d3 <- NULL
for(n in c(2,4,6,8,10,12)*100){
# n = 200
  ii <- d2 %>%
    filter(files > n) %>%
    pull(id)
  for(i in ii){
    print(paste(n, i))
    d4 <- d2 %>%
      slice(i) %>%
      mutate(category_url_next = wiki_next(d2$category_url_next[i]))
    d3 <- bind_rows(d3, d4)
  }
}
d4 <- d3 %>%
  mutate(category_url = category_url_next) %>%
  mutate(category = factor(category, levels = d1$category)) %>%
  select(-id, -category_url_next)

d5 <- d1 %>%
  mutate(category = factor(category, levels = d1$category)) %>%
  bind_rows(d4) %>%
  arrange(category)

# wiki_subcats("https://commons.wikimedia.org/wiki/Category:SVG_flags")
d6 <- tibble(
  category = "SVG Flags",
  category_url = "https://commons.wikimedia.org/wiki/Category:SVG_flags",
  subcats = 46,
  files = 165
)
d6 <- d6 %>%
  bind_rows(d5)

write_excel_csv(d0,"./flags-wikimedia/categories_all_pages1.csv")
