test_that("add_font uses registry when available (mocked)", {
  fake_files <- list(
    regular = "a.ttf",
    italic = "b.ttf",
    bold = "c.ttf",
    bolditalic = "d.ttf"
  )
  with_mocked_bindings(
    get_provider_details = function(provider) new_bunny_provider(),
    cache_get = function(family, family_id, cache_dir) {
      list(files = fake_files)
    },
    register_from_cache = function(existing, family_name) fake_files,
    .package = "AddFonts",
    {
      res <- AddFonts:::add_font(
        "somefont",
        provider = "bunny",
        family = "somefont"
      )
      expect_true(!is.null(res))
    }
  )
})
