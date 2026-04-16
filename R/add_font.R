#' Add a font to the local cache and register it for use
#'
#' Ensure a font is available locally: try the cache first, otherwise
#' download/convert and register the font so it can be used by plotting
#' devices. Returns (invisibly) the list of local file paths.
#'
#' For weight-based providers (e.g. Bunny Fonts), supply `regular.wt`,
#' `bold.wt`, and `subset`. For file-based providers (e.g. Bye Bye Binary),
#' supply `variants` instead.
#'
#' @typed name: character(1)
#'   Name of the font as known to the provider.
#' @typed provider: character(1) | FontProvider
#'   Provider id/name (default: `"bunny"`), or a `FontProvider` object
#'   constructed with [FontProviderWeight()] or [FontProviderFile()]
#'   (bypasses the registry lookup).
#' @typed family: character | NULL
#'   Optional family name to register the font under (default: NULL).
#' @typed variants: list | NULL
#'   For file-based providers only. Named list mapping symbolic variant keys
#'   (`"regular"`, `"italic"`, `"bold"`, `"bolditalic"`) to filename stems
#'   served by the provider (without extension). Must include at least
#'   `"regular"`. Ignored for weight-based providers (default: NULL).
#' @typed regular.wt: numeric(1)
#'   For weight-based providers. Regular weight to request (default: 400).
#' @typed bold.wt: numeric(1)
#'   For weight-based providers. Bold weight to request (default: 700).
#' @typed subset: character(1)
#'   For weight-based providers. Glyph subset to request (default: "latin").
#'
#' @typedreturn list
#'   Invisibly returns a list with paths for `regular`, `italic`, `bold` and
#'   `bolditalic` variants, or throws an error on failure.
#'
#' @export
add_font <- function(
  name,
  provider = "bunny",
  family = NULL,
  variants = NULL,
  regular.wt = 400,
  bold.wt = 700,
  subset = "latin"
) {
  #------ Arg check
  assert_null_or_non_empty_string(name, allow_null = FALSE)
  if (!S7::S7_inherits(provider, FontProvider)) {
    assert_null_or_non_empty_string(provider, allow_null = FALSE)
  }
  assert_null_or_non_empty_string(family, allow_null = TRUE)

  #------ Prepare identifiers and provider
  provider_obj <- if (S7::S7_inherits(provider, FontProvider)) {
    provider
  } else {
    get_provider_details(provider)
  }
  family_name <- if (is.null(family)) name else family
  cache_dir <- get_cache_dir()

  maybe_show_first_use(provider_obj)

  #------ Route by provider type
  if (S7::S7_inherits(provider_obj, FontProviderFile)) {
    .add_font_file(
      provider_obj = provider_obj,
      name         = name,
      family_name  = family_name,
      variants     = variants,
      cache_dir    = cache_dir
    )
  } else {
    .add_font_weight(
      provider_obj = provider_obj,
      name         = name,
      family_name  = family_name,
      regular.wt   = regular.wt,
      bold.wt      = bold.wt,
      subset       = subset,
      cache_dir    = cache_dir
    )
  }
}

# Internal: weight-based provider path
.add_font_weight <- function(
  provider_obj,
  name,
  family_name,
  regular.wt,
  bold.wt,
  subset,
  cache_dir
) {
  if (!is.numeric(regular.wt) || length(regular.wt) != 1) {
    cli::cli_abort("{.arg regular.wt} must be a single numeric weight.")
  }
  if (!is.numeric(bold.wt) || length(bold.wt) != 1) {
    cli::cli_abort("{.arg bold.wt} must be a single numeric weight.")
  }
  assert_null_or_non_empty_string(subset, allow_null = FALSE)

  cel <- cache_read_safe(cache_dir = cache_dir)
  existing_entry <- NULL
  if (length(cel@entries) > 0) {
    got <- cache_get(cel, families = family_name, source = provider_obj@source, quiet = TRUE)
    if (!is.null(got) && length(got) >= 1) existing_entry <- got[[1]]
  }

  if (!is.null(existing_entry)) {
    weight_check <- cache_get_weights(existing_entry, c(regular.wt, bold.wt))
    has_regular <- weight_check[1]
    has_bold    <- weight_check[2]

    if (has_regular && has_bold) {
      files <- register_from_cache(existing_entry, regular.wt = regular.wt, bold.wt = bold.wt)
      if (!is.null(files)) {
        cli::cli_alert_success("Font {.val {family_name}} registered from cache.")
        return(invisible(files))
      }
      cli::cli_warn("Stale cache entry for {.val {family_name}} - re-downloading.")
      cel <- cache_remove(cel, families = family_name, source = provider_obj@source,
                          remove_files = FALSE, cache_dir = cache_dir)
      cache_write(cel, cache_dir = cache_dir, quiet = TRUE)
    } else if (has_regular && !has_bold) {
      cli::cli_inform(
        "Cached {.val {family_name}} has regular weight {.val {regular.wt}}. Downloading missing bold weight {.val {bold.wt}}."
      )
      updated_entry <- update_download_and_cache(
        entry = existing_entry, provider = provider_obj, name = name,
        family_name = family_name, missing_weights = bold.wt,
        subset = subset, cache_dir = cache_dir, cel = cel
      )
      if (!is.null(updated_entry)) {
        files <- register_from_cache(updated_entry, regular.wt = regular.wt, bold.wt = bold.wt)
        if (!is.null(files)) {
          cli::cli_alert_success("Font {.val {family_name}} registered with updated weights from cache.")
          return(invisible(files))
        }
      }
      cli::cli_warn("Failed to download missing weight or register - re-downloading all weights.")
      cel <- cache_remove(cel, families = family_name, source = provider_obj@source,
                          remove_files = FALSE, cache_dir = cache_dir)
      cache_write(cel, cache_dir = cache_dir, quiet = TRUE)
    } else {
      cli::cli_inform(
        "Cached {.val {family_name}} is missing requested regular weight {.val {regular.wt}} - re-downloading."
      )
      cel <- cache_remove(cel, families = family_name, source = provider_obj@source,
                          remove_files = FALSE, cache_dir = cache_dir)
      cache_write(cel, cache_dir = cache_dir, quiet = TRUE)
    }
  }

  cache_entry <- download_and_cache(
    provider = provider_obj, name = name, family_name = family_name,
    regular.wt = regular.wt, bold.wt = bold.wt, subset = subset, cache_dir = cache_dir
  )
  if (is.null(cache_entry)) {
    cli::cli_abort("Failed to obtain font {.val {name}} from provider {.val {provider_obj@source}}.")
  }

  files <- register_from_cache(cache_entry, regular.wt = regular.wt, bold.wt = bold.wt)
  if (!is.null(files)) {
    cli::cli_alert_success("Font {.val {family_name}} registered and added to cache.")
  }
  invisible(files)
}

# Internal: file-based provider path
.add_font_file <- function(
  provider_obj,
  name,
  family_name,
  variants,
  cache_dir
) {
  # variants validation
  valid_variants <- c("regular", "italic", "bold", "bolditalic")
  if (is.null(variants) || !is.list(variants) || is.null(names(variants))) {
    cli::cli_abort(
      "{.arg variants} must be a named list for file-based providers.",
      "i" = "Supply e.g. {.code list(regular = \"Font-Regular\", bold = \"Font-Bold\")}."
    )
  }
  bad <- setdiff(names(variants), valid_variants)
  if (length(bad) > 0) {
    cli::cli_abort("Unknown variant name{?s} in {.arg variants}: {.val {bad}}.")
  }
  if (!"regular" %in% names(variants)) {
    cli::cli_abort("{.arg variants} must include a {.val regular} entry.")
  }

  # Check cache
  cel <- cache_read_safe(cache_dir = cache_dir)
  existing_entry <- NULL
  if (length(cel@entries) > 0) {
    got <- cache_get(cel, families = family_name, source = provider_obj@source, quiet = TRUE)
    if (!is.null(got) && length(got) >= 1) existing_entry <- got[[1]]
  }

  if (!is.null(existing_entry)) {
    variant_check <- cache_get_variants(existing_entry, "regular")
    if (isTRUE(variant_check[["regular"]])) {
      files <- register_from_cache(existing_entry)
      if (!is.null(files)) {
        cli::cli_alert_success("Font {.val {family_name}} registered from cache.")
        return(invisible(files))
      }
      # Stale — re-download
      cli::cli_warn("Stale cache entry for {.val {family_name}} - re-downloading.")
      cel <- cache_remove(cel, families = family_name, source = provider_obj@source,
                          remove_files = FALSE, cache_dir = cache_dir)
      cache_write(cel, cache_dir = cache_dir, quiet = TRUE)
    }
  }

  cache_entry <- download_and_cache_file(
    provider    = provider_obj,
    name        = name,
    family_name = family_name,
    variants    = variants,
    cache_dir   = cache_dir
  )
  if (is.null(cache_entry)) {
    cli::cli_abort("Failed to obtain font {.val {name}} from provider {.val {provider_obj@source}}.")
  }

  files <- register_from_cache(cache_entry)
  if (!is.null(files)) {
    cli::cli_alert_success("Font {.val {family_name}} registered and added to cache.")
  }
  invisible(files)
}
