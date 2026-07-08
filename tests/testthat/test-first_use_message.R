## ---- maybe_show_first_use ----

test_that("maybe_show_first_use shows message on first call for a source", {
  tmp_dir <- withr::local_tempdir()
  # Reset the tracking env for this source key
  source_key <- "test_fum_source_a"
  rm(
    list = intersect(source_key, ls(.first_use_shown)),
    envir = .first_use_shown
  )

  fp <- FontProviderWeight(
    source = source_key,
    url_template = "https://example.com/{family}.ttf",
    first_use_message = "Hello, first use!",
    first_use_url = "https://example.com/licence"
  )

  expect_message(
    maybe_show_first_use(fp),
    "Hello, first use!"
  )
})

test_that("maybe_show_first_use only shows message once per session", {
  source_key <- "test_fum_source_b"
  rm(
    list = intersect(source_key, ls(.first_use_shown)),
    envir = .first_use_shown
  )

  fp <- FontProviderWeight(
    source = source_key,
    url_template = "https://example.com/{family}.ttf",
    first_use_message = "Only once!"
  )

  expect_message(maybe_show_first_use(fp), "Only once!")
  # Second call: no message
  expect_no_message(maybe_show_first_use(fp))
})

test_that("maybe_show_first_use is silent when first_use_message is NULL", {
  fp <- FontProviderWeight(
    source = "test_fum_source_c",
    url_template = "https://example.com/{family}.ttf"
  )

  expect_no_message(maybe_show_first_use(fp))
})

test_that("maybe_show_first_use includes URL when first_use_url is set", {
  source_key <- "test_fum_source_d"
  rm(
    list = intersect(source_key, ls(.first_use_shown)),
    envir = .first_use_shown
  )

  fp <- FontProviderWeight(
    source = source_key,
    url_template = "https://example.com/{family}.ttf",
    first_use_message = "Check the licence.",
    first_use_url = "https://example.com/licence"
  )

  msgs <- capture_messages(maybe_show_first_use(fp))
  combined <- paste(msgs, collapse = "")
  expect_match(combined, "Check the licence.")
  expect_match(combined, "https://example.com/licence")
})

test_that("maybe_show_first_use works for FontProviderFile too", {
  source_key <- "test_fum_source_e"
  rm(
    list = intersect(source_key, ls(.first_use_shown)),
    envir = .first_use_shown
  )

  fp <- FontProviderFile(
    source = source_key,
    base_url = "https://example.com/{family}/{filename}.ttf",
    first_use_message = "BBB notice."
  )

  expect_message(maybe_show_first_use(fp), "BBB notice.")
})
