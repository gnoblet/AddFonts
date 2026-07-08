## helper
new_bbb_provider <- function() {
  FontProviderFile(
    source = "bbb",
    base_url = "https://gitlab.com/bye-bye-binary/{family}/-/raw/main/ttf/{filename}.ttf"
  )
}

## ---- Argument validation ----

test_that("download_and_cache_file rejects non-FontProviderFile provider", {
  tmp <- withr::local_tempdir()
  expect_error(
    download_and_cache_file(
      provider = "bunny",
      name = "Alpaga",
      family_name = "Alpaga",
      variants = list(regular = "Alpaga-Regular"),
      cache_dir = tmp
    ),
    "FontProviderFile"
  )
})

test_that("download_and_cache_file rejects variants without 'regular' key", {
  tmp <- withr::local_tempdir()
  expect_error(
    download_and_cache_file(
      provider = new_bbb_provider(),
      name = "Alpaga",
      family_name = "Alpaga",
      variants = list(bold = "Alpaga-Bold"),
      cache_dir = tmp
    ),
    "regular"
  )
})

test_that("download_and_cache_file rejects unknown variant keys", {
  tmp <- withr::local_tempdir()
  expect_error(
    download_and_cache_file(
      provider = new_bbb_provider(),
      name = "Alpaga",
      family_name = "Alpaga",
      variants = list(regular = "Alpaga-Regular", heavy = "Alpaga-Heavy"),
      cache_dir = tmp
    ),
    "heavy"
  )
})

test_that("download_and_cache_file rejects unnamed variants list", {
  tmp <- withr::local_tempdir()
  expect_error(
    download_and_cache_file(
      provider = new_bbb_provider(),
      name = "Alpaga",
      family_name = "Alpaga",
      variants = list("Alpaga-Regular"),
      cache_dir = tmp
    ),
    "named list"
  )
})

## ---- Download success ----

test_that("download_and_cache_file returns CacheEntry with symbolic keys", {
  tmp <- withr::local_tempdir()

  local_mocked_bindings(
    download_variant_file = function(
      provider,
      family,
      filename,
      variant,
      cache_dir,
      quiet
    ) {
      path <- fs::path(cache_dir, paste0(variant, ".ttf"))
      writeLines("data", path)
      as.character(path)
    }
  )

  result <- download_and_cache_file(
    provider = new_bbb_provider(),
    name = "Alpaga",
    family_name = "Alpaga",
    variants = list(regular = "Alpaga-Regular", bold = "Alpaga-Bold"),
    cache_dir = tmp
  )

  expect_s7_class(result, CacheEntry)
  expect_equal(result@family, "Alpaga")
  expect_equal(result@meta@source, "bbb")
  expect_setequal(names(result@meta@files), c("regular", "bold"))
})

test_that("download_and_cache_file writes cache to disk", {
  tmp <- withr::local_tempdir()

  local_mocked_bindings(
    download_variant_file = function(
      provider,
      family,
      filename,
      variant,
      cache_dir,
      quiet
    ) {
      path <- fs::path(cache_dir, paste0(variant, ".ttf"))
      writeLines("data", path)
      as.character(path)
    }
  )

  download_and_cache_file(
    provider = new_bbb_provider(),
    name = "Alpaga",
    family_name = "Alpaga",
    variants = list(regular = "Alpaga-Regular"),
    cache_dir = tmp
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
    provider = new_bbb_provider(),
    name = "Alpaga",
    family_name = "Alpaga",
    variants = list(regular = "Alpaga-Regular"),
    cache_dir = tmp
  )

  expect_null(result)
})

## ---- download_and_cache_url ----

test_that("download_and_cache_url returns CacheEntry with source 'url' and symbolic keys", {
  tmp <- withr::local_tempdir()

  local_mocked_bindings(
    .fetch_url_to_cache = function(url, local_path, family, variant, quiet) {
      writeLines("data", local_path)
      local_path
    }
  )

  result <- download_and_cache_url(
    name = "MyFont",
    family_name = "MyFont",
    variants = list(
      regular = "https://example.com/MyFont-Regular.ttf",
      bold = "https://example.com/MyFont-Bold.ttf"
    ),
    cache_dir = tmp
  )

  expect_s7_class(result, CacheEntry)
  expect_equal(result@family, "MyFont")
  expect_equal(result@meta@source, "url")
  expect_setequal(names(result@meta@files), c("regular", "bold"))
})

test_that("download_and_cache_url writes fonts_db.json", {
  tmp <- withr::local_tempdir()

  local_mocked_bindings(
    .fetch_url_to_cache = function(url, local_path, family, variant, quiet) {
      writeLines("data", local_path)
      local_path
    }
  )

  download_and_cache_url(
    name = "MyFont",
    family_name = "MyFont",
    variants = list(regular = "https://example.com/MyFont-Regular.ttf"),
    cache_dir = tmp
  )

  expect_true(fs::file_exists(fs::path(tmp, "fonts_db.json")))
  cel <- cache_read(tmp)
  entries <- cache_get(cel, families = "MyFont", source = "url", quiet = TRUE)
  expect_equal(length(entries), 1)
})

test_that("download_and_cache_url returns NULL when regular URL fetch fails", {
  tmp <- withr::local_tempdir()

  local_mocked_bindings(
    .fetch_url_to_cache = function(...) NULL
  )

  result <- download_and_cache_url(
    name = "MyFont",
    family_name = "MyFont",
    variants = list(regular = "https://example.com/MyFont-Regular.ttf"),
    cache_dir = tmp
  )

  expect_null(result)
})

test_that("download_and_cache_url rejects variants without 'regular'", {
  tmp <- withr::local_tempdir()
  expect_error(
    download_and_cache_url(
      name = "MyFont",
      family_name = "MyFont",
      variants = list(bold = "https://example.com/MyFont-Bold.ttf"),
      cache_dir = tmp
    ),
    "regular"
  )
})

## ---- copy_and_cache_local ----

test_that("copy_and_cache_local returns CacheEntry with source 'file' and symbolic keys", {
  tmp <- withr::local_tempdir()

  src_reg <- fs::path(tmp, "MyFont-Regular.ttf")
  src_bold <- fs::path(tmp, "MyFont-Bold.ttf")
  writeLines("data", src_reg)
  writeLines("data", src_bold)
  cache <- fs::path(tmp, "cache")
  fs::dir_create(cache)

  result <- copy_and_cache_local(
    name = "MyFont",
    family_name = "MyFont",
    variants = list(
      regular = as.character(src_reg),
      bold = as.character(src_bold)
    ),
    cache_dir = as.character(cache)
  )

  expect_s7_class(result, CacheEntry)
  expect_equal(result@family, "MyFont")
  expect_equal(result@meta@source, "file")
  expect_setequal(names(result@meta@files), c("regular", "bold"))
})

test_that("copy_and_cache_local writes fonts_db.json", {
  tmp <- withr::local_tempdir()

  src <- fs::path(tmp, "MyFont-Regular.ttf")
  writeLines("data", src)
  cache <- fs::path(tmp, "cache")
  fs::dir_create(cache)

  copy_and_cache_local(
    name = "MyFont",
    family_name = "MyFont",
    variants = list(regular = as.character(src)),
    cache_dir = as.character(cache)
  )

  expect_true(fs::file_exists(fs::path(cache, "fonts_db.json")))
  cel <- cache_read(as.character(cache))
  entries <- cache_get(cel, families = "MyFont", source = "file", quiet = TRUE)
  expect_equal(length(entries), 1)
})

test_that("copy_and_cache_local returns NULL when regular copy fails", {
  tmp <- withr::local_tempdir()
  cache <- fs::path(tmp, "cache")
  fs::dir_create(cache)

  result <- suppressWarnings(copy_and_cache_local(
    name = "MyFont",
    family_name = "MyFont",
    variants = list(regular = as.character(fs::path(tmp, "nonexistent.ttf"))),
    cache_dir = as.character(cache)
  ))

  expect_null(result)
})

test_that("copy_and_cache_local rejects variants without 'regular'", {
  tmp <- withr::local_tempdir()
  src <- fs::path(tmp, "MyFont-Bold.ttf")
  writeLines("data", src)

  expect_error(
    copy_and_cache_local(
      name = "MyFont",
      family_name = "MyFont",
      variants = list(bold = as.character(src)),
      cache_dir = as.character(tmp)
    ),
    "regular"
  )
})
