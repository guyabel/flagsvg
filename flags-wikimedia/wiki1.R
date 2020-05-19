##
## wiki1 scrape category
## wiki2 scrape category pages
## wiki3 scrape flags
## wiki4 scrape flag details
##

library(RSelenium)
library(tidyverse)
library(rvest)

source("./flags-wikimedia/wiki_fn.R")

rD <- rsDriver(check = FALSE, port = 4502L)
remDr <- rD[["client"]]
remDr$navigate("https://commons.wikimedia.org/wiki/Category:SVG_flags")

s <- remDr$getPageSource()

d <- list()
d[[1]] <- wiki_subcats(s[[1]])
bb <- nrow(d[[1]])
r <- 2
while(bb > 15){
  print(r)
  print(bb)
  b <- remDr$findElements(using = "css selector", "[title='expand']")
  bb <- length(b)
  for(i in 1:length(b)){
    b[[i]]$clickElement()
    Sys.sleep(0.5)
  }

  s <- remDr$getPageSource()
  d[[r]] <- s[[1]] %>%
    wiki_subcats()
  r <- r+1
}

d[[1]]

remDr$close()
# stop the selenium server
rD[["server"]]$stop()
rm(rD)
gc()

d0 <- d[[1]] %>%
  mutate(round = 1) %>%
  bind_rows(mutate(d[[2]], round = 2)) %>%
  bind_rows(mutate(d[[3]], round = 3)) %>%
  bind_rows(mutate(d[[4]], round = 4)) %>%
  bind_rows(mutate(d[[5]], round = 5)) %>%
  bind_rows(mutate(d[[6]], round = 6)) %>%
  bind_rows(mutate(d[[7]], round = 7)) %>%
  bind_rows(mutate(d[[8]], round = 8)) %>%
  bind_rows(mutate(d[[9]], round = 9))
write_excel_csv(d0, "./flags-wikimedia/categories.csv")







# d0 <- "https://commons.wikimedia.org/wiki/Category:SVG_flags" %>%
#   wiki_cats() %>%
#   mutate(round = 1,
#          cat_id = paste(round, 1:n(), sep = "-"))
#
# d1 <- d0
# z <- sum(d1$subcats == 0)
# r <- 1
# while(z > 0){
#   n <- d1 %>%
#     filter(round == r) %>%
#     nrow()
#   for(i in 1:n){
#     print(paste("round", r, " row ", i, "of ", n))
#
#     c0 <- d1 %>%
#       filter(round == r) %>%
#       slice(i) %>%
#       pull(subcats)
#     if(c0 == 0)
#       next()
#
#     u0 <- d1 %>%
#       filter(round == r) %>%
#       slice(i) %>%
#       pull(href) %>%
#       paste0("https://commons.wikimedia.org", .)
#
#     id <- d1 %>%
#       filter(round == r) %>%
#       slice(i) %>%
#       pull(cat_id)
#
#     d2 <- u0 %>%
#       wiki_cats() %>%
#       mutate(round = r + 1,
#              cat_parent_id = id)
#
#     if(c0 > 200){
#       d3 <- u0 %>%
#         read_html() %>%
#         html_nodes("div#mw-subcategories") %>%
#         html_nodes("a") %>%
#         .[[1]] %>%
#         html_attr("href") %>%
#         paste0("https://commons.wikimedia.org/", .) %>%
#         wiki_cats() %>%
#         mutate(round = r + 1,
#                cat_parent_id = id)
#       d2 <- bind_rows(d2, d3)
#     }
#     d2 <- d2 %>%
#       mutate(cat_id = paste(r+1, 1:n(), sep = "-"))
#     d1 <- d1 %>%
#       bind_rows(d2)
#       # mutate(d = duplicated(href)) %>%
#       # filter(d == FALSE)
#   }
#   z <- d1 %>%
#     filter(round == r + 1,
#            subcats > 0) %>%
#     nrow()
#   print(z)
#
#   r <- r + 1
# }
# d1 <- d0 %>%
#   select(-d)
# write_csv(d1,"subcats.csv")
