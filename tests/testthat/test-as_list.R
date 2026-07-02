test_that("as_list.CacheMeta returns all four fields", {
  meta <- CacheMeta(
    source = "bunny",
    files = list("400" = "bunny-roboto-latin-400-normal.ttf")
  )
  l <- as_list(meta)
  expect_type(l, "list")
  expect_equal(l$source, "bunny")
  expect_equal(l$key_scheme, "weight")
  expect_equal(l$files, list("400" = "bunny-roboto-latin-400-normal.ttf"))
  expect_equal(l$failed_keys, list())
})

test_that("as_list.CacheMeta serializes failed_keys as list", {
  meta <- CacheMeta(
    source = "bunny",
    files = list("400" = "bunny-roboto-latin-400-normal.ttf"),
    failed_keys = c("700", "700italic")
  )
  l <- as_list(meta)
  expect_equal(l$failed_keys, list("700", "700italic"))
})

test_that("as_list.CacheEntry returns family and meta fields", {
  meta <- CacheMeta(
    source = "bunny",
    files = list("400" = "bunny-roboto-latin-400-normal.ttf")
  )
  entry <- CacheEntry(family = "roboto", meta = meta)
  l <- as_list(entry)
  expect_equal(l$family, "roboto")
  expect_true(is.list(l$meta))
  expect_equal(l$meta$source, "bunny")
})

test_that("as_list.CacheEntryList returns unnamed list with correct length", {
  meta1 <- CacheMeta(
    source = "prov",
    files = list("400" = "f1-regular.ttf")
  )
  entry1 <- CacheEntry(family = "f1", meta = meta1)

  meta2 <- CacheMeta(
    source = "prov2",
    files = list("400" = "f2-regular.ttf")
  )
  entry2 <- CacheEntry(family = "f2", meta = meta2)

  cel <- CacheEntryList(entries = list(entry1, entry2))

  l <- as_list(cel)
  expect_type(l, "list")
  expect_null(names(l))
  expect_equal(length(l), 2)
  expect_true(all(vapply(
    l,
    function(x) is.list(x) && !is.null(x$family) && !is.null(x$meta),
    logical(1)
  )))
})
