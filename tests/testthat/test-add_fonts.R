test_that("add_font parameter validation works", {
  expect_error(
    add_font(name = 123, provider = "bunny"),
    regexp = "non-empty string"
  )
  expect_error(
    add_font(name = "", provider = "bunny"),
    regexp = "non-empty string"
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
    regexp = "Provider"
  )
})

test_that("add_font passes additional arguments correctly", {
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
    wt = c(300, 400, 700),
    styles = "normal"
  )

  expect_equal(captured_args$name, "roboto")
  expect_equal(captured_args$family, "CustomRoboto")
  expect_equal(captured_args$wt, c(300, 400, 700))
  expect_equal(captured_args$styles, "normal")
})

test_that("add_font default provider is 'bunny'", {
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
