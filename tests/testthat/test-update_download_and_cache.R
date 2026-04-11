test_that("update_download_and_cache validates arguments", {
    provider <- new_bunny_provider()

    meta <- CacheMeta(
        source = "bunny",
        files = list("400" = "/tmp/test-400.ttf")
    )
    entry <- CacheEntry(family = "Test", meta = meta)

    # Invalid entry
    expect_error(
        update_download_and_cache(
            entry = "not an entry",
            provider = provider,
            name = "test",
            family_name = "Test",
            missing_weights = c(700),
            subset = "latin",
            cache_dir = withr::local_tempdir()
        ),
        "must be a <CacheEntry> object"
    )

    # Invalid provider
    expect_error(
        update_download_and_cache(
            entry = entry,
            provider = "not a provider",
            name = "test",
            family_name = "Test",
            missing_weights = c(700),
            subset = "latin",
            cache_dir = withr::local_tempdir()
        ),
        "must be a <FontProvider> object"
    )

    # Invalid missing_weights
    expect_error(
        update_download_and_cache(
            entry = entry,
            provider = provider,
            name = "test",
            family_name = "Test",
            missing_weights = numeric(0),
            subset = "latin",
            cache_dir = withr::local_tempdir()
        ),
        "must be a non-empty numeric vector"
    )
})

test_that("update_download_and_cache returns NULL when no files downloaded", {
    provider <- new_bunny_provider()

    meta <- CacheMeta(
        source = "bunny",
        files = list("400" = "/tmp/test-400.ttf")
    )
    entry <- CacheEntry(family = "Test", meta = meta)

    tmp <- withr::local_tempdir()

    # Mock download_weights to return empty list
    local_mocked_bindings(
        download_weights = function(...) {
            list()
        }
    )

    result <- update_download_and_cache(
        entry = entry,
        provider = provider,
        name = "test",
        family_name = "Test",
        missing_weights = c(700),
        subset = "latin",
        cache_dir = tmp,
        cel = NULL
    )

    expect_null(result)
})

test_that("update_download_and_cache merges new files with existing", {
    provider <- new_bunny_provider()

    # Create existing entry with weight 400
    meta <- CacheMeta(
        source = "bunny",
        files = list(
            "400" = "/tmp/test-400.ttf",
            "400italic" = "/tmp/test-400italic.ttf"
        )
    )
    entry <- CacheEntry(family = "Test", meta = meta)

    tmp <- withr::local_tempdir()

    # Mock download_weights to return weight 700
    local_mocked_bindings(
        download_weights = function(...) {
            list(
                "700" = "/tmp/test-700.ttf",
                "700italic" = "/tmp/test-700italic.ttf"
            )
        }
    )

    result <- update_download_and_cache(
        entry = entry,
        provider = provider,
        name = "test",
        family_name = "Test",
        missing_weights = c(700),
        subset = "latin",
        cache_dir = tmp,
        cel = NULL
    )

    # Should return updated CacheEntry
    expect_s7_class(result, CacheEntry)
    expect_equal(result@family, "Test")

    # Should have all 4 files (400, 400italic, 700, 700italic)
    expect_equal(length(result@meta@files), 4)
    expect_true("400" %in% names(result@meta@files))
    expect_true("400italic" %in% names(result@meta@files))
    expect_true("700" %in% names(result@meta@files))
    expect_true("700italic" %in% names(result@meta@files))

    # Should preserve original source
    expect_equal(result@meta@source, "bunny")
})

test_that("update_download_and_cache updates cache when cel provided", {
    provider <- new_bunny_provider()

    tmp <- withr::local_tempdir()

    # Create and write initial cache
    meta <- CacheMeta(
        source = "bunny",
        files = list("400" = "/tmp/test-400.ttf")
    )
    entry <- CacheEntry(family = "Test", meta = meta)
    cel <- CacheEntryList(entries = list(entry))
    cache_write(cel, cache_dir = tmp, quiet = TRUE)

    # Mock download_weights
    local_mocked_bindings(
        download_weights = function(...) {
            list("700" = "/tmp/test-700.ttf")
        }
    )

    result <- update_download_and_cache(
        entry = entry,
        provider = provider,
        name = "test",
        family_name = "Test",
        missing_weights = c(700),
        subset = "latin",
        cache_dir = tmp,
        cel = cel
    )

    # Should update the cache on disk
    cel_updated <- cache_read(tmp)
    entries <- cache_get(cel_updated, families = "Test", quiet = TRUE)
    expect_equal(length(entries), 1)
    expect_equal(length(entries[[1]]@meta@files), 2)
    expect_true("700" %in% names(entries[[1]]@meta@files))
})

test_that("update_download_and_cache handles multiple missing weights", {
    provider <- new_bunny_provider()

    meta <- CacheMeta(
        source = "bunny",
        files = list("400" = "/tmp/test-400.ttf")
    )
    entry <- CacheEntry(family = "Test", meta = meta)

    tmp <- withr::local_tempdir()

    # Mock download_weights to return multiple weights
    local_mocked_bindings(
        download_weights = function(...) {
            list(
                "600" = "/tmp/test-600.ttf",
                "700" = "/tmp/test-700.ttf",
                "800" = "/tmp/test-800.ttf"
            )
        }
    )

    result <- update_download_and_cache(
        entry = entry,
        provider = provider,
        name = "test",
        family_name = "Test",
        missing_weights = c(600, 700, 800),
        subset = "latin",
        cache_dir = tmp,
        cel = NULL
    )

    # Should have all weights
    expect_equal(length(result@meta@files), 4) # 400 + 600 + 700 + 800
    expect_true(all(
        c("400", "600", "700", "800") %in% names(result@meta@files)
    ))
})

test_that("update_download_and_cache uses default cache_dir when NULL", {
    provider <- new_bunny_provider()

    meta <- CacheMeta(
        source = "bunny",
        files = list("400" = "/tmp/test-400.ttf")
    )
    entry <- CacheEntry(family = "Test", meta = meta)

    mock_cache_dir <- withr::local_tempdir()

    local_mocked_bindings(
        get_cache_dir = function() mock_cache_dir,
        download_weights = function(...) {
            list("700" = "/tmp/test-700.ttf")
        }
    )

    result <- update_download_and_cache(
        entry = entry,
        provider = provider,
        name = "test",
        family_name = "Test",
        missing_weights = c(700),
        subset = "latin",
        cache_dir = NULL,
        cel = NULL
    )

    expect_s7_class(result, CacheEntry)
})
