test_that("as_FontProvider constructs a FontProvider and validates fields", {
  x <- list(
    source = "bunny",
    url_template = "https://fonts.bunny.net/%s/files/%s-%s-%d-%s.woff2",
    conversion = "woff2_to_ttf",
    conversion_ext = "woff2",
    aliases = list("fonts.bunny.net")
  )

  fp <- as_FontProvider(x)
  expect_s7_class(fp, FontProvider)
  expect_equal(fp@source, "bunny")
  expect_equal(fp@conversion, "woff2_to_ttf")
  expect_equal(fp@conversion_ext, "woff2")
})

test_that("load_providers_db and providers_file return expected data", {
  f <- providers_file()
  expect_true(file.exists(f))

  db <- load_providers_db()
  expect_type(db, "list")
  expect_true(!is.null(db$bunny))
})

test_that("get_provider_details resolves bunny and aliases", {
  p <- get_provider_details("bunny")
  expect_s7_class(p, FontProvider)
  expect_equal(provider_name(p), "bunny")

  p2 <- get_provider_details("fonts.bunny.net")
  expect_s7_class(p2, FontProvider)
  expect_equal(p2@source, "bunny")
})

test_that("get_provider_details errors on unknown provider", {
  expect_error(get_provider_details("no-such-provider"))
})
