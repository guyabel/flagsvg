flag_search <- function(text = NULL, alpha2 = NULL, alpha3 = NULL, field = "all", type = "flag", ignore_case = TRUE){
  d <- dd %>%
    filter_at(
      .vars = vars(title, categories),
      any_vars(str_detect(string = ., pattern = regex(text, ignore_case = ignore_case)))
    )
  d
}
flag_search(text = "newbury")

flag_set_search()

library(countrycode)
countrycode(sourcevar = 'UK', origin = 'country.name', destination = 'iso3c')
countrycode(sourcevar = 'U.K.', origin = 'country.name', destination = 'iso3c')
countrycode(sourcevar = 'United Kingdom', origin = 'country.name', destination = 'iso3c')
countrycode(sourcevar = 'Britain', origin = 'country.name', destination = 'iso3c')
countrycode(sourcevar = 'Great Britain', origin = 'country.name', destination = 'iso3c')
countrycode(sourcevar = 'Great Britain and Northern Ireland', origin = 'country.name', destination = 'iso3c')

countrycode(sourcevar = 'SSD', origin = 'iso3c', destination = 'country.name.en.regex') %>%
  flag_search()

flag_search(text = "map", type = "category")



