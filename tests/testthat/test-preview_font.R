test_that("preview_font runs without error when add_font is mocked", {
  tmpf <- fs::file_temp(ext = "ttf")
  writeLines("x", tmpf)
  # Mock `add_font` in AddFonts, `showtext::showtext_auto`, and graphics text
  with_mocked_bindings(
    add_font = function(...) {
      list(regular = tmpf, italic = tmpf, bold = tmpf, bolditalic = tmpf)
    },
    .package = "AddFonts",
    {
      with_mocked_bindings(
        showtext_auto = function(...) TRUE,
        .package = "showtext",
        {
          with_mocked_bindings(
            text = function(...) NULL,
            plot.new = function(...) NULL,
            .package = "graphics",
            {
              expect_silent(preview_font(
                "somefont",
                provider = "bunny",
                family = "somefont",
                size = 6
              ))
            }
          )
        }
      )
    }
  )
  if (fs::file_exists(tmpf)) fs::file_delete(tmpf)
})
