test_that("woff2_to_ttf errors for missing or wrong extension files", {
  expect_error(woff2_to_ttf("nonexistent.woff2"), "Font file not found")
  tmp <- fs::file_temp(ext = "woff")
  writeLines("x", tmp)
  expect_error(woff2_to_ttf(tmp), "Expected a .woff2 file")
  if (fs::file_exists(tmp)) fs::file_delete(tmp)
})

test_that("woff2_to_ttf aborts when overwrite is non-logical", {
  tmp <- withr::local_tempfile(fileext = ".woff2")
  writeLines("x", tmp)
  expect_error(woff2_to_ttf(tmp, overwrite = "yes"), "must be a logical")
})

test_that("woff2_to_ttf aborts when woff2_decompress is not found", {
  tmp <- withr::local_tempfile(fileext = ".woff2")
  writeLines("x", tmp)

  local_mocked_bindings(
    Sys.which = function(x) setNames("", x),
    .package = "base"
  )

  expect_error(woff2_to_ttf(tmp), "woff2_decompress.*not found")
})

test_that("woff2_to_ttf returns existing TTF early when overwrite = FALSE", {
  tmp_dir <- withr::local_tempdir()
  woff2 <- file.path(tmp_dir, "font.woff2")
  ttf <- file.path(tmp_dir, "font.ttf")
  writeLines("fake woff2", woff2)
  writeLines("fake ttf", ttf)

  expect_message(
    result <- woff2_to_ttf(woff2, overwrite = FALSE),
    "Using existing ttf"
  )
  expect_equal(as.character(result), ttf)
})

test_that("woff2_to_ttf converts successfully and removes source when remove_old = TRUE", {
  tmp_dir <- withr::local_tempdir()
  woff2 <- file.path(tmp_dir, "font.woff2")
  ttf <- file.path(tmp_dir, "font.ttf")
  writeLines("fake woff2", woff2)

  local_mocked_bindings(
    Sys.which = function(x) setNames("/usr/bin/woff2_decompress", x),
    .package = "base"
  )
  local_mocked_bindings(
    system2 = function(command, args, ...) {
      writeLines("fake ttf", ttf)
      invisible(0L)
    },
    .package = "base"
  )

  result <- woff2_to_ttf(woff2, overwrite = TRUE, remove_old = TRUE, quiet = "full")
  expect_equal(as.character(result), ttf)
  expect_true(file.exists(ttf))
  expect_false(file.exists(woff2))
})

test_that("woff2_to_ttf keeps source when remove_old = FALSE", {
  tmp_dir <- withr::local_tempdir()
  woff2 <- file.path(tmp_dir, "font.woff2")
  ttf <- file.path(tmp_dir, "font.ttf")
  writeLines("fake woff2", woff2)

  local_mocked_bindings(
    Sys.which = function(x) setNames("/usr/bin/woff2_decompress", x),
    .package = "base"
  )
  local_mocked_bindings(
    system2 = function(command, args, ...) {
      writeLines("fake ttf", ttf)
      invisible(0L)
    },
    .package = "base"
  )

  woff2_to_ttf(woff2, remove_old = FALSE, quiet = "full")
  expect_true(file.exists(woff2))
})

test_that("woff2_to_ttf aborts on non-zero status when quiet is 'fail'", {
  tmp_dir <- withr::local_tempdir()
  woff2 <- file.path(tmp_dir, "font.woff2")
  writeLines("fake woff2", woff2)

  local_mocked_bindings(
    Sys.which = function(x) setNames("/usr/bin/woff2_decompress", x),
    .package = "base"
  )
  local_mocked_bindings(
    system2 = function(command, args, ...) {
      res <- "conversion error"
      attr(res, "status") <- 1L
      res
    },
    .package = "base"
  )

  expect_error(
    woff2_to_ttf(woff2, quiet = "fail"),
    "Error during conversion"
  )
})

test_that("woff2_to_ttf aborts when output file missing after conversion", {
  tmp_dir <- withr::local_tempdir()
  woff2 <- file.path(tmp_dir, "font.woff2")
  writeLines("fake woff2", woff2)

  local_mocked_bindings(
    Sys.which = function(x) setNames("/usr/bin/woff2_decompress", x),
    .package = "base"
  )
  # system2 returns status 0 but creates no TTF
  local_mocked_bindings(
    system2 = function(command, args, ...) invisible(0L),
    .package = "base"
  )

  expect_error(
    woff2_to_ttf(woff2, quiet = "full"),
    "output file not found"
  )
})

test_that("woff2_to_ttf shows success message when quiet is 'success' or 'none'", {
  tmp_dir <- withr::local_tempdir()
  woff2 <- file.path(tmp_dir, "font.woff2")
  ttf <- file.path(tmp_dir, "font.ttf")
  writeLines("fake woff2", woff2)

  local_mocked_bindings(
    Sys.which = function(x) setNames("/usr/bin/woff2_decompress", x),
    .package = "base"
  )
  local_mocked_bindings(
    system2 = function(command, args, ...) {
      writeLines("fake ttf", ttf)
      invisible(0L)
    },
    .package = "base"
  )

  expect_message(woff2_to_ttf(woff2, overwrite = TRUE, quiet = "success"), "Converted")
  writeLines("fake woff2", woff2)
  expect_message(woff2_to_ttf(woff2, overwrite = TRUE, quiet = "none"), "Converted")
})
