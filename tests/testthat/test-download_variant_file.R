## helper: a minimal FontProviderFile for tests
new_bbb_provider <- function() {
  FontProviderFile(
    source   = "bbb",
    base_url = "https://gitlab.com/bye-bye-binary/{family}/-/raw/main/ttf/{filename}.ttf"
  )
}

## ---- Argument validation ----

test_that("download_variant_file rejects non-FontProviderFile provider", {
  tmp <- withr::local_tempdir()
  expect_error(
    download_variant_file(
      provider  = "bunny",
      family    = "Alpaga",
      filename  = "Alpaga-Regular",
      variant   = "regular",
      cache_dir = tmp
    ),
    "FontProviderFile"
  )
})

test_that("download_variant_file rejects unknown variant name", {
  tmp <- withr::local_tempdir()
  expect_error(
    download_variant_file(
      provider  = new_bbb_provider(),
      family    = "Alpaga",
      filename  = "Alpaga-Regular",
      variant   = "heavy",
      cache_dir = tmp
    ),
    "heavy"
  )
})

test_that("download_variant_file rejects empty family", {
  tmp <- withr::local_tempdir()
  expect_error(
    download_variant_file(
      provider  = new_bbb_provider(),
      family    = "",
      filename  = "Alpaga-Regular",
      variant   = "regular",
      cache_dir = tmp
    ),
    "empty"
  )
})

## ---- Download success and failure ----

test_that("download_variant_file returns local path on successful download", {
  tmp <- withr::local_tempdir()

  local_mocked_bindings(
    req_perform = function(req, path, ...) {
      writeLines("fake font data", path)
      list()
    },
    .package = "httr2"
  )

  result <- download_variant_file(
    provider  = new_bbb_provider(),
    family    = "Alpaga",
    filename  = "Alpaga-Regular",
    variant   = "regular",
    cache_dir = tmp,
    quiet     = TRUE
  )

  expect_false(is.null(result))
  expect_true(fs::file_exists(result))
  expect_match(basename(result), "bbb-alpaga-regular\\.ttf$")
})

test_that("download_variant_file returns NULL when download fails", {
  tmp <- withr::local_tempdir()

  local_mocked_bindings(
    req_perform = function(...) stop("Network error"),
    .package = "httr2"
  )

  result <- suppressWarnings(
    download_variant_file(
      provider  = new_bbb_provider(),
      family    = "Alpaga",
      filename  = "Alpaga-Regular",
      variant   = "regular",
      cache_dir = tmp,
      quiet     = TRUE
    )
  )

  expect_null(result)
})

test_that("download_variant_file builds URL from base_url template", {
  tmp <- withr::local_tempdir()
  tracker <- new.env(parent = emptyenv())
  tracker$url <- NULL

  local_mocked_bindings(
    req_perform = function(req, path, ...) {
      tracker$url <- req$url
      writeLines("data", path)
      list()
    },
    .package = "httr2"
  )

  download_variant_file(
    provider  = new_bbb_provider(),
    family    = "Alpaga",
    filename  = "Alpaga-Regular",
    variant   = "regular",
    cache_dir = tmp,
    quiet     = TRUE
  )

  expect_match(
    tracker$url,
    "gitlab.com/bye-bye-binary/Alpaga/-/raw/main/ttf/Alpaga-Regular.ttf"
  )
})
