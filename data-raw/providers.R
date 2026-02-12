# Read inst/extdata/providers.json and save as internal dataset 'providers'
library(jsonlite)
providers <- jsonlite::read_json(
  "inst/extdata/providers.json",
  simplifyVector = FALSE
)

usethis::use_data(providers, internal = TRUE, overwrite = TRUE)
