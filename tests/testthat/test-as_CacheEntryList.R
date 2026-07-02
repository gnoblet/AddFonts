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

test_that("as_CacheEntryList backfills failed_keys = character(0) for old JSON without field", {
  withr::local_tempdir()

  l <- list(
    list(
      family = "roboto",
      meta = list(
        source = "bunny",
        key_scheme = "weight",
        files = list("400" = "roboto-400.ttf")
        # no failed_keys field — simulates old cache format
      )
    )
  )

  cel <- as_CacheEntryList(l)
  expect_equal(cel@entries[["bunny::roboto"]]@meta@failed_keys, character(0))
})

test_that("as_CacheEntryList preserves failed_keys through round-trip", {
  withr::local_tempdir()

  original <- CacheEntryList(entries = list(
    "bunny::roboto" = CacheEntry(
      family = "roboto",
      meta = CacheMeta(
        source = "bunny",
        files = list("400" = "roboto-400.ttf"),
        failed_keys = c("700", "700italic")
      )
    )
  ))

  round_tripped <- as_CacheEntryList(as_list(original))
  expect_equal(
    round_tripped@entries[["bunny::roboto"]]@meta@failed_keys,
    c("700", "700italic")
  )
})
