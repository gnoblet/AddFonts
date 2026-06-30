test_that("register_provider adds a provider to the session registry", {
  provider <- FontProviderWeight(
    source = "test_reg",
    url_template = "https://example.com/{family}-{weight}-{style}.ttf",
    conversion = NULL,
    conversion_ext = NULL,
    aliases = list()
  )

  register_provider(provider)
  on.exit(try(unregister_provider("test_reg"), silent = TRUE), add = TRUE)

  all <- list_providers()
  expect_true("test_reg" %in% names(all))
  expect_s7_class(all[["test_reg"]], FontProvider)
})

test_that("register_provider errors on duplicate source without overwrite", {
  provider <- FontProviderWeight(
    source = "test_dup",
    url_template = "https://example.com/{family}-{weight}-{style}.ttf",
    conversion = NULL,
    conversion_ext = NULL,
    aliases = list()
  )

  register_provider(provider)
  on.exit(try(unregister_provider("test_dup"), silent = TRUE), add = TRUE)

  expect_error(
    register_provider(provider),
    "already registered"
  )
})

test_that("register_provider overwrites when overwrite = TRUE", {
  provider <- FontProviderWeight(
    source = "test_ow",
    url_template = "https://example.com/{family}-{weight}-{style}.ttf",
    conversion = NULL,
    conversion_ext = NULL,
    aliases = list()
  )

  register_provider(provider)
  on.exit(try(unregister_provider("test_ow"), silent = TRUE), add = TRUE)

  provider2 <- FontProviderWeight(
    source = "test_ow",
    url_template = "https://other.com/{family}-{weight}-{style}.ttf",
    conversion = NULL,
    conversion_ext = NULL,
    aliases = list()
  )

  expect_no_error(register_provider(provider2, overwrite = TRUE))
  expect_equal(
    list_providers()[["test_ow"]]@url_template,
    "https://other.com/{family}-{weight}-{style}.ttf"
  )
})

test_that("unregister_provider removes the provider by name", {
  provider <- FontProviderWeight(
    source = "test_rm",
    url_template = "https://example.com/{family}-{weight}-{style}.ttf",
    conversion = NULL,
    conversion_ext = NULL,
    aliases = list()
  )

  register_provider(provider)
  unregister_provider("test_rm")

  expect_false("test_rm" %in% names(list_providers()))
})

test_that("unregister_provider removes the provider by FontProvider object", {
  provider <- FontProviderWeight(
    source = "test_rm_obj",
    url_template = "https://example.com/{family}-{weight}-{style}.ttf",
    conversion = NULL,
    conversion_ext = NULL,
    aliases = list()
  )

  register_provider(provider)
  unregister_provider(provider)

  expect_false("test_rm_obj" %in% names(list_providers()))
})

test_that("unregister_provider errors when provider not found", {
  expect_error(
    unregister_provider("does_not_exist_xyz"),
    "No user-registered provider"
  )
})

test_that("get_provider_details finds session-registered provider by source", {
  provider <- FontProviderWeight(
    source = "test_lookup",
    url_template = "https://example.com/{family}-{weight}-{style}.ttf",
    conversion = NULL,
    conversion_ext = NULL,
    aliases = list()
  )

  register_provider(provider)
  on.exit(try(unregister_provider("test_lookup"), silent = TRUE), add = TRUE)

  fp <- get_provider_details("test_lookup")
  expect_s7_class(fp, FontProvider)
  expect_equal(fp@source, "test_lookup")
})

test_that("get_provider_details finds session provider by alias", {
  provider <- FontProviderWeight(
    source = "test_alias_src",
    url_template = "https://example.com/{family}-{weight}-{style}.ttf",
    conversion = NULL,
    conversion_ext = NULL,
    aliases = list("my_alias")
  )

  register_provider(provider)
  on.exit(try(unregister_provider("test_alias_src"), silent = TRUE), add = TRUE)

  fp <- get_provider_details("my_alias")
  expect_equal(fp@source, "test_alias_src")
})

test_that("list_providers includes both built-in and session providers", {
  provider <- FontProviderWeight(
    source = "test_list",
    url_template = "https://example.com/{family}-{weight}-{style}.ttf",
    conversion = NULL,
    conversion_ext = NULL,
    aliases = list()
  )

  register_provider(provider)
  on.exit(try(unregister_provider("test_list"), silent = TRUE), add = TRUE)

  all <- list_providers()
  expect_true("bunny" %in% names(all))
  expect_true("test_list" %in% names(all))
})
