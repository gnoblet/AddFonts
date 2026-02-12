test_that("register_from_cache validates arguments", {
    fn <- getFromNamespace("register_from_cache", "AddFonts")

    # Invalid entry
    expect_error(
        fn(
            entry = "not an entry",
            regular.wt = 400,
            bold.wt = 700
        ),
        "must be a <CacheEntry> object"
    )

    # Invalid regular.wt
    meta <- CacheMeta(
        family_id = "test",
        source = "bunny",
        files = list("400" = "/tmp/test-400.ttf")
    )
    entry <- CacheEntry(family = "Test", meta = meta)

    expect_error(
        fn(entry = entry, regular.wt = "not numeric", bold.wt = 700),
        "must be a single numeric weight"
    )

    expect_error(
        fn(entry = entry, regular.wt = c(400, 500), bold.wt = 700),
        "must be a single numeric weight"
    )

    # Invalid bold.wt
    expect_error(
        fn(entry = entry, regular.wt = 400, bold.wt = "not numeric"),
        "must be a single numeric weight"
    )
})


test_that("register_from_cache returns NULL when regular file missing", {
    fn <- getFromNamespace("register_from_cache", "AddFonts")

    # Entry with only weight 700
    meta <- CacheMeta(
        family_id = "test",
        source = "bunny",
        files = list("700" = "/tmp/test-700.ttf")
    )
    entry <- CacheEntry(family = "Test", meta = meta)

    result <- fn(entry = entry, regular.wt = 400, bold.wt = 700)
    expect_null(result)
})

test_that("register_from_cache returns NULL when regular file does not exist", {
    fn <- getFromNamespace("register_from_cache", "AddFonts")

    # Entry with non-existent file
    meta <- CacheMeta(
        family_id = "test",
        source = "bunny",
        files = list("400" = "/tmp/nonexistent-test-400.ttf")
    )
    entry <- CacheEntry(family = "Test", meta = meta)

    result <- fn(entry = entry, regular.wt = 400, bold.wt = 700)
    expect_null(result)
})

test_that("register_from_cache registers with sysfonts and applies fallbacks", {
    fn <- getFromNamespace("register_from_cache", "AddFonts")

    # Create temporary files
    tmp_dir <- tempfile("fonts_")
    dir.create(tmp_dir)
    on.exit(unlink(tmp_dir, recursive = TRUE), add = TRUE)

    regular_file <- fs::path(tmp_dir, "test-400.ttf")
    fs::file_create(regular_file)

    meta <- CacheMeta(
        family_id = "test",
        source = "bunny",
        files = list("400" = as.character(regular_file))
    )
    entry <- CacheEntry(family = "test", meta = meta)

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

    result <- fn(entry = entry, regular.wt = 400, bold.wt = 700)

    # Should return files list
    expect_type(result, "list")
    expect_named(result, c("regular", "italic", "bold", "bolditalic"))

    # All variants should fall back to regular
    expect_equal(result$regular, as.character(regular_file))
    expect_equal(result$italic, as.character(regular_file))
    expect_equal(result$bold, as.character(regular_file))
    expect_equal(result$bolditalic, as.character(regular_file))

    # Verify sysfonts::font_add was called correctly
    expect_equal(font_add_calls$family, "test")
    expect_equal(font_add_calls$regular, as.character(regular_file))
})

test_that("register_from_cache uses available variants when present", {
    fn <- getFromNamespace("register_from_cache", "AddFonts")

    # Create temporary files
    tmp_dir <- tempfile("fonts_")
    dir.create(tmp_dir)
    on.exit(unlink(tmp_dir, recursive = TRUE), add = TRUE)

    regular_file <- fs::path(tmp_dir, "test-400.ttf")
    italic_file <- fs::path(tmp_dir, "test-400italic.ttf")
    bold_file <- fs::path(tmp_dir, "test-700.ttf")
    bolditalic_file <- fs::path(tmp_dir, "test-700italic.ttf")

    fs::file_create(c(regular_file, italic_file, bold_file, bolditalic_file))

    meta <- CacheMeta(
        family_id = "test",
        source = "bunny",
        files = list(
            "400" = as.character(regular_file),
            "400italic" = as.character(italic_file),
            "700" = as.character(bold_file),
            "700italic" = as.character(bolditalic_file)
        )
    )
    entry <- CacheEntry(family = "test", meta = meta)

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

    result <- fn(entry = entry, regular.wt = 400, bold.wt = 700)

    # Should use all specific variants
    expect_equal(result$regular, as.character(regular_file))
    expect_equal(result$italic, as.character(italic_file))
    expect_equal(result$bold, as.character(bold_file))
    expect_equal(result$bolditalic, as.character(bolditalic_file))

    # Verify sysfonts::font_add received correct paths
    expect_equal(font_add_calls$regular, as.character(regular_file))
    expect_equal(font_add_calls$italic, as.character(italic_file))
    expect_equal(font_add_calls$bold, as.character(bold_file))
    expect_equal(font_add_calls$bolditalic, as.character(bolditalic_file))
})

test_that("register_from_cache applies partial fallbacks correctly", {
    fn <- getFromNamespace("register_from_cache", "AddFonts")

    # Create temporary files
    tmp_dir <- tempfile("fonts_")
    dir.create(tmp_dir)
    on.exit(unlink(tmp_dir, recursive = TRUE), add = TRUE)

    regular_file <- fs::path(tmp_dir, "test-400.ttf")
    bold_file <- fs::path(tmp_dir, "test-700.ttf")

    fs::file_create(c(regular_file, bold_file))

    meta <- CacheMeta(
        family_id = "test",
        source = "bunny",
        files = list(
            "400" = as.character(regular_file),
            "700" = as.character(bold_file)
        )
    )
    entry <- CacheEntry(family = "test", meta = meta)

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

    result <- fn(entry = entry, regular.wt = 400, bold.wt = 700)

    # italic should fall back to regular
    expect_equal(result$italic, as.character(regular_file))

    # bolditalic should fall back to bold (preferred over italic/regular)
    expect_equal(result$bolditalic, as.character(bold_file))
})

test_that("register_from_cache works with non-standard weights", {
    fn <- getFromNamespace("register_from_cache", "AddFonts")

    # Create temporary files
    tmp_dir <- tempfile("fonts_")
    dir.create(tmp_dir)
    on.exit(unlink(tmp_dir, recursive = TRUE), add = TRUE)

    light_file <- fs::path(tmp_dir, "test-300.ttf")
    black_file <- fs::path(tmp_dir, "test-900.ttf")

    fs::file_create(c(light_file, black_file))

    meta <- CacheMeta(
        family_id = "test",
        source = "bunny",
        files = list(
            "300" = as.character(light_file),
            "900" = as.character(black_file)
        )
    )
    entry <- CacheEntry(family = "test", meta = meta)

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

    # Request weight 300 as regular and 900 as bold
    result <- fn(entry = entry, regular.wt = 300, bold.wt = 900)

    expect_equal(result$regular, as.character(light_file))
    expect_equal(result$bold, as.character(black_file))
    expect_equal(font_add_calls$regular, as.character(light_file))
    expect_equal(font_add_calls$bold, as.character(black_file))
})
