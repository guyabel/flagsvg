# u = s[[1]]
wiki_subcats <- function(u){
  h <- read_html(u) %>%
    html_nodes("div#mw-subcategories") %>%
    html_nodes("div.CategoryTreeItem")

  d1 <- h %>%
    html_nodes("a") %>%
    map(xml_attrs) %>%
    map_df(~as.list(.)) %>%
    as_tibble() %>%
    rename(subcat_url = href,
           subcat = title) %>%
    mutate(subcat = str_remove(string = subcat, pattern = "Category:"),
           subcat_url = paste0("https://commons.wikimedia.org", subcat_url)) %>%
    select(subcat, subcat_url) %>%
    rename(category = subcat,
           category_url = subcat_url)

  d2 <- h %>%
    html_nodes("span") %>%
    map(xml_attrs) %>%
    map_df(~as.list(.)) %>%
    drop_na(title) %>%
    select(title) %>%
    rename(stats = title) %>%
    filter(stats != "expand",
           stats != "collapse") %>%
    mutate(subcats = str_extract(string = stats, pattern = "[0-9]+"),
           subcats = as.numeric(subcats),
           files = word(string = stats, -2),
           files = str_remove_all(string = files, pattern = ","),
           files = as.numeric(files)) %>%
           # files = as.numeric(files)) %>%
           # pages = str_extract(string = stats, pattern = "[0-9]+ page"),
           # pages = str_extract(string = pages, pattern = "[0-9]+"),
           # pages = as.numeric(pages)) %>%
    as_tibble() %>%
    select(-stats)

    # d3 <- h %>%
    #   html_nodes("span") %>%
    #   map(xml_attrs) %>%
    #   map_df(~as.list(.)) %>%
    #   fill(class) %>%
    #   drop_na(title) %>%
    #   fill(`data-ct-title`)
    #   select(contains("title")) %>%
    #   drop_na("data-ct-title") %>%
    #   mutate(parent = ifelse(title == "collapse", `data-ct-title`, NA))

  bind_cols(d1, d2)
}

wiki_files <- function(u){
  h <- read_html(u) %>%
    html_nodes("div#mw-category-media")

  if(length(h)==0){
    d <- tibble(alt = "error somewhere.. no files on this page")
  }

  if(length(h)>0){
    d1 <- h %>%
      html_nodes("li.gallerybox") %>%
      html_nodes("img") %>%
      map(xml_attrs) %>%
      map_df(~as.list(.)) %>%
      as_tibble()

    d2 <- h %>%
      html_nodes("li.gallerybox") %>%
      html_nodes("a") %>%
      map(xml_attrs) %>%
      map_df(~as.list(.)) %>%
      as_tibble() %>%
      drop_na(title) %>%
      select(-class)
    d <- bind_cols(d1, d2)
  }
  return(d)
}

# u = "https://commons.wikimedia.org/w/index.php?title=Category:SVG_special_or_fictional_flags&filefrom=Fictitious+Hussite+banner.svg%0AFictitious+Hussite+banner.svg#mw-category-media"
wiki_next <- function(u){
  h <- read_html(u) %>%
    html_nodes("div#mw-category-media")

  h %>%
    html_nodes("a") %>%
    map(xml_attrs) %>%
    map_df(~as.list(.)) %>%
    as_tibble() %>%
    filter(is.na(class)) %>%
    slice(n()) %>%
    select(href) %>%
    mutate(href = paste0("https://commons.wikimedia.org", href)) %>%
    pull(href)
}

# u <- d1$file_url[i]
# u <- "https://commons.wikimedia.org//wiki/File:Flag_of_the_Count_of_%C3%9D%C3%B1igo-Genio.svg"
wiki_file_detail <- function(u){
  h <- read_html(u)

  x1 <- tibble(
    file_url = u,
    description = h %>%
      html_nodes("#fileinfotpl_desc+ td") %>%
      html_text() %>%
      paste(collapse = "\n"),
    date = h %>%
      html_nodes("#fileinfotpl_date+ td") %>%
      html_text() %>%
      paste(collapse = "\n"),
    source = h %>%
      html_nodes("#fileinfotpl_src+ td") %>%
      html_text() %>%
      paste(collapse = "\n"),
    author = h %>%
      html_nodes("#fileinfotpl_aut+ td") %>%
      html_text() %>%
      paste(collapse = "\n")
  )

  x2 <- h %>%
    html_nodes("div#mw-normal-catlinks") %>%
    html_nodes("a") %>%
    map(xml_attrs) %>%
    map_df(~as.list(.)) %>%
    as_tibble() %>%
    filter(href != "/wiki/Special:Categories") %>%
    mutate(href = paste0("https://commons.wikimedia.org", href),
           title = str_remove(string = title, pattern = "Category:"),
           file_url = u) %>%
    rename(category_url = href,
           category = title)

  # if(length(t1) == 0)
  #   x1 <- tibble(
  #     file_url = u
  #   )
  # if(length(t1) > 0){
  #   x1 <- t1 %>%
  #     .[[1]] %>%
  #     as_tibble() %>%
  #     filter(str_detect(string = X1, pattern = "Description|Date|Source|Author")) %>%
  #     select(1:2) %>%
  #     pivot_wider(names_from = "X1", values_from = "X2") %>%
  #     rename(Description = 1) %>%
  #     mutate(file_url = u)
  # }
  left_join(x2, x1, by = "file_url")
}
# rm(x1, x2, h, u, t1)
# wiki_file_detail(u)

# wiki_file_info <- function(u){
#   h <- read_html(u)
#   h %>%
#     html_nodes("div.fullMedia") %>%
#     html_nodes("a") %>%
#     map(xml_attrs) %>%
#     map_df(~as.list(.)) %>%
#     as_tibble()
#     html_nodes("a") %>%
#     div.fullMedia
# }
