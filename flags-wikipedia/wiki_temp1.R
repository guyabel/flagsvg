library(tidyverse)
library(rvest)

d <- tibble(
  category = c("countries",
               "countries",
               "former_countries",
               "partly_recognized_states",
               "former_unrecognized_states"),
  url = c("https://en.wikipedia.org/w/index.php?title=Category:Country_data_templates_of_countries&pageuntil=Zimbabwe%0ACountry+data+Zimbabwe#mw-pages",
        "https://en.wikipedia.org/w/index.php?title=Category:Country_data_templates_of_countries&pagefrom=Zimbabwe%0ACountry+data+Zimbabwe#mw-pages",
        "https://en.wikipedia.org/wiki/Category:Country_data_templates_of_former_countries",
        "https://en.wikipedia.org/wiki/Category:Country_data_templates_of_partly_recognized_states",
        "https://en.wikipedia.org/wiki/Category:Country_data_templates_of_former_unrecognized_states"
        )
)

get_pages <- function(u){
  # u = d$u[i]; u
  h <- read_html(u)
  tibble(
    page_url = h %>%
      html_nodes("#mw-pages .mw-content-ltr a") %>%
      html_attr("href"),
    ) %>%
    mutate(page_name = str_remove(string = page_url,
                                  pattern = ".*(data_)"))
}

d0 <- d %>%
  mutate(page = map(.x = url, .f = ~get_pages(u = .x)))

d1 <- d0 %>%
  rename(category_url = url) %>%
  unnest(page)

get_flags <- function(u){
  # u = d1$page_url[i]; u
  message(u)
  h <- paste0("https://en.wikipedia.org", u) %>%
    read_html()

  # title and table
  n <- h %>%
    html_nodes(".mw-headline,.wikitable")

  x <- tibble(
    id = n %>%
      html_attr("id")
  ) %>%
    mutate(tab = is.na(id),
           tab_no = cumsum(tab)) %>%
    fill(id)

  tab_sp <- x %>%
    filter(id == "Standard_parameters",
           tab) %>%
    pull(tab_no)

  m <- tibble(
    variant = "main",
    image = h %>%
      html_nodes(".wikitable") %>%
      html_table() %>%
      .[tab_sp] %>%
      .[[1]] %>%
      pull(2) %>%
      str_subset(pattern = "Flag of")
  )

  tab_v <- x %>%
    filter(id == "Flag_variants",
           tab) %>%
    pull(tab_no)

  v <- NULL
  if(length(tab_v) > 0){
    v <- h %>%
      html_nodes(".wikitable") %>%
      html_table() %>%
      .[tab_v] %>%
      .[[1]] %>%
      select(-2) %>%
      rename(variant = 1,
             image = 2) %>%
      mutate(variant = as.character(variant))
  }

  f <- m %>%
    bind_rows(v) %>%
    mutate(name = h %>%
             html_nodes(".wikitable") %>%
             html_table() %>%
             .[tab_sp] %>%
             .[[1]] %>%
             pull(2) %>%
             .[1])
  return(f)
}

d2 <- d1 %>%
  filter(!str_detect(string = page_name, pattern = "Swaziland")) %>%
  filter(!str_detect(string = page_name, pattern = "Burma")) %>%
  filter(!str_detect(string = page_name, pattern = "Siam")) %>%
  mutate(flags = map(.x = page_url, .f = ~get_flags(u = .x)))

d3 <- d2 %>%
  unnest(flags)
  mutate(d)
write_csv(d3, "./flags-wikipedia/flags1.csv")
