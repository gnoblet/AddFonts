test_that("download_and_cache validates provider argument", {
    fn <- getFromNamespace("download_and_cache", "AddFonts")

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

test_that("download_and_cache returns NULL when regular weight unavailable", {
    fn <- getFromNamespace("download_and_cache", "AddFonts")
    provider <- new_bunny_provider()

    tmp <- tempfile("cache_")
    dir.create(tmp)
    on.exit(unlink(tmp, recursive = TRUE), add = TRUE)

    # Mock download_weights to return empty list (no regular weight)
    local_mocked_bindings(
        download_weights = function(...) {
            list()
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

test_that("download_and_cache creates CacheEntry and writes to cache", {
    fn <- getFromNamespace("download_and_cache", "AddFonts")
    provider <- new_bunny_provider()

    tmp <- tempfile("cache_")
    dir.create(tmp)
    on.exit(unlink(tmp, recursive = TRUE), add = TRUE)

    # Mock download_weights to return files
    local_mocked_bindings(
        download_weights = function(...) {
            list(
                "400" = "/tmp/test-400.ttf",
                "400italic" = "/tmp/test-400italic.ttf",
                "700" = "/tmp/test-700.ttf",
                "700italic" = "/tmp/test-700italic.ttf"
            )
        }
    )

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

    # Should return a CacheEntry
    expect_s7_class(result, CacheEntry)
    expect_equal(result@family, "test")
    expect_equal(result@meta@family_id, "test-font-id")
    expect_equal(result@meta@source, "bunny")
    expect_equal(length(result@meta@files), 4)

    # Should write to cache
    expect_true(fs::file_exists(fs::path(tmp, "fonts_db.json")))

    # Verify cache contents
    cel <- cache_read(tmp)
    entries <- cache_get(cel, families = "test", quiet = TRUE)
    expect_equal(length(entries), 1)
    expect_equal(entries[[1]]@family, "test")
})

test_that("download_and_cache handles partial weight downloads", {
    fn <- getFromNamespace("download_and_cache", "AddFonts")
    provider <- new_bunny_provider()

    tmp <- tempfile("cache_")
    dir.create(tmp)
    on.exit(unlink(tmp, recursive = TRUE), add = TRUE)

    # Mock download_weights to return only regular weight
    local_mocked_bindings(
        download_weights = function(...) {
            list(
                "400" = "/tmp/test-400.ttf"
            )
        }
    )

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

    # Should succeed even with only regular weight
    expect_s7_class(result, CacheEntry)
    expect_equal(length(result@meta@files), 1)
    expect_true("400" %in% names(result@meta@files))
})

test_that("download_and_cache uses default cache_dir when NULL", {
    fn <- getFromNamespace("download_and_cache", "AddFonts")
    provider <- new_bunny_provider()

    # Mock get_cache_dir and download_weights
    mock_cache_dir <- tempfile("mock_cache_")
    dir.create(mock_cache_dir)
    on.exit(unlink(mock_cache_dir, recursive = TRUE), add = TRUE)

    local_mocked_bindings(
        get_cache_dir = function() mock_cache_dir,
        download_weights = function(...) {
            list("400" = "/tmp/test-400.ttf")
        }
    )

    result <- fn(
        provider = provider,
        name = "test-font",
        font_id = "test-font-id",
        family_name = "test",
        regular.wt = 400,
        bold.wt = 700,
        subset = "latin",
        cache_dir = NULL
    )

    # Should use mocked cache dir
    expect_true(fs::file_exists(fs::path(mock_cache_dir, "fonts_db.json")))
})
