test_that("safe_id() creates filesystem-safe identifiers", {
    # Basic conversion
    expect_equal(safe_id("MyFont"), "myfont")
    expect_equal(safe_id("My Font"), "my-font")
    expect_equal(safe_id("My-Font"), "my-font")

    # Special characters
    expect_equal(safe_id("Font@123"), "font-123")
    expect_equal(safe_id("Font#Name"), "font-name")
    expect_equal(safe_id("Font$Name"), "font-name")
    expect_equal(safe_id("Font%Name"), "font-name")
    expect_equal(safe_id("Font!Name"), "font-name")

    # Already safe names
    expect_equal(safe_id("font-123"), "font-123")
    expect_equal(safe_id("font123"), "font123")

    # Multiple special characters in a row
    expect_equal(safe_id("Font!!!Name"), "font---name")
    expect_equal(safe_id("My   Font"), "my---font")

    # Mixed case with numbers
    expect_equal(safe_id("Font123ABC"), "font123abc")
    expect_equal(safe_id("ABC-123-xyz"), "abc-123-xyz")
})

test_that("safe_id() handles edge cases", {
    # Empty strings not allowed (should be caught by assert)
    expect_error(safe_id(""))

    # NULL not allowed
    expect_error(safe_id(NULL))

    # Non-character input should error
    expect_error(safe_id(123))
    expect_error(safe_id(c("a", "b")))
})

test_that("delete_files() deletes existing files", {
    # Create temporary files
    temp_dir <- withr::local_tempdir()
    file1 <- fs::path(temp_dir, "test1.txt")
    file2 <- fs::path(temp_dir, "test2.txt")

    fs::file_create(file1)
    fs::file_create(file2)

    expect_true(fs::file_exists(file1))
    expect_true(fs::file_exists(file2))

    # Delete files
    result <- delete_files(c(file1, file2), quiet = "full")

    expect_false(fs::file_exists(file1))
    expect_false(fs::file_exists(file2))
    expect_equal(result$deleted, as.character(c(file1, file2)))
    expect_equal(result$failed, character(0))
    expect_equal(result$not_found, character(0))
})

test_that("delete_files() handles non-existent files", {
    temp_dir <- withr::local_tempdir()
    nonexistent <- fs::path(temp_dir, "does_not_exist.txt")

    result <- delete_files(nonexistent, quiet = "full")

    expect_equal(result$deleted, character(0))
    expect_equal(result$failed, character(0))
    expect_equal(result$not_found, as.character(nonexistent))
})

test_that("delete_files() handles mixed scenarios", {
    temp_dir <- withr::local_tempdir()
    file1 <- fs::path(temp_dir, "exists.txt")
    file2 <- fs::path(temp_dir, "missing.txt")

    fs::file_create(file1)

    result <- delete_files(c(file1, file2), quiet = "full")

    expect_equal(result$deleted, as.character(file1))
    expect_equal(result$failed, character(0))
    expect_equal(result$not_found, as.character(file2))
})

test_that("delete_files() quiet parameter works correctly", {
    temp_dir <- withr::local_tempdir()
    file1 <- fs::path(temp_dir, "test.txt")
    fs::file_create(file1)

    # quiet = "full" should suppress all messages
    expect_silent(delete_files(file1, quiet = "full"))

    # Create another file for testing
    file2 <- fs::path(temp_dir, "test2.txt")
    fs::file_create(file2)

    # quiet = "success" should show success messages
    expect_message(delete_files(file2, quiet = "success"), "Deleted")

    # quiet = "fail" with non-existent file should show info
    file3 <- fs::path(temp_dir, "missing.txt")
    expect_message(delete_files(file3, quiet = "fail"), "not found")
})

test_that("delete_files() validates arguments", {
    # Invalid quiet value
    expect_error(delete_files("file.txt", quiet = "invalid"))

    # NULL entries should be handled by assert
    expect_error(delete_files(NULL))
})
test_that("get_cache_dir() returns a valid directory path", {
    cache_dir <- get_cache_dir()

    expect_type(cache_dir, "character")
    expect_length(cache_dir, 1)
    expect_true(fs::dir_exists(cache_dir))
    expect_true(nzchar(cache_dir))
})

test_that("get_cache_dir() creates directory if missing", {
    # This is hard to test without mocking, but we can verify it returns
    # a path under the expected location
    cache_dir <- get_cache_dir()
    expected_base <- rappdirs::user_cache_dir("AddFonts")

    expect_equal(cache_dir, expected_base)
})

test_that("get_provider_details() returns valid FontProvider object", {
    provider <- get_provider_details("bunny")

    expect_s3_class(provider, "AddFonts::FontProvider")
    expect_true(S7::S7_inherits(provider, FontProvider))
    expect_type(provider@source, "character")
})

test_that("get_provider_details() handles invalid provider", {
    expect_error(
        get_provider_details("nonexistent_provider"),
        "Provider.*not found"
    )
})

test_that("get_provider_details() validates arguments", {
    expect_error(get_provider_details(NULL))
    expect_error(get_provider_details(""))
    expect_error(get_provider_details(123))
    expect_error(get_provider_details(c("bunny", "other")))
})

test_that("get_provider_details() lists available providers on error", {
    expect_error(
        get_provider_details("invalid"),
        "Available providers"
    )
})
