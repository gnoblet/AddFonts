mock_add_font_showtext <- function(fake_files, .env = parent.frame()) {
  local_mocked_bindings(
    add_font = function(...) fake_files,
    .package = "AddFonts",
    .env = .env
  )
  local_mocked_bindings(
    showtext_auto = function(...) invisible(NULL),
    .package = "showtext",
    .env = .env
  )
}

# Use "sans" as name so family_name resolves to a PostScript-safe font
preview_into_pdf <- function(name = "sans", family = NULL, ...) {
  pdf(nullfile())
  on.exit(dev.off(), add = TRUE)
  preview_font(name, family = family, ...)
}

test_that("preview_font returns files invisibly when all variants are distinct", {
  # has_italic=TRUE, has_bold=TRUE, has_bolditalic=TRUE
  fake_files <- list(
    regular = "r.ttf",
    italic = "i.ttf",
    bold = "b.ttf",
    bolditalic = "bi.ttf"
  )
  mock_add_font_showtext(fake_files)

  result <- preview_into_pdf()
  expect_equal(result, fake_files)
})

test_that("preview_font draws italic fallback when italic file matches regular", {
  # has_italic=FALSE: italic cell drawn with font=1 and "(fallback)" label
  fake_files <- list(
    regular = "r.ttf",
    italic = "r.ttf",
    bold = "b.ttf",
    bolditalic = "bi.ttf"
  )
  mock_add_font_showtext(fake_files)

  expect_no_error(preview_into_pdf())
})

test_that("preview_font draws all fallbacks when bold matches regular", {
  # has_bold=FALSE: bold cell drawn with font=1
  # has_bolditalic=FALSE (bolditalic==bold==regular): else branch with font=1
  fake_files <- list(
    regular = "r.ttf",
    italic = "i.ttf",
    bold = "r.ttf",
    bolditalic = "r.ttf"
  )
  mock_add_font_showtext(fake_files)

  expect_no_error(preview_into_pdf())
})

test_that("preview_font draws bolditalic as bold fallback when bolditalic matches bold", {
  # has_bolditalic=FALSE, has_bold=TRUE: bolditalic cell drawn with font=2
  fake_files <- list(
    regular = "r.ttf",
    italic = "i.ttf",
    bold = "b.ttf",
    bolditalic = "b.ttf"
  )
  mock_add_font_showtext(fake_files)

  expect_no_error(preview_into_pdf())
})

test_that("preview_font passes family and name to add_font", {
  fake_files <- list(
    regular = "r.ttf",
    italic = "r.ttf",
    bold = "r.ttf",
    bolditalic = "r.ttf"
  )

  captured <- list()
  local_mocked_bindings(
    add_font = function(name, family = NULL, ...) {
      captured <<- list(name = name, family = family)
      fake_files
    },
    .package = "AddFonts"
  )
  local_mocked_bindings(
    showtext_auto = function(...) invisible(NULL),
    .package = "showtext"
  )

  # Use family = "sans" so the draw step uses a safe PostScript font
  preview_into_pdf(name = "myfont", family = "sans")
  expect_equal(captured$name, "myfont")
  expect_equal(captured$family, "sans")
})
