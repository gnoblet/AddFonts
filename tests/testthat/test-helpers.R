## ---- .validate_variants ----

test_that(".validate_variants passes a minimal valid list", {
  expect_no_error(.validate_variants(list(regular = "x")))
})

test_that(".validate_variants passes all four symbolic keys", {
  expect_no_error(
    .validate_variants(list(
      regular    = "r",
      italic     = "i",
      bold       = "b",
      bolditalic = "bi"
    ))
  )
})

test_that(".validate_variants errors on NULL", {
  expect_error(.validate_variants(NULL), "named list")
})

test_that(".validate_variants errors on unnamed list", {
  expect_error(.validate_variants(list("x")), "named list")
})

test_that(".validate_variants errors on unknown variant names", {
  expect_error(
    .validate_variants(list(regular = "r", heavy = "h")),
    "heavy"
  )
})

test_that(".validate_variants errors when 'regular' is absent", {
  expect_error(
    .validate_variants(list(bold = "b")),
    "regular"
  )
})

## ---- .persist_cache_entry ----

test_that(".persist_cache_entry returns a CacheEntry with correct fields", {
  tmp <- withr::local_tempdir()

  result <- .persist_cache_entry(
    source      = "url",
    family_name = "MyFont",
    files_entry = list(regular = "url-myfont-regular.ttf"),
    cache_dir   = tmp
  )

  expect_s7_class(result, CacheEntry)
  expect_equal(result@family, "MyFont")
  expect_equal(result@meta@source, "url")
  expect_equal(result@meta@files[["regular"]], "url-myfont-regular.ttf")
})

test_that(".persist_cache_entry writes fonts_db.json to disk", {
  tmp <- withr::local_tempdir()

  .persist_cache_entry(
    source      = "file",
    family_name = "LocalFont",
    files_entry = list(regular = "/tmp/LocalFont-Regular.ttf"),
    cache_dir   = tmp
  )

  expect_true(fs::file_exists(fs::path(tmp, "fonts_db.json")))
})

test_that(".persist_cache_entry entry is readable from cache", {
  tmp <- withr::local_tempdir()

  .persist_cache_entry(
    source      = "bunny",
    family_name = "Roboto",
    files_entry = list("400" = "bunny-roboto-latin-400-normal.ttf"),
    cache_dir   = tmp
  )

  cel     <- cache_read(tmp)
  entries <- cache_get(cel, families = "Roboto", source = "bunny", quiet = TRUE)
  expect_equal(length(entries), 1)
  expect_equal(entries[[1]]@family, "Roboto")
})

## ---- .fetch_url_to_cache ----

test_that(".fetch_url_to_cache returns local_path on success", {
  tmp        <- withr::local_tempdir()
  local_path <- as.character(fs::path(tmp, "font.ttf"))

  local_mocked_bindings(
    req_perform = function(req, path, ...) {
      writeLines("fake font", path)
      list()
    },
    .package = "httr2"
  )

  result <- .fetch_url_to_cache(
    url        = "https://example.com/font.ttf",
    local_path = local_path,
    family     = "MyFont",
    variant    = "regular",
    quiet      = TRUE
  )

  expect_equal(result, local_path)
  expect_true(fs::file_exists(result))
})

test_that(".fetch_url_to_cache returns NULL when httr2 errors", {
  tmp        <- withr::local_tempdir()
  local_path <- as.character(fs::path(tmp, "font.ttf"))

  local_mocked_bindings(
    req_perform = function(...) stop("Network error"),
    .package    = "httr2"
  )

  result <- suppressWarnings(.fetch_url_to_cache(
    url        = "https://example.com/font.ttf",
    local_path = local_path,
    family     = "MyFont",
    variant    = "regular",
    quiet      = TRUE
  ))

  expect_null(result)
})

test_that(".fetch_url_to_cache warns on failure when quiet = FALSE", {
  tmp        <- withr::local_tempdir()
  local_path <- as.character(fs::path(tmp, "font.ttf"))

  local_mocked_bindings(
    req_perform = function(...) stop("Network error"),
    .package    = "httr2"
  )

  expect_warning(
    .fetch_url_to_cache(
      url        = "https://example.com/font.ttf",
      local_path = local_path,
      family     = "MyFont",
      variant    = "regular",
      quiet      = FALSE
    ),
    "Download failed"
  )
})

## ---- .add_font_weight ----

test_that(".add_font_weight errors when regular.wt is not numeric", {
  tmp <- withr::local_tempdir()
  expect_error(
    .add_font_weight(
      provider_obj = new_bunny_provider(),
      name         = "Roboto",
      family_name  = "Roboto",
      regular.wt   = "400",
      bold.wt      = 700,
      subset       = "latin",
      cache_dir    = tmp
    ),
    "regular.wt"
  )
})

test_that(".add_font_weight errors when bold.wt is not numeric", {
  tmp <- withr::local_tempdir()
  expect_error(
    .add_font_weight(
      provider_obj = new_bunny_provider(),
      name         = "Roboto",
      family_name  = "Roboto",
      regular.wt   = 400,
      bold.wt      = "700",
      subset       = "latin",
      cache_dir    = tmp
    ),
    "bold.wt"
  )
})

test_that(".add_font_weight errors when subset is empty", {
  tmp <- withr::local_tempdir()
  expect_error(
    .add_font_weight(
      provider_obj = new_bunny_provider(),
      name         = "Roboto",
      family_name  = "Roboto",
      regular.wt   = 400,
      bold.wt      = 700,
      subset       = "",
      cache_dir    = tmp
    ),
    "empty"
  )
})

## ---- .add_font_file ----

test_that(".add_font_file errors when variants is invalid", {
  tmp <- withr::local_tempdir()
  expect_error(
    .add_font_file(
      provider_obj = FontProviderFile(
        source   = "bbb",
        base_url = "https://example.com/{family}/{filename}.ttf"
      ),
      name        = "Alpaga",
      family_name = "Alpaga",
      variants    = list(bold = "Alpaga-Bold"),
      cache_dir   = tmp
    ),
    "regular"
  )
})

test_that(".add_font_file registers from cache on hit", {
  tmp <- withr::local_tempdir()

  fake_entry <- CacheEntry(
    family = "Alpaga",
    meta   = CacheMeta(source = "bbb", files = list(regular = "r.ttf"))
  )
  fake_cel   <- CacheEntryList(entries = list(fake_entry))
  fake_files <- list(regular = "r.ttf", italic = "r.ttf", bold = "r.ttf", bolditalic = "r.ttf")

  tracker <- new.env(parent = emptyenv())
  tracker$downloaded <- FALSE

  local_mocked_bindings(
    cache_read           = function(...) fake_cel,
    register_from_cache  = function(...) fake_files,
    download_and_cache_file = function(...) { tracker$downloaded <- TRUE; fake_entry },
    .package = "AddFonts"
  )

  res <- .add_font_file(
    provider_obj = FontProviderFile(
      source   = "bbb",
      base_url = "https://example.com/{family}/{filename}.ttf"
    ),
    name        = "Alpaga",
    family_name = "Alpaga",
    variants    = list(regular = "Alpaga-Regular"),
    cache_dir   = tmp
  )

  expect_false(tracker$downloaded)
  expect_equal(res, fake_files)
})

## ---- .add_font_local ----

test_that(".add_font_local errors when variants is invalid", {
  tmp <- withr::local_tempdir()
  expect_error(
    .add_font_local(
      name        = "MyFont",
      family_name = "MyFont",
      variants    = list(bold = "/tmp/Bold.ttf"),
      cache_dir   = tmp
    ),
    "regular"
  )
})

test_that(".add_font_local calls copy_and_cache_local on cache miss", {
  tmp <- withr::local_tempdir()

  src <- fs::path(tmp, "MyFont-Regular.ttf")
  writeLines("data", src)

  fake_entry <- CacheEntry(
    family = "MyFont",
    meta   = CacheMeta(source = "file", files = list(regular = as.character(src)))
  )
  fake_files <- list(regular = as.character(src), italic = as.character(src),
                     bold = as.character(src), bolditalic = as.character(src))

  tracker <- new.env(parent = emptyenv())
  tracker$copy_called <- FALSE

  local_mocked_bindings(
    cache_read           = function(...) CacheEntryList(entries = list()),
    copy_and_cache_local = function(...) { tracker$copy_called <- TRUE; fake_entry },
    register_from_cache  = function(...) fake_files,
    .package = "AddFonts"
  )

  .add_font_local(
    name        = "MyFont",
    family_name = "MyFont",
    variants    = list(regular = as.character(src)),
    cache_dir   = tmp
  )

  expect_true(tracker$copy_called)
})

## ---- .add_font_direct_url ----

test_that(".add_font_direct_url errors when variants is invalid", {
  tmp <- withr::local_tempdir()
  expect_error(
    .add_font_direct_url(
      name        = "MyFont",
      family_name = "MyFont",
      variants    = list(bold = "https://example.com/Bold.ttf"),
      cache_dir   = tmp
    ),
    "regular"
  )
})

test_that(".add_font_direct_url calls download_and_cache_url on cache miss", {
  tmp <- withr::local_tempdir()

  src <- "/fake/url-myfont-regular.ttf"

  fake_entry <- CacheEntry(
    family = "MyFont",
    meta   = CacheMeta(source = "url", files = list(regular = src))
  )
  fake_files <- list(regular = src, italic = src, bold = src, bolditalic = src)

  tracker <- new.env(parent = emptyenv())
  tracker$download_called <- FALSE

  local_mocked_bindings(
    cache_read             = function(...) CacheEntryList(entries = list()),
    download_and_cache_url = function(...) { tracker$download_called <- TRUE; fake_entry },
    register_from_cache    = function(...) fake_files,
    .package = "AddFonts"
  )

  .add_font_direct_url(
    name        = "MyFont",
    family_name = "MyFont",
    variants    = list(regular = "https://example.com/MyFont-Regular.ttf"),
    cache_dir   = tmp
  )

  expect_true(tracker$download_called)
})
