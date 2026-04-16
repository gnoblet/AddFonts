## helper
new_bbb_provider <- function() {
  FontProviderFile(
    source   = "bbb",
    base_url = "https://gitlab.com/bye-bye-binary/{family}/-/raw/main/ttf/{filename}.ttf"
  )
}

## ---- Argument validation ----

test_that("download_and_cache_file rejects non-FontProviderFile provider", {
  tmp <- withr::local_tempdir()
  expect_error(
    download_and_cache_file(
      provider    = "bunny",
      name        = "Alpaga",
      family_name = "Alpaga",
      variants    = list(regular = "Alpaga-Regular"),
      cache_dir   = tmp
    ),
    "FontProviderFile"
  )
})

test_that("download_and_cache_file rejects variants without 'regular' key", {
  tmp <- withr::local_tempdir()
  expect_error(
    download_and_cache_file(
      provider    = new_bbb_provider(),
      name        = "Alpaga",
      family_name = "Alpaga",
      variants    = list(bold = "Alpaga-Bold"),
      cache_dir   = tmp
    ),
    "regular"
  )
})

test_that("download_and_cache_file rejects unknown variant keys", {
  tmp <- withr::local_tempdir()
  expect_error(
    download_and_cache_file(
      provider    = new_bbb_provider(),
      name        = "Alpaga",
      family_name = "Alpaga",
      variants    = list(regular = "Alpaga-Regular", heavy = "Alpaga-Heavy"),
      cache_dir   = tmp
    ),
    "heavy"
  )
})

test_that("download_and_cache_file rejects unnamed variants list", {
  tmp <- withr::local_tempdir()
  expect_error(
    download_and_cache_file(
      provider    = new_bbb_provider(),
      name        = "Alpaga",
      family_name = "Alpaga",
      variants    = list("Alpaga-Regular"),
      cache_dir   = tmp
    ),
    "named list"
  )
})

## ---- Download success ----

test_that("download_and_cache_file returns CacheEntry with symbolic keys", {
  tmp <- withr::local_tempdir()

  local_mocked_bindings(
    download_variant_file = function(provider, family, filename, variant,
                                     cache_dir, quiet) {
      path <- fs::path(cache_dir, paste0(variant, ".ttf"))
      writeLines("data", path)
      as.character(path)
    }
  )

  result <- download_and_cache_file(
    provider    = new_bbb_provider(),
    name        = "Alpaga",
    family_name = "Alpaga",
    variants    = list(regular = "Alpaga-Regular", bold = "Alpaga-Bold"),
    cache_dir   = tmp
  )

  expect_s7_class(result, CacheEntry)
  expect_equal(result@family, "Alpaga")
  expect_equal(result@meta@source, "bbb")
  expect_setequal(names(result@meta@files), c("regular", "bold"))
})

test_that("download_and_cache_file writes cache to disk", {
  tmp <- withr::local_tempdir()

  local_mocked_bindings(
    download_variant_file = function(provider, family, filename, variant,
                                     cache_dir, quiet) {
      path <- fs::path(cache_dir, paste0(variant, ".ttf"))
      writeLines("data", path)
      as.character(path)
    }
  )

  download_and_cache_file(
    provider    = new_bbb_provider(),
    name        = "Alpaga",
    family_name = "Alpaga",
    variants    = list(regular = "Alpaga-Regular"),
    cache_dir   = tmp
  )

  expect_true(fs::file_exists(fs::path(tmp, "fonts_db.json")))

  cel <- cache_read(tmp)
  entries <- cache_get(cel, families = "Alpaga", source = "bbb", quiet = TRUE)
  expect_equal(length(entries), 1)
})

test_that("download_and_cache_file returns NULL when regular variant fails", {
  tmp <- withr::local_tempdir()

  local_mocked_bindings(
    download_variant_file = function(...) NULL
  )

  result <- download_and_cache_file(
    provider    = new_bbb_provider(),
    name        = "Alpaga",
    family_name = "Alpaga",
    variants    = list(regular = "Alpaga-Regular"),
    cache_dir   = tmp
  )

  expect_null(result)
})
