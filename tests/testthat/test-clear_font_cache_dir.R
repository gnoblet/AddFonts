test_that("clear_font_cache_dir parameter validation works", {
  expect_error(
    clear_font_cache_dir("yes"),
    regexp = "must be a single logical value"
  )
  expect_error(
    clear_font_cache_dir(NULL),
    regexp = "must be a single logical value"
  )
  expect_error(
    clear_font_cache_dir(c(TRUE, FALSE)),
    regexp = "must be a single logical value"
  )
})

test_that("clear_font_cache_dir handles non-existent cache directory", {
  temp_dir <- fs::file_temp()

  with_mocked_bindings(
    get_font_cache_dir = function() temp_dir,
    {
      expect_message(
        result <- clear_font_cache_dir(confirm = FALSE),
        "No font cache directory found"
      )
      expect_true(result)
    }
  )
})

test_that("clear_font_cache_dir handles empty cache directory", {
  temp_dir <- fs::file_temp()
  fs::dir_create(temp_dir)

  with_mocked_bindings(
    get_font_cache_dir = function() temp_dir,
    {
      expect_message(
        result <- clear_font_cache_dir(confirm = FALSE),
        "No cached fonts found"
      )
      expect_true(result)
    }
  )

  fs::dir_delete(temp_dir)
})

test_that("clear_font_cache_dir deletes font files successfully", {
  temp_dir <- fs::file_temp()
  fs::dir_create(temp_dir)

  # Create mock font files
  font_files <- c(
    fs::path(temp_dir, "roboto-latin-400-normal.woff2"),
    fs::path(temp_dir, "lato-latin-700-normal.woff2")
  )

  for (file in font_files) {
    fs::file_create(file)
  }

  with_mocked_bindings(
    get_font_cache_dir = function() temp_dir,
    {
      expect_message(
        result <- clear_font_cache_dir(confirm = FALSE),
        "Font cache cleared successfully"
      )
      expect_true(result)
    }
  )

  # Files should be deleted
  expect_false(any(fs::file_exists(font_files)))

  fs::dir_delete(temp_dir)
})

test_that("clear_font_cache_dir ignores non-font files", {
  temp_dir <- fs::file_temp()
  fs::dir_create(temp_dir)

  font_file <- fs::path(temp_dir, "roboto-latin-400-normal.woff2")
  other_file <- fs::path(temp_dir, "readme.txt")

  fs::file_create(font_file)
  fs::file_create(other_file)

  with_mocked_bindings(
    get_font_cache_dir = function() temp_dir,
    {
      result <- clear_font_cache_dir(confirm = FALSE)
      expect_true(result)
    }
  )

  # Only font file deleted, other file remains
  expect_false(fs::file_exists(font_file))
  expect_true(fs::file_exists(other_file))

  fs::dir_delete(temp_dir)
})

test_that("clear_font_cache_dir with confirm=TRUE requires manual testing", {
  # Interactive confirmation can't be easily automated
  skip("Interactive confirmation requires manual testing")
})
