test_that("add_font_bunny parameter validation works", {
  expect_error(
    add_font_bunny(name = 123),
    regexp = "string"
  )
  expect_error(
    add_font_bunny(name = "roboto", regular.wt = "400"),
    regexp = "integerish"
  )
  expect_error(
    add_font_bunny(name = "roboto", italic = "yes"),
    regexp = "logical"
  )
})

test_that("add_font_bunny downloads and registers a font", {
  skip_on_cran()
  skip_if_offline()

  # Try adding a well-known font
  expect_no_error(add_font_bunny("roboto"))

  # Check that the font is now registered
  families <- sysfonts::font_families()
  expect_true("roboto" %in% families)
})

test_that("add_font_bunny handles non-existent fonts gracefully", {
  skip_on_cran()
  skip_if_offline()

  expect_error(
    add_font_bunny("DefinitelyNotARealFontName123"),
    regexp = "not found"
  )
})

test_that("add_font_bunny can use a custom family name", {
  skip_on_cran()
  skip_if_offline()

  expect_no_error(add_font_bunny("roboto", family = "CustomRoboto"))
  families <- sysfonts::font_families()
  expect_true("CustomRoboto" %in% families)
})

test_that("add_font_bunny respects cache_dir parameter", {
  skip_on_cran()
  skip_if_offline()

  temp_cache <- fs::file_temp()
  fs::dir_create(temp_cache)

  # Download to custom cache directory
  result <- add_font_bunny("roboto", cache_dir = temp_cache)

  # Check that files were created in custom directory
  cached_files <- fs::dir_ls(temp_cache, glob = "*.woff2")
  expect_true(length(cached_files) > 0)

  fs::dir_delete(temp_cache)
})

test_that("add_font_bunny uses default cache_dir when not specified", {
  skip_on_cran()
  skip_if_offline()

  get_font_cache_dir_called <- FALSE
  mock_cache_dir <- fs::file_temp()
  fs::dir_create(mock_cache_dir)

  local_mocked_bindings(
    get_font_cache_dir = function() {
      get_font_cache_dir_called <<- TRUE
      return(mock_cache_dir)
    }
  )

  # Mock the download function to avoid actual download
  local_mocked_bindings(
    .download_bunny_font = function(...) {
      return(fs::path(mock_cache_dir, "mock-font.woff2"))
    }
  )

  # Mock sysfonts::font_add
  local_mocked_bindings(
    font_add = function(...) invisible(NULL),
    .package = "sysfonts"
  )

  add_font_bunny("roboto")

  expect_true(get_font_cache_dir_called)

  if (fs::dir_exists(mock_cache_dir)) fs::dir_delete(mock_cache_dir)
})

test_that("add_font_bunny returns invisible list of font paths", {
  skip_on_cran()
  skip_if_offline()

  # Mock the download and registration
  mock_cache_dir <- fs::file_temp()
  fs::dir_create(mock_cache_dir)

  local_mocked_bindings(
    .download_bunny_font = function(...) {
      return(fs::path(mock_cache_dir, "mock-font.woff2"))
    }
  )

  local_mocked_bindings(
    font_add = function(...) invisible(NULL),
    .package = "sysfonts"
  )

  result <- add_font_bunny("roboto")

  expect_type(result, "list")
  expect_true("regular" %in% names(result))

  if (fs::dir_exists(mock_cache_dir)) fs::dir_delete(mock_cache_dir)
})

test_that("add_font_bunny handles weight validation", {
  skip_on_cran()
  skip_if_offline()

  # Roboto doesn't have weight 250
  expect_error(
    add_font_bunny("roboto", regular.wt = 250),
    regexp = "Weight.*not available"
  )
})

test_that("add_font_bunny caches font files correctly", {
  skip_on_cran()
  skip_if_offline()

  temp_cache <- fs::file_temp()
  fs::dir_create(temp_cache)

  # First call - should download
  result1 <- add_font_bunny("roboto", cache_dir = temp_cache)

  # Get list of cached files
  cached_files <- fs::dir_ls(temp_cache, glob = "*.woff2")
  expect_true(length(cached_files) > 0)

  # Record file modification times
  file_times <- fs::file_info(cached_files)$modification_time

  # Second call - should use cache (no download)
  result2 <- add_font_bunny(
    "roboto",
    cache_dir = temp_cache,
    family = "Roboto2"
  )

  # Modification times should be unchanged
  file_times2 <- fs::file_info(cached_files)$modification_time
  expect_equal(file_times, file_times2)

  fs::dir_delete(temp_cache)
})
