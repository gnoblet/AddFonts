test_that("add_font uses cache when available (mocked)", {
  fake_files <- list(
    regular = "a.ttf",
    italic = "b.ttf",
    bold = "c.ttf",
    bolditalic = "d.ttf"
  )

  # Create a mock CacheEntry with matching weights (400 and 700)
  fake_entry <- CacheEntry(
    family = "somefont",
    meta = CacheMeta(
      source = "bunny",
      files = list(
        "400" = "a.ttf",
        "400italic" = "b.ttf",
        "700" = "c.ttf",
        "700italic" = "d.ttf"
      )
    )
  )

  # Create a mock CacheEntryList with our entry
  fake_cache <- CacheEntryList(entries = list(fake_entry))

  local_mocked_bindings(
    cache_read = function(...) fake_cache,
    register_from_cache = function(entry, ...) fake_files,
    .package = "AddFonts"
  )
  res <- add_font(
    "somefont",
    provider = "bunny",
    family = "somefont"
  )
  expect_equal(res, fake_files)
})


test_that("add_font re-downloads when weights don't match cached weights", {
  fake_files_old <- list(
    regular = "a.ttf",
    italic = "b.ttf",
    bold = "c.ttf",
    bolditalic = "d.ttf"
  )

  fake_files_new <- list(
    regular = "e.ttf",
    italic = "f.ttf",
    bold = "g.ttf",
    bolditalic = "h.ttf"
  )

  # Create a mock CacheEntry with different weights (300/900 != requested 400/700)
  fake_entry <- CacheEntry(
    family = "somefont",
    meta = CacheMeta(
      source = "bunny",
      files = list(
        "300" = "a.ttf",
        "300italic" = "b.ttf",
        "900" = "c.ttf",
        "900italic" = "d.ttf"
      )
    )
  )

  # Create a mock CacheEntryList with our entry
  fake_cache <- CacheEntryList(entries = list(fake_entry))

  # Track if download_and_cache was called (it should be)
  tracker <- new.env(parent = emptyenv())
  tracker$download_called <- FALSE

  # Create a fake new cache entry for download_and_cache to return
  fake_new_entry <- CacheEntry(
    family = "somefont",
    meta = CacheMeta(
      source = "bunny",
      files = list(
        "400" = "e.ttf",
        "400italic" = "f.ttf",
        "700" = "g.ttf",
        "700italic" = "h.ttf"
      )
    )
  )

  local_mocked_bindings(
    cache_read = function(...) fake_cache,
    cache_remove = function(cel, ...) cel,
    cache_write = function(...) NULL,
    download_and_cache = function(...) {
      tracker$download_called <- TRUE
      fake_new_entry
    },
    register_from_cache = function(entry, ...) {
      if (tracker$download_called) fake_files_new else fake_files_old
    },
    .package = "AddFonts"
  )
  res <- add_font(
    "somefont",
    provider = "bunny",
    family = "somefont",
    regular.wt = 400,
    bold.wt = 700
  )
  expect_true(tracker$download_called)
  expect_equal(res, fake_files_new)
})

test_that("add_font re-downloads when cached weights are missing", {
  fake_files_old <- list(
    regular = "a.ttf",
    italic = "b.ttf",
    bold = "c.ttf",
    bolditalic = "d.ttf"
  )

  fake_files_new <- list(
    regular = "e.ttf",
    italic = "f.ttf",
    bold = "g.ttf",
    bolditalic = "h.ttf"
  )

  # Create a mock CacheEntry with only weight 500 (missing requested 400/700)
  fake_entry <- CacheEntry(
    family = "somefont",
    meta = CacheMeta(
      source = "bunny",
      files = list(
        "500" = "a.ttf",
        "500italic" = "b.ttf"
      )
    )
  )

  # Create a mock CacheEntryList with our entry
  fake_cache <- CacheEntryList(entries = list(fake_entry))

  # Track if download_and_cache was called (it should be)
  tracker <- new.env(parent = emptyenv())
  tracker$download_called <- FALSE

  # Create a fake new cache entry for download_and_cache to return
  fake_new_entry <- CacheEntry(
    family = "somefont",
    meta = CacheMeta(
      source = "bunny",
      files = list(
        "400" = "e.ttf",
        "400italic" = "f.ttf",
        "700" = "g.ttf",
        "700italic" = "h.ttf"
      )
    )
  )

  local_mocked_bindings(
    cache_read = function(...) fake_cache,
    cache_remove = function(cel, ...) cel,
    cache_write = function(...) NULL,
    download_and_cache = function(...) {
      tracker$download_called <- TRUE
      fake_new_entry
    },
    register_from_cache = function(entry, ...) {
      if (tracker$download_called) fake_files_new else fake_files_old
    },
    .package = "AddFonts"
  )
  res <- add_font(
    "somefont",
    provider = "bunny",
    family = "somefont",
    regular.wt = 400,
    bold.wt = 700
  )
  expect_true(tracker$download_called)
  expect_equal(res, fake_files_new)
})

test_that("add_font validates input arguments", {
  expect_error(add_font(NULL), "non-empty character string")
  expect_error(add_font(""), "non-empty character string")
  expect_error(add_font("font", provider = ""), "non-empty character string")
  expect_error(add_font("font", family = ""), "non-empty character string")
  expect_error(add_font("font", regular.wt = "400"), "single numeric weight")
  expect_error(add_font("font", regular.wt = c(400, 500)), "single numeric weight")
  expect_error(add_font("font", bold.wt = "700"), "single numeric weight")
  expect_error(add_font("font", subset = ""), "non-empty character string")
})

test_that("add_font re-downloads when register_from_cache returns NULL (stale entry)", {
  fake_entry <- CacheEntry(
    family = "somefont",
    meta = CacheMeta(source = "bunny", files = list("400" = "a.ttf", "700" = "b.ttf"))
  )
  fake_cache <- CacheEntryList(entries = list(fake_entry))
  fake_new_entry <- CacheEntry(
    family = "somefont",
    meta = CacheMeta(source = "bunny", files = list("400" = "c.ttf", "700" = "d.ttf"))
  )
  tracker <- new.env(parent = emptyenv())
  tracker$download_called <- FALSE

  local_mocked_bindings(
    cache_read = function(...) fake_cache,
    register_from_cache = function(...) NULL,
    cache_remove = function(cel, ...) cel,
    cache_write = function(...) NULL,
    download_and_cache = function(...) { tracker$download_called <- TRUE; fake_new_entry },
    .package = "AddFonts"
  )
  add_font("somefont", family = "somefont")
  expect_true(tracker$download_called)
})

test_that("add_font downloads missing bold and registers from updated entry", {
  fake_entry <- CacheEntry(
    family = "somefont",
    meta = CacheMeta(source = "bunny", files = list("400" = "a.ttf"))
  )
  fake_cache <- CacheEntryList(entries = list(fake_entry))
  fake_updated_entry <- CacheEntry(
    family = "somefont",
    meta = CacheMeta(source = "bunny", files = list("400" = "a.ttf", "700" = "b.ttf"))
  )
  fake_files <- list(regular = "a.ttf", italic = "a.ttf", bold = "b.ttf", bolditalic = "b.ttf")

  local_mocked_bindings(
    cache_read = function(...) fake_cache,
    update_download_and_cache = function(...) fake_updated_entry,
    register_from_cache = function(entry, ...) fake_files,
    .package = "AddFonts"
  )
  res <- add_font("somefont", family = "somefont")
  expect_equal(res, fake_files)
})

test_that("add_font falls back to full re-download when update_download_and_cache fails", {
  fake_entry <- CacheEntry(
    family = "somefont",
    meta = CacheMeta(source = "bunny", files = list("400" = "a.ttf"))
  )
  fake_cache <- CacheEntryList(entries = list(fake_entry))
  fake_new_entry <- CacheEntry(
    family = "somefont",
    meta = CacheMeta(source = "bunny", files = list("400" = "e.ttf", "700" = "f.ttf"))
  )
  fake_files <- list(regular = "e.ttf", italic = "e.ttf", bold = "f.ttf", bolditalic = "f.ttf")
  tracker <- new.env(parent = emptyenv())
  tracker$download_called <- FALSE

  local_mocked_bindings(
    cache_read = function(...) fake_cache,
    update_download_and_cache = function(...) NULL,
    cache_remove = function(cel, ...) cel,
    cache_write = function(...) NULL,
    download_and_cache = function(...) { tracker$download_called <- TRUE; fake_new_entry },
    register_from_cache = function(...) fake_files,
    .package = "AddFonts"
  )
  res <- add_font("somefont", family = "somefont")
  expect_true(tracker$download_called)
  expect_equal(res, fake_files)
})

test_that("add_font aborts when download_and_cache returns NULL", {
  local_mocked_bindings(
    cache_read = function(...) CacheEntryList(entries = list()),
    download_and_cache = function(...) NULL,
    .package = "AddFonts"
  )
  expect_error(add_font("nonexistent"), "Failed to obtain font")
})

## ---- provider = "file" ----

test_that("add_font with provider='file' registers from cache on second call", {
  tmp <- withr::local_tempdir()

  src <- fs::path(tmp, "MyFont-Regular.ttf")
  writeLines("data", src)

  fake_entry <- CacheEntry(
    family = "MyFont",
    meta   = CacheMeta(source = "file", files = list(regular = as.character(src)))
  )
  fake_cel <- CacheEntryList(entries = list(fake_entry))
  fake_files <- list(regular = as.character(src), italic = as.character(src),
                     bold = as.character(src), bolditalic = as.character(src))

  tracker <- new.env(parent = emptyenv())
  tracker$copy_called <- FALSE

  local_mocked_bindings(
    cache_read = function(...) fake_cel,
    register_from_cache = function(...) fake_files,
    copy_and_cache_local = function(...) { tracker$copy_called <- TRUE; fake_entry },
    .package = "AddFonts"
  )

  res <- add_font(
    "MyFont", provider = "file",
    variants = list(regular = as.character(src))
  )

  expect_false(tracker$copy_called)
  expect_equal(res, fake_files)
})

test_that("add_font with provider='file' copies and registers on first call", {
  tmp <- withr::local_tempdir()

  src <- fs::path(tmp, "MyFont-Regular.ttf")
  writeLines("data", src)

  fake_entry <- CacheEntry(
    family = "MyFont",
    meta   = CacheMeta(source = "file", files = list(regular = as.character(src)))
  )
  fake_files <- list(regular = as.character(src), italic = as.character(src),
                     bold = as.character(src), bolditalic = as.character(src))

  local_mocked_bindings(
    cache_read = function(...) CacheEntryList(entries = list()),
    copy_and_cache_local = function(...) fake_entry,
    register_from_cache  = function(...) fake_files,
    .package = "AddFonts"
  )

  res <- add_font(
    "MyFont", provider = "file",
    variants = list(regular = as.character(src))
  )

  expect_equal(res, fake_files)
})

test_that("add_font with provider='file' errors when regular variant missing", {
  tmp <- withr::local_tempdir()
  expect_error(
    add_font(
      "MyFont", provider = "file",
      variants = list(bold = as.character(fs::path(tmp, "MyFont-Bold.ttf")))
    ),
    "regular"
  )
})

## ---- provider = "url" ----

test_that("add_font with provider='url' registers from cache on second call", {
  src <- "/fake/cache/url-myfont-regular.ttf"

  fake_entry <- CacheEntry(
    family = "MyFont",
    meta   = CacheMeta(source = "url", files = list(regular = src))
  )
  fake_cel   <- CacheEntryList(entries = list(fake_entry))
  fake_files <- list(regular = src, italic = src, bold = src, bolditalic = src)

  tracker <- new.env(parent = emptyenv())
  tracker$download_called <- FALSE

  local_mocked_bindings(
    cache_read = function(...) fake_cel,
    register_from_cache = function(...) fake_files,
    download_and_cache_url = function(...) {
      tracker$download_called <- TRUE
      fake_entry
    },
    .package = "AddFonts"
  )

  res <- add_font(
    "MyFont", provider = "url",
    variants = list(regular = "https://example.com/MyFont-Regular.ttf")
  )

  expect_false(tracker$download_called)
  expect_equal(res, fake_files)
})

test_that("add_font with provider='url' downloads and registers on first call", {
  src <- "/fake/cache/url-myfont-regular.ttf"

  fake_entry <- CacheEntry(
    family = "MyFont",
    meta   = CacheMeta(source = "url", files = list(regular = src))
  )
  fake_files <- list(regular = src, italic = src, bold = src, bolditalic = src)

  local_mocked_bindings(
    cache_read = function(...) CacheEntryList(entries = list()),
    download_and_cache_url = function(...) fake_entry,
    register_from_cache    = function(...) fake_files,
    .package = "AddFonts"
  )

  res <- add_font(
    "MyFont", provider = "url",
    variants = list(regular = "https://example.com/MyFont-Regular.ttf")
  )

  expect_equal(res, fake_files)
})

test_that("add_font with provider='url' errors when regular variant missing", {
  expect_error(
    add_font(
      "MyFont", provider = "url",
      variants = list(bold = "https://example.com/MyFont-Bold.ttf")
    ),
    "regular"
  )
})
