test_that("add_font uses cache when available (mocked)", {
  fake_files <- list(
    regular = "a.ttf",
    italic = "b.ttf",
    bold = "c.ttf",
    bolditalic = "d.ttf"
  )

  # Create a mock CacheEntry with matching weights (400 and 700)
  fake_entry <- CacheEntry(
    family = "somefont",
    meta = CacheMeta(
      source = "bunny",
      family_id = "somefont",
      files = list(
        "400" = "a.ttf",
        "400italic" = "b.ttf",
        "700" = "c.ttf",
        "700italic" = "d.ttf"
      )
    )
  )

  # Create a mock CacheEntryList with our entry
  fake_cache <- CacheEntryList(entries = list(fake_entry))

  with_mocked_bindings(
    cache_read = function(...) fake_cache,
    register_from_cache = function(entry, ...) fake_files,
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


test_that("add_font re-downloads when weights don't match cached weights", {
  fake_files_old <- list(
    regular = "a.ttf",
    italic = "b.ttf",
    bold = "c.ttf",
    bolditalic = "d.ttf"
  )

  fake_files_new <- list(
    regular = "e.ttf",
    italic = "f.ttf",
    bold = "g.ttf",
    bolditalic = "h.ttf"
  )

  # Create a mock CacheEntry with different weights (300/900 != requested 400/700)
  fake_entry <- CacheEntry(
    family = "somefont",
    meta = CacheMeta(
      source = "bunny",
      family_id = "somefont",
      files = list(
        "300" = "a.ttf",
        "300italic" = "b.ttf",
        "900" = "c.ttf",
        "900italic" = "d.ttf"
      )
    )
  )

  # Create a mock CacheEntryList with our entry
  fake_cache <- CacheEntryList(entries = list(fake_entry))

  # Track if download_and_cache was called (it should be)
  download_called <- FALSE

  # Create a fake new cache entry for download_and_cache to return
  fake_new_entry <- CacheEntry(
    family = "somefont",
    meta = CacheMeta(
      source = "bunny",
      family_id = "somefont",
      files = list(
        "400" = "e.ttf",
        "400italic" = "f.ttf",
        "700" = "g.ttf",
        "700italic" = "h.ttf"
      )
    )
  )

  with_mocked_bindings(
    cache_read = function(...) fake_cache,
    cache_remove = function(cel, ...) cel,
    cache_write = function(...) NULL,
    download_and_cache = function(...) {
      download_called <<- TRUE
      fake_new_entry
    },
    register_from_cache = function(entry, ...) {
      if (download_called) fake_files_new else fake_files_old
    },
    .package = "AddFonts",
    {
      res <- add_font(
        "somefont",
        provider = "bunny",
        family = "somefont",
        regular.wt = 400,
        bold.wt = 700
      )
      expect_true(download_called)
      expect_true(!is.null(res))
      expect_equal(res, fake_files_new)
    }
  )
})

test_that("add_font re-downloads when cached weights are missing", {
  fake_files_old <- list(
    regular = "a.ttf",
    italic = "b.ttf",
    bold = "c.ttf",
    bolditalic = "d.ttf"
  )

  fake_files_new <- list(
    regular = "e.ttf",
    italic = "f.ttf",
    bold = "g.ttf",
    bolditalic = "h.ttf"
  )

  # Create a mock CacheEntry with only weight 500 (missing requested 400/700)
  fake_entry <- CacheEntry(
    family = "somefont",
    meta = CacheMeta(
      source = "bunny",
      family_id = "somefont",
      files = list(
        "500" = "a.ttf",
        "500italic" = "b.ttf"
      )
    )
  )

  # Create a mock CacheEntryList with our entry
  fake_cache <- CacheEntryList(entries = list(fake_entry))

  # Track if download_and_cache was called (it should be)
  download_called <- FALSE

  # Create a fake new cache entry for download_and_cache to return
  fake_new_entry <- CacheEntry(
    family = "somefont",
    meta = CacheMeta(
      source = "bunny",
      family_id = "somefont",
      files = list(
        "400" = "e.ttf",
        "400italic" = "f.ttf",
        "700" = "g.ttf",
        "700italic" = "h.ttf"
      )
    )
  )

  with_mocked_bindings(
    cache_read = function(...) fake_cache,
    cache_remove = function(cel, ...) cel,
    cache_write = function(...) NULL,
    download_and_cache = function(...) {
      download_called <<- TRUE
      fake_new_entry
    },
    register_from_cache = function(entry, ...) {
      if (download_called) fake_files_new else fake_files_old
    },
    .package = "AddFonts",
    {
      res <- add_font(
        "somefont",
        provider = "bunny",
        family = "somefont",
        regular.wt = 400,
        bold.wt = 700
      )
      expect_true(download_called)
      expect_true(!is.null(res))
      expect_equal(res, fake_files_new)
    }
  )
})
