test_that("download_weights validates provider argument", {
  expect_error(
    download_weights(
      provider = "not a provider",
      name = "test-font",
      weights = c(400),
      subset = "latin",
      cache_dir = withr::local_tempdir(),
      quiet = TRUE
    ),
    "must be a <FontProvider> object"
  )
})

test_that("download_weights validates name argument", {
  provider <- new_bunny_provider()

  expect_error(
    download_weights(
      provider = provider,
      name = "",
      weights = c(400),
      subset = "latin",
      cache_dir = withr::local_tempdir(),
      quiet = TRUE
    ),
    "must be"
  )
})

test_that("download_weights validates weights argument", {
  provider <- new_bunny_provider()

  expect_error(
    download_weights(
      provider = provider,
      name = "test-font",
      weights = numeric(0),
      subset = "latin",
      cache_dir = withr::local_tempdir(),
      quiet = TRUE
    ),
    "must be a non-empty numeric vector"
  )

  expect_error(
    download_weights(
      provider = provider,
      name = "test-font",
      weights = "not numeric",
      subset = "latin",
      cache_dir = withr::local_tempdir(),
      quiet = TRUE
    ),
    "must be a non-empty numeric vector"
  )
})

test_that("download_weights validates quiet argument", {
  provider <- new_bunny_provider()

  expect_error(
    download_weights(
      provider = provider,
      name = "test-font",
      weights = c(400),
      subset = "latin",
      cache_dir = withr::local_tempdir(),
      quiet = "not logical"
    ),
    "must be a logical scalar"
  )
})

test_that("download_weights returns a named list with weight keys", {
  provider <- new_bunny_provider()

  # Mock download_variant_generic to avoid real downloads
  local_mocked_bindings(
    download_variant_generic = function(
      provider,
      name,
      weight,
      style,
      subset,
      cache_dir,
      quiet
    ) {
      # Return a fake path for normal variants only
      if (style == "normal") {
        return(paste0("/tmp/fake-", weight, "-", style, ".ttf"))
      }
      return(NULL)
    }
  )

  result <- download_weights(
    provider = provider,
    name = "test-font",
    weights = c(400, 700),
    subset = "latin",
    cache_dir = tempdir(),
    quiet = TRUE
  )

  expect_type(result, "list")
  expect_named(result)

  # Should have weight keys
  expect_true("400" %in% names(result))
  expect_true("700" %in% names(result))
})

test_that("download_weights includes italic variants when available", {
  provider <- new_bunny_provider()

  # Mock to return both normal and italic
  local_mocked_bindings(
    download_variant_generic = function(
      provider,
      name,
      weight,
      style,
      subset,
      cache_dir,
      quiet
    ) {
      return(paste0("/tmp/fake-", weight, "-", style, ".ttf"))
    }
  )

  result <- download_weights(
    provider = provider,
    name = "test-font",
    weights = c(400),
    subset = "latin",
    cache_dir = tempdir(),
    quiet = TRUE
  )

  # Should have both normal and italic
  expect_true("400" %in% names(result))
  expect_true("400italic" %in% names(result))
})

test_that("download_weights skips unavailable variants", {
  provider <- new_bunny_provider()

  # Mock to return NULL (unavailable)
  local_mocked_bindings(
    download_variant_generic = function(
      provider,
      name,
      weight,
      style,
      subset,
      cache_dir,
      quiet
    ) {
      return(NULL)
    }
  )

  result <- download_weights(
    provider = provider,
    name = "test-font",
    weights = c(400, 700),
    subset = "latin",
    cache_dir = tempdir(),
    quiet = TRUE
  )

  # Should return an empty list if nothing downloaded
  expect_type(result, "list")
  expect_length(result, 0)
})

test_that("download_weights handles multiple weights correctly", {
  provider <- new_bunny_provider()

  # Track which weights were requested
  tracker <- new.env(parent = emptyenv())
  tracker$requested_weights <- c()
  local_mocked_bindings(
    download_variant_generic = function(
      provider,
      name,
      weight,
      style,
      subset,
      cache_dir,
      quiet
    ) {
      tracker$requested_weights <- c(tracker$requested_weights, weight)
      if (style == "normal") {
        return(paste0("/tmp/fake-", weight, ".ttf"))
      }
      return(NULL)
    }
  )

  result <- download_weights(
    provider = provider,
    name = "test-font",
    weights = c(300, 400, 700),
    subset = "latin",
    cache_dir = withr::local_tempdir(),
    quiet = TRUE
  )

  # Should have tried all three weights
  expect_true(all(c(300, 400, 700) %in% tracker$requested_weights))

  # Should have all three in result (normal variants)
  expect_true("300" %in% names(result))
  expect_true("400" %in% names(result))
  expect_true("700" %in% names(result))
})
