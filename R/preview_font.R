# ## Preview: preview_font
# #' Preview a font by ensuring it's installed and drawing a sample string
# #'
# #' Ensure the requested font is installed via `add_font()` and draw a brief
# #' sample using `showtext` (preferred) or base graphics as a fallback.
# #'
# #' @typed name: character(1)
# #'   Font name as used by the provider (e.g. "oswald").
# #' @typed provider: character(1)
# #'   Provider name to use (default: "bunny")
# #' @typed family: character | NULL
# #'   Optional family name to register the font under (default: NULL)
# #' @typed sample: character(1)
# #'   Sample text to display (default: "The quick brown fox jumps over the lazy dog")
# #' @typed size: numeric(1)
# #'   Font size in points for the preview (default: 28)
# #' @typed subset: character(1)
# #'   Glyph subset to request (default: "latin")
# #' @typed regular.wt: integer(1)
# #'   Regular weight to display (default: 400)
# #' @typed bold.wt: integer(1)
# #'   Bold weight to display (default: 700)
# #' @typedreturn list
# #'   Invisibly returns the list of paths produced by `add_font()`.
# #' @export
# preview_font <- function(
#   name,
#   provider = "bunny",
#   family = NULL,
#   sample = "The quick brown fox jumps over the lazy dog",
#   size = 28,
#   subset = "latin",
#   regular.wt = 400,
#   bold.wt = 700
# ) {
#   files <- add_font(
#     name,
#     provider = provider,
#     family = family,
#     regular.wt = regular.wt,
#     bold.wt = bold.wt,
#     subset = subset
#   )
#   family_name <- if (is.null(family)) name else family

#   # Prefer showtext for reliable rendering, but still use base graphics
#   if (requireNamespace("showtext", quietly = TRUE)) {
#     showtext::showtext_auto()
#   }

#   # Prepare 2x2 grid: columns = regular/bold weights, rows = normal/italic
#   old_par <- par(no.readonly = TRUE)
#   on.exit(par(old_par), add = TRUE)
#   par(mfrow = c(2, 2), mar = c(1, 1, 2, 1))

#   # Determine which variants were actually installed (files may be equal
#   # when italic/bold variants are missing and fell back to regular).
#   has_italic <- !is.null(files$italic) &&
#     !is.null(files$regular) &&
#     !identical(files$italic, files$regular)
#   has_bold <- !is.null(files$bold) &&
#     !is.null(files$regular) &&
#     !identical(files$bold, files$regular)
#   has_bolditalic <- !is.null(files$bolditalic) &&
#     !is.null(files$bold) &&
#     !identical(files$bolditalic, files$bold)

#   # Helper to draw one cell with wrapped text and a font face
#   draw_cell <- function(label, txt, fam, cex, font = 1) {
#     plot.new()
#     # Draw label inside the cell using text() (avoid title())
#     cex_main <- max(0.85, cex * 0.95)
#     label_y <- 0.92
#     text(
#       x = 0.5,
#       y = label_y,
#       labels = label,
#       family = fam,
#       cex = cex_main,
#       font = font
#     )

#     # Wrap text to a reasonable width depending on cex
#     wrap_width <- max(10, floor(40 / cex))
#     lines <- strwrap(txt, width = wrap_width)
#     n <- length(lines)
#     # vertical spacing scaled by cex
#     spacing <- 0.08 * max(1, cex)
#     start_y <- 0.5 + (n - 1) / 2 * spacing
#     ys <- start_y - (seq_len(n) - 1) * spacing
#     for (i in seq_along(lines)) {
#       text(
#         x = 0.5,
#         y = ys[i],
#         labels = lines[i],
#         family = fam,
#         cex = cex,
#         font = font
#       )
#     }
#   }

#   cex_val <- size / 14

#   # Line 1 1: regular weight
#   draw_cell(
#     paste0(regular.wt, " — Regular"),
#     sample,
#     family_name,
#     cex_val,
#     font = 1
#   )
#   if (has_italic) {
#     draw_cell(
#       paste0(regular.wt, " — Italic"),
#       sample,
#       family_name,
#       cex_val,
#       font = 3
#     )
#   } else {
#     draw_cell(
#       paste0(regular.wt, " — Italic"),
#       paste(sample, "(none)"),
#       family_name,
#       cex_val,
#       font = 1
#     )
#   }

#   # Line 2: bold weight
#   if (has_bold) {
#     draw_cell(
#       paste0(bold.wt, " — Regular"),
#       sample,
#       family_name,
#       cex_val,
#       font = 2
#     )
#   } else {
#     draw_cell(
#       paste0(bold.wt, " — Regular"),
#       paste(sample, "(none)"),
#       family_name,
#       cex_val,
#       font = 1
#     )
#   }
#   if (has_bolditalic) {
#     draw_cell(
#       paste0(bold.wt, " — Italic"),
#       sample,
#       family_name,
#       cex_val,
#       font = 4
#     )
#   } else if (has_bold) {
#     draw_cell(
#       paste0(bold.wt, " — Italic"),
#       paste(sample, "(none)"),
#       family_name,
#       cex_val,
#       font = 2
#     )
#   } else {
#     draw_cell(
#       paste0(bold.wt, " — Italic"),
#       paste(sample, "(none)"),
#       family_name,
#       cex_val,
#       font = 1
#     )
#   }

#   invisible(files)
# }
