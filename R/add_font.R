#' Add a font to the local cache and register it for use
#'
#' Ensure a font is available locally: try the cache first, otherwise download/convert and register the font so it can be used by plotting devices. Returns (invisibly) the list of local file paths.
#'
#' For weight-based providers (e.g. Bunny Fonts), supply `regular.wt`,`bold.wt`, and `subset`. For file-based providers (e.g. Bye Bye Binary), supply `variants` instead.
#'
#' @typed name: character(1)
#'   Name of the font as known to the provider.
#' @typed provider: character(1) | FontProvider
#'   Provider id/name (default: `"bunny"`), or a `FontProvider` object constructed with `FontProviderWeight()` or `FontProviderFile()` (bypasses the registry lookup).
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
  } else if (identical(provider, "file")) {
    FontProviderLocal()
  } else if (identical(provider, "url")) {
    FontProviderDirectURL()
  } else {
    get_provider_details(provider)
  }
  family_name <- if (is.null(family)) name else family
  cache_dir <- get_cache_dir()

  maybe_show_first_use(provider_obj)

  #------ Route by provider type (pure S7 dispatch)
  if (S7::S7_inherits(provider_obj, FontProviderLocal)) {
    return(.add_font_local(name, family_name, variants, cache_dir))
  }
  if (S7::S7_inherits(provider_obj, FontProviderDirectURL)) {
    return(.add_font_direct_url(name, family_name, variants, cache_dir))
  }
  if (S7::S7_inherits(provider_obj, FontProviderFile)) {
    .add_font_file(
      provider_obj = provider_obj,
      name = name,
      family_name = family_name,
      variants = variants,
      cache_dir = cache_dir
    )
  } else {
    .add_font_weight(
      provider_obj = provider_obj,
      name = name,
      family_name = family_name,
      regular.wt = regular.wt,
      bold.wt = bold.wt,
      subset = subset,
      cache_dir = cache_dir
    )
  }
}

#' Route add_font() for a weight-based provider
#'
#' Handles the full cache-check → optional partial update-download-register cycle for `FontProviderWeight` providers.
#'
#' @typed provider_obj: FontProviderWeight
#'   Weight-based provider object.
#' @typed name: character(1)
#'   Font name at the provider.
#' @typed family_name: character(1)
#'   Family name to register the font under.
#' @typed regular.wt: numeric(1)
#'   Regular weight to request.
#' @typed bold.wt: numeric(1)
#'   Bold weight to request.
#' @typed subset: character(1)
#'   Glyph subset to request.
#' @typed cache_dir: character(1)
#'   Cache directory path.
#'
#' @typedreturn list
#'   Invisibly, a named list of local file paths for all registered variants.
#'
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

  res <- .cache_lookup(cache_dir, family_name, provider_obj@source)
  cel <- res$cel
  existing_entry <- res$entry

  if (!is.null(existing_entry)) {
    weight_check <- cache_get_weights(existing_entry, c(regular.wt, bold.wt))
    has_regular <- weight_check[1]
    has_bold <- weight_check[2]

    if (has_regular && has_bold) {
      files <- register_from_cache(
        existing_entry,
        regular.wt = regular.wt,
        bold.wt = bold.wt
      )
      if (!is.null(files)) {
        cli::cli_alert_success(
          "Font {.val {family_name}} registered from cache."
        )
        return(invisible(files))
      }
      cli::cli_warn(
        "Stale cache entry for {.val {family_name}} - re-downloading."
      )
      cel <- cache_remove(
        cel,
        families = family_name,
        source = provider_obj@source,
        remove_files = FALSE,
        cache_dir = cache_dir
      )
      cache_write(cel, cache_dir = cache_dir, quiet = TRUE)
    } else if (has_regular && !has_bold) {
      cli::cli_inform(
        "Cached {.val {family_name}} has regular weight {.val {regular.wt}}. Downloading missing bold weight {.val {bold.wt}}."
      )
      updated_entry <- update_download_and_cache(
        entry = existing_entry,
        provider = provider_obj,
        name = name,
        family_name = family_name,
        missing_weights = bold.wt,
        subset = subset,
        cache_dir = cache_dir,
        cel = cel
      )
      if (!is.null(updated_entry)) {
        files <- register_from_cache(
          updated_entry,
          regular.wt = regular.wt,
          bold.wt = bold.wt
        )
        if (!is.null(files)) {
          cli::cli_alert_success(
            "Font {.val {family_name}} registered with updated weights from cache."
          )
          return(invisible(files))
        }
      }
      cli::cli_warn(
        "Failed to download missing weight or register - re-downloading all weights."
      )
      cel <- cache_remove(
        cel,
        families = family_name,
        source = provider_obj@source,
        remove_files = FALSE,
        cache_dir = cache_dir
      )
      cache_write(cel, cache_dir = cache_dir, quiet = TRUE)
    } else {
      cli::cli_inform(
        "Cached {.val {family_name}} is missing requested regular weight {.val {regular.wt}} - re-downloading."
      )
      cel <- cache_remove(
        cel,
        families = family_name,
        source = provider_obj@source,
        remove_files = FALSE,
        cache_dir = cache_dir
      )
      cache_write(cel, cache_dir = cache_dir, quiet = TRUE)
    }
  }

  cache_entry <- download_and_cache(
    provider = provider_obj,
    name = name,
    family_name = family_name,
    regular.wt = regular.wt,
    bold.wt = bold.wt,
    subset = subset,
    cache_dir = cache_dir
  )
  if (is.null(cache_entry)) {
    cli::cli_abort(
      "Failed to obtain font {.val {name}} from provider {.val {provider_obj@source}}."
    )
  }

  files <- register_from_cache(
    cache_entry,
    regular.wt = regular.wt,
    bold.wt = bold.wt
  )
  if (!is.null(files)) {
    cli::cli_alert_success(
      "Font {.val {family_name}} registered and added to cache."
    )
  }
  invisible(files)
}

#' Route add_font() for a file-based provider
#'
#' Handles the cache-check → download → register cycle for `FontProviderFile` providers using symbolic variant keys.
#'
#' @typed provider_obj: FontProviderFile
#'   File-based provider object.
#' @typed name: character(1)
#'   Font name at the provider (used as `{family}` in the URL template).
#' @typed family_name: character(1)
#'   Family name to register the font under.
#' @typed variants: list
#'   Named list mapping symbolic variant keys to filename stems.
#' @typed cache_dir: character(1)
#'   Cache directory path.
#'
#' @typedreturn list
#'   Invisibly, a named list of local file paths for all registered variants.
#'
.add_font_file <- function(
  provider_obj,
  name,
  family_name,
  variants,
  cache_dir
) {
  .validate_variants(variants)

  res <- .cache_lookup(cache_dir, family_name, provider_obj@source)
  cel <- res$cel
  existing_entry <- res$entry

  if (!is.null(existing_entry)) {
    variant_check <- cache_get_variants(existing_entry, "regular")
    if (isTRUE(variant_check[["regular"]])) {
      files <- register_from_cache(existing_entry)
      if (!is.null(files)) {
        cli::cli_alert_success(
          "Font {.val {family_name}} registered from cache."
        )
        return(invisible(files))
      }
      cli::cli_warn(
        "Stale cache entry for {.val {family_name}} - re-downloading."
      )
      cel <- cache_remove(
        cel,
        families = family_name,
        source = provider_obj@source,
        remove_files = FALSE,
        cache_dir = cache_dir
      )
      cache_write(cel, cache_dir = cache_dir, quiet = TRUE)
    }
  }

  cache_entry <- download_and_cache_file(
    provider = provider_obj,
    name = name,
    family_name = family_name,
    variants = variants,
    cache_dir = cache_dir
  )
  if (is.null(cache_entry)) {
    cli::cli_abort(
      "Failed to obtain font {.val {name}} from provider {.val {provider_obj@source}}."
    )
  }

  files <- register_from_cache(cache_entry)
  if (!is.null(files)) {
    cli::cli_alert_success(
      "Font {.val {family_name}} registered and added to cache."
    )
  }
  invisible(files)
}

#' Route add_font() for provider = "file" (local copies)
#'
#' Handles the cache-check → copy → register cycle when the user supplies `provider = "file"`. Uses source key `"file"` in the cache index.
#'
#' @typed name: character(1)
#'   Font name (used as the family component of cache filenames).
#' @typed family_name: character(1)
#'   Family name to register the font under.
#' @typed variants: list
#'   Named list mapping symbolic variant keys to absolute local file paths.
#' @typed cache_dir: character(1)
#'   Cache directory path.
#'
#' @typedreturn list
#'   Invisibly, a named list of local file paths for all registered variants.
#'
.add_font_local <- function(name, family_name, variants, cache_dir) {
  .validate_variants(variants)

  res <- .cache_lookup(cache_dir, family_name, "file")
  cel <- res$cel
  existing_entry <- res$entry

  if (!is.null(existing_entry)) {
    variant_check <- cache_get_variants(existing_entry, "regular")
    if (isTRUE(variant_check[["regular"]])) {
      files <- register_from_cache(existing_entry)
      if (!is.null(files)) {
        cli::cli_alert_success(
          "Font {.val {family_name}} registered from cache."
        )
        return(invisible(files))
      }
      cli::cli_warn("Stale cache entry for {.val {family_name}} - re-copying.")
      cel <- cache_remove(
        cel,
        families = family_name,
        source = "file",
        remove_files = FALSE,
        cache_dir = cache_dir
      )
      cache_write(cel, cache_dir = cache_dir, quiet = TRUE)
    }
  }

  cache_entry <- copy_and_cache_local(
    name = name,
    family_name = family_name,
    variants = variants,
    cache_dir = cache_dir
  )
  if (is.null(cache_entry)) {
    cli::cli_abort("Failed to copy font {.val {name}} to cache.")
  }

  files <- register_from_cache(cache_entry)
  if (!is.null(files)) {
    cli::cli_alert_success(
      "Font {.val {family_name}} registered and added to cache."
    )
  }
  invisible(files)
}

#' Route add_font() for provider = "url" (direct download)
#'
#' Handles the cache-check → download → register cycle when the user supplies `provider = "url"`. Uses source key `"url"` in the cache index.
#'
#' @typed name: character(1)
#'   Font name (used as the family component of cache filenames).
#' @typed family_name: character(1)
#'   Family name to register the font under.
#' @typed variants: list
#'   Named list mapping symbolic variant keys to full download URLs.
#' @typed cache_dir: character(1)
#'   Cache directory path.
#'
#' @typedreturn list
#'   Invisibly, a named list of local file paths for all registered variants.
#'
.add_font_direct_url <- function(name, family_name, variants, cache_dir) {
  .validate_variants(variants)

  res <- .cache_lookup(cache_dir, family_name, "url")
  cel <- res$cel
  existing_entry <- res$entry

  if (!is.null(existing_entry)) {
    variant_check <- cache_get_variants(existing_entry, "regular")
    if (isTRUE(variant_check[["regular"]])) {
      files <- register_from_cache(existing_entry)
      if (!is.null(files)) {
        cli::cli_alert_success(
          "Font {.val {family_name}} registered from cache."
        )
        return(invisible(files))
      }
      cli::cli_warn(
        "Stale cache entry for {.val {family_name}} - re-downloading."
      )
      cel <- cache_remove(
        cel,
        families = family_name,
        source = "url",
        remove_files = FALSE,
        cache_dir = cache_dir
      )
      cache_write(cel, cache_dir = cache_dir, quiet = TRUE)
    }
  }

  cache_entry <- download_and_cache_url(
    name = name,
    family_name = family_name,
    variants = variants,
    cache_dir = cache_dir
  )
  if (is.null(cache_entry)) {
    cli::cli_abort("Failed to download font {.val {name}} from URL.")
  }

  files <- register_from_cache(cache_entry)
  if (!is.null(files)) {
    cli::cli_alert_success(
      "Font {.val {family_name}} registered and added to cache."
    )
  }
  invisible(files)
}
