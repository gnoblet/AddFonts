test_that("add_font_bunny parameter validation works", {
  expect_error(
    add_font_bunny(name = 123),
    regexp = "non-empty string"
  )
  expect_error(
    add_font_bunny(name = "roboto", wt = "400"),
    regexp = "must be NULL or integer"
  )
  expect_error(
    add_font_bunny(name = "roboto", styles = "invalid"),
    regexp = "must be one of"
  )
})

test_that("add_font_bunny downloads and registers a font", {
  skip_if_offline()

  # Try adding a well-known font
  expect_no_error(add_font_bunny("roboto"))

  # Check that the font is now registered
  families <- sysfonts::font_families()
  expect_true("roboto" %in% families)
})

test_that("add_font_bunny handles non-existent fonts gracefully", {
  skip_if_offline()

  expect_error(
    add_font_bunny("DefinitelyNotARealFontName123"),
    regexp = "not found"
  )
})

test_that("add_font_bunny can use a custom family name", {
  skip_if_offline()

  expect_no_error(add_font_bunny("roboto", family = "CustomRoboto"))
  families <- sysfonts::font_families()
  expect_true("CustomRoboto" %in% families)
})

test_that("add_font_bunny respects cache_dir parameter", {
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
  skip_if_offline()

  # Mock the download and registration
  mock_cache_dir <- fs::file_temp()
  fs::dir_create(mock_cache_dir)

  local_mocked_bindings(
    .download_bunny_font = function(font_id, weight, style, ...) {
      # Return a unique path for each weight/style combination
      return(fs::path(
        mock_cache_dir,
        sprintf("mock-%s-%d-%s.woff2", font_id, weight, style)
      ))
    }
  )

  local_mocked_bindings(
    font_add = function(...) invisible(NULL),
    .package = "sysfonts"
  )

  result <- add_font_bunny("roboto")

  expect_type(result, "list")
  # With new API, keys are like "normal_400", "italic_400", etc.
  expect_true(length(result) > 0)
  expect_true(any(grepl("normal_", names(result))))

  if (fs::dir_exists(mock_cache_dir)) fs::dir_delete(mock_cache_dir)
})

test_that("add_font_bunny handles weight validation", {
  skip_if_offline()

  # Roboto doesn't have weight 250
  expect_error(
    add_font_bunny("roboto", wt = 250),
    regexp = "Weight.*not available"
  )
})

test_that("add_font_bunny validates regular.wt parameter", {
  expect_error(
    add_font_bunny("roboto", wt = c(400, 700), regular.wt = "400"),
    regexp = "regular.wt.*must be NULL or a single integer"
  )
  expect_error(
    add_font_bunny("roboto", wt = c(400, 700), regular.wt = 50),
    regexp = "regular.wt.*must be NULL or a single integer"
  )
  expect_error(
    add_font_bunny("roboto", wt = c(400, 700), regular.wt = c(400, 700)),
    regexp = "regular.wt.*must be NULL or a single integer"
  )
})

test_that("add_font_bunny validates bold.wt parameter", {
  expect_error(
    add_font_bunny("roboto", wt = c(400, 700), bold.wt = "700"),
    regexp = "bold.wt.*must be NULL or a single integer"
  )
  expect_error(
    add_font_bunny("roboto", wt = c(400, 700), bold.wt = 1000),
    regexp = "bold.wt.*must be NULL or a single integer"
  )
  expect_error(
    add_font_bunny("roboto", wt = c(400, 700), bold.wt = c(400, 700)),
    regexp = "bold.wt.*must be NULL or a single integer"
  )
})

test_that("add_font_bunny validates regular.wt is in weights to download", {
  skip_if_offline()

  expect_error(
    add_font_bunny("roboto", wt = c(400, 700), regular.wt = 300),
    regexp = "regular.wt.*not in the weights to download"
  )
})

test_that("add_font_bunny validates bold.wt is in weights to download", {
  skip_if_offline()

  expect_error(
    add_font_bunny("roboto", wt = c(400, 700), bold.wt = 900),
    regexp = "bold.wt.*not in the weights to download"
  )
})

test_that("add_font_bunny respects custom regular.wt and bold.wt", {
  skip_if_offline()

  mock_cache_dir <- fs::file_temp()
  fs::dir_create(mock_cache_dir)

  font_args_captured <- NULL

  local_mocked_bindings(
    .download_bunny_font = function(font_id, weight, style, ...) {
      file_path <- fs::path(
        mock_cache_dir,
        sprintf("%s-%d-%s.woff2", font_id, weight, style)
      )
      fs::file_create(file_path)
      return(file_path)
    }
  )

  local_mocked_bindings(
    font_add = function(...) {
      font_args_captured <<- list(...)
      invisible(NULL)
    },
    .package = "sysfonts"
  )

  # Download weights 300, 400, 700 but use 400 as regular and 700 as bold
  add_font_bunny(
    "roboto",
    wt = c(300, 400, 700),
    regular.wt = 400,
    bold.wt = 700,
    styles = "normal",
    cache_dir = mock_cache_dir
  )

  # Check that correct files were passed to font_add
  expect_true(grepl("400-normal", font_args_captured$regular))
  expect_true(grepl("700-normal", font_args_captured$bold))
  # 300 should not be used for regular or bold
  expect_false(grepl("300-normal", font_args_captured$regular))

  if (fs::dir_exists(mock_cache_dir)) fs::dir_delete(mock_cache_dir)
})

test_that("add_font_bunny uses first/last weights as defaults for regular/bold", {
  skip_if_offline()

  mock_cache_dir <- fs::file_temp()
  fs::dir_create(mock_cache_dir)

  font_args_captured <- NULL

  local_mocked_bindings(
    .download_bunny_font = function(font_id, weight, style, ...) {
      file_path <- fs::path(
        mock_cache_dir,
        sprintf("%s-%d-%s.woff2", font_id, weight, style)
      )
      fs::file_create(file_path)
      return(file_path)
    }
  )

  local_mocked_bindings(
    font_add = function(...) {
      font_args_captured <<- list(...)
      invisible(NULL)
    },
    .package = "sysfonts"
  )

  # Download weights 300, 400, 700 without specifying regular.wt/bold.wt
  # Should use 300 as regular and 700 as bold (first and last)
  add_font_bunny(
    "roboto",
    wt = c(300, 400, 700),
    styles = "normal",
    cache_dir = mock_cache_dir
  )

  # Check that first weight (300) was used for regular
  expect_true(grepl("300-normal", font_args_captured$regular))
  # Check that last weight (700) was used for bold
  expect_true(grepl("700-normal", font_args_captured$bold))

  if (fs::dir_exists(mock_cache_dir)) fs::dir_delete(mock_cache_dir)
})

test_that("add_font_bunny handles italic styles with custom weights", {
  skip_if_offline()

  mock_cache_dir <- fs::file_temp()
  fs::dir_create(mock_cache_dir)

  font_args_captured <- NULL

  local_mocked_bindings(
    .download_bunny_font = function(font_id, weight, style, ...) {
      file_path <- fs::path(
        mock_cache_dir,
        sprintf("%s-%d-%s.woff2", font_id, weight, style)
      )
      fs::file_create(file_path)
      return(file_path)
    }
  )

  local_mocked_bindings(
    font_add = function(...) {
      font_args_captured <<- list(...)
      invisible(NULL)
    },
    .package = "sysfonts"
  )

  # Download with both normal and italic, custom weights
  add_font_bunny(
    "roboto",
    wt = c(300, 400, 700),
    regular.wt = 400,
    bold.wt = 700,
    styles = "both",
    cache_dir = mock_cache_dir
  )

  # Check normal styles
  expect_true(grepl("400-normal", font_args_captured$regular))
  expect_true(grepl("700-normal", font_args_captured$bold))

  # Check italic styles
  expect_true(grepl("400-italic", font_args_captured$italic))
  expect_true(grepl("700-italic", font_args_captured$bolditalic))

  if (fs::dir_exists(mock_cache_dir)) fs::dir_delete(mock_cache_dir)
})

test_that("add_font_bunny downloads specific weights", {
  skip_if_offline()

  temp_cache <- fs::file_temp()
  fs::dir_create(temp_cache)

  # Download only specific weights
  result <- add_font_bunny("roboto", wt = c(400, 700), cache_dir = temp_cache)

  # Check that files were created
  cached_files <- fs::dir_ls(temp_cache, glob = "*.woff2")
  expect_true(length(cached_files) > 0)

  # Check that result contains expected weight keys
  expect_true(any(grepl("400", names(result))))
  expect_true(any(grepl("700", names(result))))

  fs::dir_delete(temp_cache)
})

test_that("add_font_bunny downloads only normal styles", {
  skip_if_offline()

  temp_cache <- fs::file_temp()
  fs::dir_create(temp_cache)

  # Download only normal styles
  result <- add_font_bunny(
    "roboto",
    wt = 400,
    styles = "normal",
    cache_dir = temp_cache
  )

  # Check that files were created
  cached_files <- fs::dir_ls(temp_cache, glob = "*.woff2")
  expect_true(length(cached_files) > 0)

  # Should not have italic files
  expect_false(any(grepl("italic", cached_files)))

  fs::dir_delete(temp_cache)
})

test_that("add_font_bunny downloads only italic styles", {
  skip_if_offline()

  temp_cache <- fs::file_temp()
  fs::dir_create(temp_cache)

  # Download only italic styles
  result <- add_font_bunny(
    "roboto",
    wt = c(400, 700),
    styles = "italic",
    cache_dir = temp_cache
  )

  # Check that files were created
  cached_files <- fs::dir_ls(temp_cache, glob = "*.woff2")
  expect_true(length(cached_files) > 0)

  # All files should be italic
  expect_true(all(grepl("italic", cached_files)))

  fs::dir_delete(temp_cache)
})

test_that("add_font_bunny downloads all weights when wt = NULL", {
  skip_if_offline()

  temp_cache <- fs::file_temp()
  fs::dir_create(temp_cache)

  # Mock to avoid downloading too many files
  local_mocked_bindings(
    .download_bunny_font = function(font_id, weight, style, ...) {
      file_path <- fs::path(
        temp_cache,
        sprintf("%s-%d-%s.woff2", font_id, weight, style)
      )
      fs::file_create(file_path)
      return(file_path)
    }
  )

  local_mocked_bindings(
    font_add = function(...) invisible(NULL),
    .package = "sysfonts"
  )

  # wt = NULL should download all available weights
  result <- add_font_bunny(
    "roboto",
    wt = NULL,
    styles = "normal",
    cache_dir = temp_cache
  )

  # Roboto has many weights, should have multiple files
  expect_true(length(result) > 2)

  if (fs::dir_exists(temp_cache)) fs::dir_delete(temp_cache)
})

test_that("add_font_bunny caches font files correctly", {
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
