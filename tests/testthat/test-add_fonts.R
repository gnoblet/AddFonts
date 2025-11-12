test_that("add_font parameter validation works", {
  expect_error(
    add_font(name = 123, provider = "bunny"),
    regexp = "string"
  )
  expect_error(
    add_font(name = "", provider = "bunny"),
    regexp = "at least 1 characters"
  )
  expect_error(
    add_font(name = "roboto", provider = ""),
    regexp = "Provider .* not supported"
  )
  expect_error(
    add_font(name = "roboto", provider = 123),
    regexp = "Provider .* not supported|string"
  )
})

test_that("add_font with provider='bunny' calls add_font_bunny", {
  skip_on_cran()

  add_font_bunny_called <- FALSE
  captured_args <- NULL

  local_mocked_bindings(
    add_font_bunny = function(...) {
      add_font_bunny_called <<- TRUE
      captured_args <<- list(...)
      return(invisible(list(regular = "mock_path")))
    }
  )

  result <- add_font(name = "roboto", provider = "bunny")

  expect_true(add_font_bunny_called)
  expect_equal(captured_args$name, "roboto")
})

test_that("add_font with invalid provider fails", {
  expect_error(
    add_font(name = "roboto", provider = "nonexistent"),
    regexp = "provider"
  )
})

test_that("add_font passes additional arguments correctly", {
  skip_on_cran()

  captured_args <- NULL

  local_mocked_bindings(
    add_font_bunny = function(...) {
      captured_args <<- list(...)
      return(invisible(list(regular = "mock_path")))
    }
  )

  add_font(
    name = "roboto",
    provider = "bunny",
    family = "CustomRoboto",
    regular.wt = 300
  )

  expect_equal(captured_args$name, "roboto")
  expect_equal(captured_args$family, "CustomRoboto")
  expect_equal(captured_args$regular.wt, 300)
})

test_that("add_font S3 dispatch works correctly", {
  skip_on_cran()

  # Mock add_font_bunny
  local_mocked_bindings(
    add_font_bunny = function(...) {
      return(invisible(list(regular = "mock_path")))
    }
  )

  # Create object with class for dispatch
  obj <- structure(
    list(
      provider = "bunny",
      name = "roboto",
      family = NULL,
      regular.wt = 400,
      bold.wt = 700,
      italic = TRUE,
      subset = NULL,
      cache_dir = NULL
    ),
    class = "font_provider_bunny"
  )

  result <- add_font_dispatch(obj)
  expect_type(result, "list")
})

test_that("add_font default provider is 'bunny'", {
  skip_on_cran()

  add_font_bunny_called <- FALSE

  local_mocked_bindings(
    add_font_bunny = function(...) {
      add_font_bunny_called <<- TRUE
      return(invisible(list(regular = "mock_path")))
    }
  )

  add_font(name = "roboto")

  expect_true(add_font_bunny_called)
})
