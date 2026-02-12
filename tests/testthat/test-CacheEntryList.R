test_that("CacheEntryList S7 class basics works correctly", {
  meta1 <- CacheMeta(
    family_id = "fid1",
    source = "bunny",
    files = list("400" = "r1.ttf")
  )
  entry1 <- CacheEntry(
    family = "fid1",
    meta = meta1
  )

  meta2 <- CacheMeta(
    family_id = "fid2",
    source = "fox",
    files = list("400" = "r2.ttf")
  )
  entry2 <- CacheEntry(
    family = "fid2",
    meta = meta2
  )

  entry_list <- CacheEntryList(
    entries = list(entry1, entry2)
  )

  expect_s3_class(entry_list, "AddFonts::CacheEntryList")
  expect_s7_class(entry_list, CacheEntryList)

  expect_equal(entry_list@entries, list(entry1, entry2))
})

test_that("CacheEntryList validation works correctly", {
  meta <- CacheMeta(
    family_id = "fid",
    source = "bunny",
    files = list("400" = "r.ttf")
  )
  entry <- CacheEntry(
    family = "fid",
    meta = meta
  )

  # invalid entries (not a list)
  expect_error(
    CacheEntryList(
      entries = "not a list"
    ),
    "@entries must be <list>"
  )

  # invalid entries (list with non-CacheEntry)
  expect_error(
    CacheEntryList(
      entries = list(entry, "not a CacheEntry")
    ),
    "All elements of self@entries must be <CacheEntry>"
  )
})
