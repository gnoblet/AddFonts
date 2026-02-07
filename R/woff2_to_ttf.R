#' Convert a .woff2 font to .ttf using the system 'woff2_decompress' tool
#'
#' Internal helper. Uses the system `woff2_decompress` tool to convert a
#' `.woff2` file into a `.ttf` file. Documented with roxytypes annotations
#' for clarity.
#'
#' @typed font_file: character(1)
#'   Path to the `.woff2` file to convert.
#' @typed overwrite: logical(1)
#'   If `TRUE`, overwrite an existing `.ttf` conversion.
#' @typed remove_old: logical(1)
#'   If `TRUE`, remove the original `.woff2` file after conversion try.
#' @typed quiet: "full" | "success" | "fail" | "none"
#'   If "full", capture all output and suppress console messages; if "success",
#'   only show success messages; if "fail", only show error messages; if "none",
#'   show all messages (default: "none").
#'
#' @typedreturn character(1)
#'   Invisibly returns the path to the `.ttf` file on success.
#'
woff2_to_ttf <- function(
  font_file,
  overwrite = FALSE,
  remove_old = TRUE,
  quiet = "fail"
) {
  #------ Arg check

  # font_file is a non-empty string
  assert_null_or_non_empty_string(font_file, allow_null = FALSE)

  # overwrite is a logical of length 1
  if (!is.logical(overwrite) || length(overwrite) != 1) {
    cli::cli_abort("{.arg overwrite} must be a logical value of length 1.")
  }

  # font_file exists and is a .woff2 file
  if (!fs::file_exists(font_file)) {
    cli::cli_abort("Font file not found: {.file {font_file}}")
  }
  if (tolower(fs::path_ext(font_file)) != "woff2") {
    cli::cli_abort("Expected a .woff2 file but got: {.file {font_file}}")
  }

  # quiet is one of allowed values
  assert_string_in_set(quiet, choices = c("full", "success", "fail", "none"))

  # locate woff2_decompress command
  woff2_cmd <- Sys.which("woff2_decompress")

  # abort if command not found
  if (!nzchar(woff2_cmd)) {
    cli::cli_abort(c(
      "System tool {.val woff2_decompress} not found.",
      "i" = "Install the tool and ensure it's on your PATH.",
      "i" = "On Debian/Ubuntu: {.code sudo apt install woff2}",
      "i" = "On Fedora/RHEL: {.code sudo dnf install woff2-tools}",
      "i" = "On Arch Linux: {.code sudo pacman -S woff2}",
      "i" = "On macOS (Homebrew): {.code brew install woff2}",
      "i" = "Or build from: https://github.com/google/woff2"
    ))
  }

  # ------ Do stuff

  # output .ttf path while checking for existing file
  out <- fs::path_ext_set(font_file, "ttf")
  if (fs::file_exists(out) && !isTRUE(overwrite)) {
    cli::cli_alert_info("Using existing ttf file: {.file {out}}")
    return(invisible(out))
  }

  # run conversion
  res <- system2(woff2_cmd, args = font_file, stdout = TRUE, stderr = TRUE)

  # check result
  status <- attr(res, "status")

  # clean out source file if requested (successful or not)
  if (isTRUE(remove_old) && fs::file_exists(font_file)) {
    try(fs::file_delete(font_file), silent = TRUE)
  }

  # abort if errored status
  if (quiet %in% c("fail", "full") && !is.null(status) && status != 0) {
    cli::cli_abort(c(
      "Error during conversion of {.file {font_file}} to TTF using {.val woff2_decompress}.",
      "x" = paste(res, collapse = "\n")
    ))
  }

  # abort if no error status but output missing
  if (quiet %in% c("fail", "full") && !fs::file_exists(out)) {
    cli::cli_abort(
      "Conversion finished but output file not found: {.file {out}}"
    )
  }

  # success alert
  if (quiet %in% c("success", "full")) {
    cli::cli_alert_success(
      "Converted {.file {font_file}} to TTF: {.file {out}}"
    )
  }

  invisible(out)
}
