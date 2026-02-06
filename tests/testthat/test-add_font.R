test_that("add_font uses cache when available (mocked)", {
  fake_files <- list(
    regular = "a.ttf",
    italic = "b.ttf",
    bold = "c.ttf",
    bolditalic = "d.ttf"
  )

  # Create a mock CacheEntry
  fake_entry <- CacheEntry(
    family = "somefont",
    meta = CacheMeta(
      source = "bunny",
      family_id = "somefont",
      files = fake_files
    )
  )

  # Create a mock CacheEntryList with our entry
  fake_cache <- CacheEntryList(entries = list(fake_entry))

  with_mocked_bindings(
    cache_read = function(...) fake_cache,
    register_from_cache = function(entry) fake_files,
    .package = "AddFonts",
    {
      res <- add_font(
        "somefont",
        provider = "bunny",
        family = "somefont"
      )
      expect_true(!is.null(res))
      expect_equal(res, fake_files)
    }
  )
})
