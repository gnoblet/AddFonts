## Helper: resolve a conversion specification to a function
#'
#' Resolve a conversion name to the converter function used by the
#' package (currently only `woff2_to_ttf`).
#'
#' @typed conversion: character(1)
#'   Name of the conversion to resolve.
#' @typedreturn function
#'   The conversion function if known; otherwise the helper aborts.
conv_fun <- function(conversion) {
  #------ Arg check

  # conversion is a character string of length 1
  assert_null_or_non_empty_string(conversion, allow_null = FALSE)

  #------ Do stuff

  switch(
    conversion,
    "woff2_to_ttf" = woff2_to_ttf,
    cli::cli_abort(
      "Unknown conversion '{conversion}'; expected 'woff2_to_ttf'."
    )
  )
}
