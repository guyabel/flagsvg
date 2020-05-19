##
## wiki1 scrape category
## wiki2 scrape category pages
## wiki3 scrape flags
## wiki4 scrape flag details
## wiki5 extra category pages found and added.. rerun wiki3 and wiki4 after
##

d0 <- read_csv("./flags-wikimedia/categories_all_pages1.csv")
d1 <- read_csv("./flags-wikimedia/flags_all_categories1.csv")

d2 <- d1 %>%
  filter(str_detect(string = category, pattern = "SVG"),
         !category_url %in% d0$category_url,
         str_detect(string = category, pattern = "Flag|flag"),
         !str_detect(string = category, pattern = "(page does not exist)")) %>%
  select(category_url, category) %>%
  distinct()

d3 <- d0 %>%
  bind_rows(d2)
write_excel_csv(d3, "./flags-wikimedia/categories_all_pages2.csv")


# wiki3 with new data
d0 <- d3 %>%
  filter(is.na(subcats))
d1 <- read_csv("./flags-wikimedia/flags1.csv", col_types = cols(.default = "c"))

for(i in 1:nrow(d0)){
  print(i)
  d2 <- d0$category_url[i] %>%
    wiki_files() %>%
    mutate(category = d0$category[i],
           category_url = d0$category_url[i])
  d1 <- bind_rows(d1, d2)
}
write_excel_csv(d1, "./flags-wikimedia/flags2.csv")

# wiki4 with new data
d0 <- read_csv("./flags-wikimedia/flags1.csv", col_types = cols(.default = "c"))
d1 <- read_csv("./flags-wikimedia/flags2.csv", col_types = cols(.default = "c"))
d0 <- d1 %>%
  filter(!src %in% d0$src)

d1 <- d0 %>%
  mutate(flag_url = str_remove_all(string = src, pattern = ".svg(.*)"),
         flag_url = str_remove(string = flag_url, pattern = "/thumb"),
         flag_url = paste0(flag_url, ".svg"),
         file_url = paste0("https://commons.wikimedia.org/", href)) %>%
  select(alt, flag_url, file_url) %>%
  distinct()

d <- list()
for(i in 1:nrow(d1)){
  d[[i]] <- wiki_file_detail(u = d1$file_url[i])
  if(i %% 10 == 0)
    print(i)
}
d2 <- bind_rows(d)
d3 <- read_csv("./flags-wikimedia/flags_all_categories1.csv")
d4 <- bind_rows(d3, d2)
write_excel_csv(d4, "./flags-wikimedia/flags_all_categories2.csv")


