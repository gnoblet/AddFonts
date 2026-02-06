test_that("conv_fun resolves known conversions and errors on unknown", {
  expect_identical(conv_fun("woff2_to_ttf"), woff2_to_ttf)
  expect_error(conv_fun("nope"), "Unknown conversion")
})

test_that("conv_fun errors for invalid arguments", {
  expect_error(conv_fun(NULL), "must be a non-empty character string")
  expect_error(conv_fun(123), "must be a non-empty character string")
  expect_error(conv_fun(character(0)), "must be a non-empty character string")
  expect_error(conv_fun(""), "must be a non-empty character string")
})
