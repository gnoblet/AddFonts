test_that("as_CacheEntryList converts native list to CacheEntryList", {
  l <- list(
    list(
      family = "roboto",
      meta = list(
        source = "google_fonts",
        files = list("400" = "roboto-regular.ttf")
      )
    ),
    list(
      family = "open-sans",
      meta = list(
        source = "google_fonts",
        files = list("400" = "open-sans-regular.ttf")
      )
    )
  )

  cel <- as_CacheEntryList(l)
  expect_s7_class(cel, CacheEntryList)
  fams <- unname(vapply(cel@entries, function(e) e@family, character(1)))
  expect_setequal(fams, c("roboto", "open-sans"))
})
