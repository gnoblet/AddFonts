test_that("as_list returns native lists for classes", {
  meta1 <- CacheMeta(
    family_id = "f1",
    source = "prov",
    files = list("400" = "f1-regular.ttf")
  )
  entry1 <- CacheEntry(family = "f1", meta = meta1)

  meta2 <- CacheMeta(
    family_id = "f2",
    source = "prov2",
    files = list("400" = "f2-regular.ttf")
  )
  entry2 <- CacheEntry(family = "f2", meta = meta2)

  cel <- CacheEntryList(entries = list(entry1, entry2))

  l <- as_list(cel)
  expect_type(l, "list")
  expect_equal(length(l), 2)

  # each element should be a list with family and meta fields
  expect_true(all(vapply(
    l,
    function(x) is.list(x) && !is.null(x$family) && !is.null(x$meta),
    logical(1)
  )))
})
