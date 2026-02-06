test_that("add_font_bunny forwards to add_font", {
  called <- FALSE
  with_mocked_bindings(
    add_font = function(name, provider, ...) {
      called <<- TRUE
      list(regular = "r")
    },
    .package = "AddFonts",
    {
      res <- AddFonts:::add_font_bunny("name")
      expect_true(called)
      expect_true(!is.null(res))
    }
  )
})
