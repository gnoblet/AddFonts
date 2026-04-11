test_that("download_variant_generic validates weight and returns appropriate errors", {
  provider <- new_bunny_provider()
  expect_error(
    download_variant_generic(provider, "fam", 50, "normal"),
    "must be a single integer"
  )
})

test_that("download_variant_generic returns TTF path on success without conversion", {
  provider <- FontProvider(
    source = "test",
    url_template = "https://example.com/%s/%s/%s/%d/%s",
    conversion = NULL,
    conversion_ext = NULL,
    aliases = list()
  )

  tmp <- withr::local_tempdir()
  ttf_path <- file.path(tmp, "font-400-normal.ttf")

  local_mocked_bindings(
    cache_variant_paths = function(...) list(ttf = ttf_path, to_convert = NULL),
    .package = "AddFonts"
  )
  local_mocked_bindings(
    req_perform = function(req, path, ...) {
      writeLines("fake", path)
      list()
    },
    .package = "httr2"
  )

  result <- download_variant_generic(provider, "test-fam", 400, "normal", cache_dir = tmp)
  expect_equal(result, ttf_path)
  expect_true(file.exists(ttf_path))
})

test_that("download_variant_generic returns TTF path on success with conversion", {
  provider <- new_bunny_provider()

  tmp <- withr::local_tempdir()
  woff2_path <- file.path(tmp, "font-400-normal.woff2")
  ttf_path <- file.path(tmp, "font-400-normal.ttf")

  local_mocked_bindings(
    cache_variant_paths = function(...)
      list(ttf = ttf_path, to_convert = woff2_path),
    .package = "AddFonts"
  )
  local_mocked_bindings(
    req_perform = function(req, path, ...) {
      writeLines("fake woff2", path)
      list()
    },
    .package = "httr2"
  )
  local_mocked_bindings(
    conv_fun = function(...) function(from, ...) {
      writeLines("fake ttf", ttf_path)
      invisible(ttf_path)
    },
    .package = "AddFonts"
  )

  result <- download_variant_generic(provider, "test-fam", 400, "normal", cache_dir = tmp)
  expect_equal(result, ttf_path)
})

test_that("download_variant_generic returns NULL and warns on download failure", {
  provider <- FontProvider(
    source = "test",
    url_template = "https://example.com/%s/%s/%s/%d/%s",
    conversion = NULL,
    conversion_ext = NULL,
    aliases = list()
  )

  tmp <- withr::local_tempdir()
  ttf_path <- file.path(tmp, "font-400-normal.ttf")

  local_mocked_bindings(
    cache_variant_paths = function(...) list(ttf = ttf_path, to_convert = NULL),
    .package = "AddFonts"
  )
  local_mocked_bindings(
    req_perform = function(...) stop("connection refused"),
    .package = "httr2"
  )

  expect_warning(
    result <- download_variant_generic(provider, "test-fam", 400, "normal", cache_dir = tmp),
    "Download failed"
  )
  expect_null(result)
})

test_that("download_variant_generic returns NULL silently on download failure when quiet", {
  provider <- FontProvider(
    source = "test",
    url_template = "https://example.com/%s/%s/%s/%d/%s",
    conversion = NULL,
    conversion_ext = NULL,
    aliases = list()
  )

  tmp <- withr::local_tempdir()
  ttf_path <- file.path(tmp, "font-400-normal.ttf")

  local_mocked_bindings(
    cache_variant_paths = function(...) list(ttf = ttf_path, to_convert = NULL),
    .package = "AddFonts"
  )
  local_mocked_bindings(
    req_perform = function(...) stop("connection refused"),
    .package = "httr2"
  )

  expect_no_warning(
    result <- download_variant_generic(provider, "test-fam", 400, "normal", cache_dir = tmp, quiet = TRUE)
  )
  expect_null(result)
})

test_that("download_variant_generic returns NULL and warns on conversion failure", {
  provider <- new_bunny_provider()

  tmp <- withr::local_tempdir()
  woff2_path <- file.path(tmp, "font-400-normal.woff2")
  ttf_path <- file.path(tmp, "font-400-normal.ttf")

  local_mocked_bindings(
    cache_variant_paths = function(...)
      list(ttf = ttf_path, to_convert = woff2_path),
    .package = "AddFonts"
  )
  local_mocked_bindings(
    req_perform = function(req, path, ...) {
      writeLines("fake woff2", path)
      list()
    },
    .package = "httr2"
  )
  local_mocked_bindings(
    conv_fun = function(...) function(...) stop("conversion failed"),
    .package = "AddFonts"
  )

  expect_warning(
    result <- download_variant_generic(provider, "test-fam", 400, "normal", cache_dir = tmp),
    "Conversion failed"
  )
  expect_null(result)
  # Source file cleaned up on conversion failure
  expect_false(file.exists(woff2_path))
})

test_that("download_variant_generic warns when TTF missing after silent conversion failure", {
  # Conversion "succeeds" (no error thrown) but produces no TTF file
  provider <- new_bunny_provider()

  tmp <- withr::local_tempdir()
  woff2_path <- file.path(tmp, "font-400-normal.woff2")
  ttf_path <- file.path(tmp, "font-400-normal.ttf")

  local_mocked_bindings(
    cache_variant_paths = function(...)
      list(ttf = ttf_path, to_convert = woff2_path),
    .package = "AddFonts"
  )
  local_mocked_bindings(
    req_perform = function(req, path, ...) {
      writeLines("fake woff2", path)
      list()
    },
    .package = "httr2"
  )
  # Converter returns without error but creates no TTF
  local_mocked_bindings(
    conv_fun = function(...) function(...) invisible(NULL),
    .package = "AddFonts"
  )

  expect_warning(
    result <- download_variant_generic(provider, "test-fam", 400, "normal", cache_dir = tmp),
    "TTF file not found"
  )
  expect_null(result)
})
