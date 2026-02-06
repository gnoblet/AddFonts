test_that("provider helpers return expected structure", {
  p <- get_provider_details("bunny")
  expect_true(is.list(p))
  expect_true(!is.null(p$source))
  expect_equal(provider_name(p), "bunny")
  nb <- new_bunny_provider()
  expect_true(is.list(nb))
  expect_equal(nb$source, "bunny")
})
