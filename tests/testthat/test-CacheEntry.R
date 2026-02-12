test_that("CacheEntry S7 class basics works correctly", {
  meta <- CacheMeta(
    family_id = "fid",
    source = "bunny",
    files = list("400" = "r.ttf")
  )

  entry <- CacheEntry(
    family = "fid",
    meta = meta
  )

  # S3 and S7 classes
  expect_s3_class(entry, "AddFonts::CacheEntry")
  expect_s7_class(entry, CacheEntry)

  # meta property is CacheMeta
  expect_s7_class(entry@meta, CacheMeta)

  expect_equal(entry@family, "fid")
  expect_equal(entry@meta, meta)
})

test_that("CacheEntry validation works correctly", {
  meta <- CacheMeta(
    family_id = "fid",
    source = "bunny",
    files = list("400" = "r.ttf")
  )

  # invalid family (empty)
  expect_error(
    CacheEntry(
      family = "",
      meta = meta
    )
  )

  # invalid family (different from meta@family_id)
  expect_warning(
    CacheEntry(
      family = "different-fid",
      meta = meta
    )
  )

  # meta is not CacheMeta
  expect_error(
    CacheEntry(
      family = "fid",
      meta = "not a CacheMeta"
    )
  )
})
