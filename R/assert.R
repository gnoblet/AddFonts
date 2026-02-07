# Assert a value is NULL (optionally) or a non-empty character string
assert_null_or_non_empty_string <- function(x, allow_null = TRUE) {
  arg_name <- rlang::as_label(rlang::enexpr(x))

  if (!allow_null && is.null(x)) {
    cli::cli_abort(
      "{arg_name} must be a non-empty character string; NULL is not allowed."
    )
  }

  if (allow_null && is.null(x)) {
    return(invisible(TRUE))
  }

  if (
    !is.null(x) &&
      (!is.character(x) || length(x) != 1 || is.na(x) || !nzchar(x))
  ) {
    info_msg <- if (is.null(x)) {
      glue::glue("{arg_name} is NULL.")
    } else {
      glue::glue(
        "{arg_name} is of type '{typeof(x)}' with length {length(x)} and number of characters {nchar(x)}."
      )
    }

    cli::cli_abort(c(
      "{arg_name} must be {if (allow_null) 'NULL or ' else ''}a non-empty character string.",
      "i" = info_msg
    ))
  }

  invisible(TRUE)
}

# Assert a value is NULL (optionally) or a non-empty character vector
assert_null_or_non_empty_character_vector <- function(x, allow_null = TRUE) {
  arg_name <- rlang::as_label(rlang::enexpr(x))

  if (!allow_null && is.null(x)) {
    cli::cli_abort(
      "{arg_name} must be a non-empty character vector; NULL is not allowed."
    )
  }
  if (
    !is.null(x) &&
      (!is.character(x) || length(x) == 0 || all(is.na(x)) || !all(nzchar(x)))
  ) {
    info_msg <- if (is.null(x)) {
      glue::glue("{arg_name} is NULL.")
    } else {
      glue::glue(
        "{arg_name} is of type '{typeof(x)}' with length {length(x)} and number of characters {paste0(nchar(x), collapse = ', ')}."
      )
    }
    cli::cli_abort(c(
      "{arg_name} must be {if (allow_null) 'NULL or ' else ''}a non-empty character vector.",
      "i" = info_msg
    ))
  }

  invisible(TRUE)
}

# Assert a value is a list, optionally with required elements (with types and lengths if specified)
assert_list_with_elements <- function(
  x,
  required_elements = NULL
) {
  arg_name <- rlang::as_label(rlang::enexpr(x))

  if (!is.list(x)) {
    cli::cli_abort("{arg_name} must be a list.")
  }
  if (!is.null(required_elements)) {
    missing_elements <- setdiff(required_elements, names(x))
    if (length(missing_elements) > 0) {
      cli::cli_abort(
        "{arg_name} is missing required elements:
          {glue::glue_collapse(missing_elements, sep = ', ')}."
      )
    }
  }

  invisible(TRUE)
}

# Assert a value is a list of 1-length character strings
assert_list_of_1_length_character_strings <- function(x, allow_empty = TRUE) {
  arg_name <- rlang::as_label(rlang::enexpr(x))

  if (!is.list(x)) {
    cli::cli_abort("{arg_name} must be a list.")
  }
  # if not empty list check for 1-length character strings
  if (allow_empty && length(x) == 0) {
    return(invisible(TRUE))
  }

  for (i in seq_along(x)) {
    if (
      !is.character(x[[i]]) ||
        length(x[[i]]) != 1 ||
        is.na(x[[i]]) ||
        !nzchar(x[[i]])
    ) {
      cli::cli_abort(c(
        "{arg_name}[{i}] must be a non-empty character string.",
        "i" = "{arg_name}[{i}] is of type '{typeof(x[[i]])}' with length {length(x[[i]])} and number of characters {nchar(x[[i]])}."
      ))
    }
  }

  invisible(TRUE)
}

# Assert a string is in a set of allowed choices
assert_string_in_set <- function(x, choices) {
  arg_name <- rlang::as_label(rlang::enexpr(x))

  # x is a non-empty string
  assert_null_or_non_empty_string(x, allow_null = FALSE)

  # x is in choices
  if (!x %in% choices) {
    cli::cli_abort(
      "{arg_name} must be one of: {glue::glue_collapse(choices, sep = ', ')}; got '{x}'."
    )
  }
  invisible(TRUE)
}


# Assert that a path is a valid font file path with given extension
assert_pattern_with_ext <- function(
  x,
  ext = NULL,
  allow_lowercase = TRUE,
  allow_uppercase = TRUE,
  allow_digits = TRUE,
  allow_dot = TRUE,
  allow_underscore = TRUE,
  allow_hyphen = TRUE,
  allow_forward_slash = TRUE,
  allow_backslash = TRUE,
  allow_colon = TRUE,
  allow_tilde = TRUE
) {
  arg_name <- rlang::as_label(rlang::enexpr(x))

  # basic input checks
  assert_null_or_non_empty_string(x, allow_null = FALSE)

  # validate flag types
  flags <- list(
    allow_lowercase = allow_lowercase,
    allow_uppercase = allow_uppercase,
    allow_digits = allow_digits,
    allow_dot = allow_dot,
    allow_underscore = allow_underscore,
    allow_hyphen = allow_hyphen,
    allow_forward_slash = allow_forward_slash,
    allow_backslash = allow_backslash,
    allow_colon = allow_colon,
    allow_tilde = allow_tilde
  )
  if (
    !all(vapply(flags, function(z) is.logical(z) && length(z) == 1, logical(1)))
  ) {
    cli::cli_abort(
      "All `allow_*` arguments must be single logical (TRUE / FALSE) values."
    )
  }

  # whitespace not allowed at all
  if (grepl("\\s", x)) {
    cli::cli_abort(
      "{arg_name} must not contain whitespace characters."
    )
  }

  # build character-class components based on flags
  comps <- character()
  if (allow_lowercase) {
    comps <- c(comps, "a-z")
  }
  if (allow_uppercase) {
    comps <- c(comps, "A-Z")
  }
  if (allow_digits) {
    comps <- c(comps, "0-9")
  }
  if (allow_dot) {
    comps <- c(comps, "\\.")
  } # dot in class must be escaped
  if (allow_underscore) {
    comps <- c(comps, "_")
  }
  # place hyphen at the end of the class to avoid being treated as a range
  if (allow_forward_slash) {
    comps <- c(comps, "/")
  }
  if (allow_backslash) {
    comps <- c(comps, "\\\\")
  } # needs double escape in R string
  if (allow_colon) {
    comps <- c(comps, ":")
  }
  if (allow_tilde) {
    comps <- c(comps, "~")
  }
  if (allow_hyphen) {
    comps <- c(comps, "-")
  }

  if (length(comps) == 0) {
    cli::cli_abort("At least one `allow_*` must be TRUE.")
  }

  # assemble safe regex: only characters from the chosen set allowed (one or more)
  safe_class <- paste0("[", paste0(comps, collapse = ""), "]+")
  safe_pattern <- paste0("^", safe_class, "$")

  if (!grepl(safe_pattern, x, perl = TRUE)) {
    # human-readable allowed set for the error message
    human_parts <- c()
    if (allow_lowercase) {
      human_parts <- c(human_parts, "lower-case letters a-z")
    }
    if (allow_uppercase) {
      human_parts <- c(human_parts, "upper-case letters A-Z")
    }
    if (allow_digits) {
      human_parts <- c(human_parts, "digits 0-9")
    }
    if (allow_dot) {
      human_parts <- c(human_parts, "dot (.)")
    }
    if (allow_underscore) {
      human_parts <- c(human_parts, "underscore (_)")
    }
    if (allow_hyphen) {
      human_parts <- c(human_parts, "hyphen (-)")
    }
    if (allow_forward_slash) {
      human_parts <- c(human_parts, "forward slash (/)")
    }
    if (allow_backslash) {
      human_parts <- c(human_parts, "backslash (\\\\)")
    }
    if (allow_colon) {
      human_parts <- c(human_parts, "colon (:)")
    }
    if (allow_tilde) {
      human_parts <- c(human_parts, "tilde (~)")
    }

    cli::cli_abort(
      "{arg_name} contains invalid characters. Only these are allowed: {glue::glue_collapse(human_parts, sep = ', ')}."
    )
  }
  # validate extension on last path component (case-insensitive)
  if (is.null(ext)) {
    pattern <- paste0("(?i)(?:^|[\\\\/])[^\\\\/]+$")
    if (!grepl(pattern, x, perl = TRUE)) {
      cli::cli_abort(
        c(
          "{arg_name} must be formatted as a valid path.",
          "i" = "A valid example: 'fonts/roboto-regular'."
        )
      )
    }
  } else {
    pattern <- paste0("(?i)(?:^|[\\\\/])[^\\\\/]+\\", ext, "$")
    if (!grepl(pattern, x, perl = TRUE)) {
      cli::cli_abort(
        c(
          "{arg_name} must be formatted as a path whose extension is '{ext}'."
        ),
        "i" = "A valid example: 'fonts/roboto-regular{ext}'."
      )
    }
  }

  invisible(TRUE)
}
