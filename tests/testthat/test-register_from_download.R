# Note: register_from_download appears to be deprecated in favor of
# download_and_cache + register_from_cache workflow. These tests are
# provided for completeness but the function may not be actively used.

test_that("register_from_download validates provider argument", {
    fn <- getFromNamespace("register_from_download", "AddFonts")

    expect_error(
        fn(
            provider = "not a provider",
            name = "test-font",
            font_id = "test-font",
            family_name = "test",
            regular.wt = 400,
            bold.wt = 700,
            subset = "latin",
            cache_dir = tempdir()
        ),
        "must be a <FontProvider> object"
    )
})

test_that("register_from_download returns NULL when regular weight unavailable", {
    fn <- getFromNamespace("register_from_download", "AddFonts")
    provider <- new_bunny_provider()

    tmp <- tempfile("cache_")
    dir.create(tmp)
    on.exit(unlink(tmp, recursive = TRUE), add = TRUE)

    # Mock download_variant_generic to return NULL for regular
    local_mocked_bindings(
        download_variant_generic = function(
            provider,
            name,
            weight,
            style,
            subset,
            cache_dir,
            quiet
        ) {
            return(NULL)
        }
    )

    result <- fn(
        provider = provider,
        name = "test-font",
        font_id = "test-font",
        family_name = "test",
        regular.wt = 400,
        bold.wt = 700,
        subset = "latin",
        cache_dir = tmp
    )

    expect_null(result)
})

test_that("register_from_download downloads, caches, and registers font", {
    fn <- getFromNamespace("register_from_download", "AddFonts")
    provider <- new_bunny_provider()

    tmp <- tempfile("cache_")
    dir.create(tmp)
    on.exit(unlink(tmp, recursive = TRUE), add = TRUE)

    # Create temporary font files
    regular_file <- fs::path(tmp, "test-400-normal.ttf")
    italic_file <- fs::path(tmp, "test-400-italic.ttf")
    bold_file <- fs::path(tmp, "test-700-normal.ttf")
    bolditalic_file <- fs::path(tmp, "test-700-italic.ttf")

    fs::file_create(c(regular_file, italic_file, bold_file, bolditalic_file))

    # Mock download_variant_generic to return paths
    local_mocked_bindings(
        download_variant_generic = function(
            provider,
            name,
            weight,
            style,
            subset,
            cache_dir,
            quiet
        ) {
            if (weight == 400 && style == "normal") {
                return(as.character(regular_file))
            }
            if (weight == 400 && style == "italic") {
                return(as.character(italic_file))
            }
            if (weight == 700 && style == "normal") {
                return(as.character(bold_file))
            }
            if (weight == 700 && style == "italic") {
                return(as.character(bolditalic_file))
            }
            return(NULL)
        }
    )

    # Mock sysfonts::font_add
    font_add_calls <- list()
    local_mocked_bindings(
        font_add = function(family, regular, italic, bold, bolditalic) {
            font_add_calls <<- list(
                family = family,
                regular = regular,
                italic = italic,
                bold = bold,
                bolditalic = bolditalic
            )
            invisible(NULL)
        },
        .package = "sysfonts"
    )

    # Suppress success message
    suppressMessages({
        result <- fn(
            provider = provider,
            name = "test-font",
            font_id = "test-font-id",
            family_name = "test",
            regular.wt = 400,
            bold.wt = 700,
            subset = "latin",
            cache_dir = tmp
        )
    })

    # Should return files list
    expect_type(result, "list")
    expect_named(result, c("regular", "italic", "bold", "bolditalic"))

    # Verify cache was written
    expect_true(fs::file_exists(fs::path(tmp, "fonts_db.json")))

    # Verify cache contents
    cel <- cache_read(tmp)
    entries <- cache_get(cel, families = "test", quiet = TRUE)
    expect_equal(length(entries), 1)
    expect_equal(entries[[1]]@family, "test")
    expect_equal(entries[[1]]@meta@family_id, "test-font-id")

    # Verify sysfonts::font_add was called
    expect_equal(font_add_calls$family, "test")
    expect_equal(font_add_calls$regular, as.character(regular_file))
})

test_that("register_from_download handles partial variant availability", {
    fn <- getFromNamespace("register_from_download", "AddFonts")
    provider <- new_bunny_provider()

    tmp <- tempfile("cache_")
    dir.create(tmp)
    on.exit(unlink(tmp, recursive = TRUE), add = TRUE)

    # Create only regular file
    regular_file <- fs::path(tmp, "test-400-normal.ttf")
    fs::file_create(regular_file)

    # Mock download_variant_generic to return only regular
    local_mocked_bindings(
        download_variant_generic = function(
            provider,
            name,
            weight,
            style,
            subset,
            cache_dir,
            quiet
        ) {
            if (weight == 400 && style == "normal") {
                return(as.character(regular_file))
            }
            return(NULL)
        }
    )

    # Mock sysfonts::font_add
    font_add_calls <- list()
    local_mocked_bindings(
        font_add = function(family, regular, italic, bold, bolditalic) {
            font_add_calls <<- list(
                family = family,
                regular = regular,
                italic = italic,
                bold = bold,
                bolditalic = bolditalic
            )
            invisible(NULL)
        },
        .package = "sysfonts"
    )

    # Suppress success message
    suppressMessages({
        result <- fn(
            provider = provider,
            name = "test-font",
            font_id = "test-font-id",
            family_name = "test",
            regular.wt = 400,
            bold.wt = 700,
            subset = "latin",
            cache_dir = tmp
        )
    })

    # Should return files with fallbacks
    expect_type(result, "list")

    # All variants should fall back to regular
    expect_equal(result$regular, as.character(regular_file))
    expect_equal(result$italic, as.character(regular_file))
    expect_equal(result$bold, as.character(regular_file))
    expect_equal(result$bolditalic, as.character(regular_file))
})
