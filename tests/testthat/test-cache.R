meta <- CacheMeta(
  family_id = "cw",
  source = "s",
  files = list("400" = "cw.ttf")
)
entry <- CacheEntry(family = "cw", meta = meta)
cel <- CacheEntryList(entries = list(entry))


test_that("cache_write and cache_read work with a real directory", {
  tmp <- tempfile("addfonts_cache_")
  dir.create(tmp)
  on.exit(unlink(tmp, recursive = TRUE), add = TRUE)

  cache_write(cel, cache_dir = tmp)
  cache_file <- fs::path(tmp, "fonts_db.json")
  expect_true(fs::file_exists(cache_file))

  cel_read <- cache_read(tmp)
  expect_s7_class(cel_read, CacheEntryList)
  expect_equal(
    vapply(cel_read@entries, function(e) e@family, character(1)),
    "cw"
  )
})

test_that("cache_write errors on invalid input", {
  expect_error(
    cache_write(NULL),
    "Can't find method for"
  )
  expect_error(cache_write(list()), "Can't find method for")
  expect_error(cache_write(1:10), "Can't find method for")
})

test_that("cache_write quietly (or not) writes cache index", {
  tmp <- tempfile("quiet_cache_")
  dir.create(tmp)
  on.exit(unlink(tmp, recursive = TRUE), add = TRUE)

  # write with quiet = TRUE
  expect_silent(cache_write(cel, cache_dir = tmp, quiet = TRUE))
  expect_true(fs::file_exists(fs::path(tmp, "fonts_db.json")))

  # write with quiet = FALSE
  expect_message(
    cache_write(cel, cache_dir = tmp, quiet = FALSE),
    "Cache index written to"
  )
})

test_that("cache_read errors when index missing", {
  tmp <- tempfile("no_cache_")
  dir.create(tmp)
  on.exit(unlink(tmp, recursive = TRUE), add = TRUE)
  expect_error(cache_read(tmp))
})

test_that("cache_get and cache_set behave as expected", {
  m1 <- CacheMeta(
    family_id = "g1",
    source = "s",
    files = list("400" = "g1.ttf")
  )
  e1 <- CacheEntry(family = "g1", meta = m1)
  m2 <- CacheMeta(
    family_id = "g2",
    source = "s2",
    files = list("400" = "g2.ttf")
  )
  e2 <- CacheEntry(family = "g2", meta = m2)

  cel <- CacheEntryList(entries = list(e1))

  # get all
  all_entries <- cache_get(cel)
  expect_equal(length(all_entries), 1)

  # get specific
  got <- cache_get(cel, families = "g1")
  expect_equal(length(got), 1)
  expect_equal(got[[1]]@family, "g1")

  # set new family (append)
  cel2 <- cache_set(cel, family = "g2", meta = m2)
  expect_equal(length(cel2@entries), 2)

  # replace existing
  m1b <- CacheMeta(
    family_id = "g1",
    source = "x",
    files = list("400" = "g1b.ttf")
  )
  cel3 <- cache_set(cel2, family = "g1", meta = m1b)
  fams <- vapply(cel3@entries, function(e) e@family, character(1))
  expect_equal(sort(fams), sort(c("g1", "g2")))
  # verify replacement
  idx <- which(fams == "g1")
  expect_equal(cel3@entries[[idx]]@meta@source, "x")
})

#######################
## cache_remove tests
#######################

test_that("cache_remove works as expected both in-memory and on-disk", {
  tmp <- tempfile("af-cache-")
  dir.create(tmp)
  on.exit(unlink(tmp, recursive = TRUE), add = TRUE)

  # create CacheEntryList with two entries
  cm1 <- CacheMeta(
    family_id = "fid1",
    source = "bunny",
    files = list("400" = "FamilyA-Regular.ttf")
  )
  cm2 <- CacheMeta(
    family_id = "fid2",
    source = "bunny",
    files = list("400" = "FamilyB-Regular.ttf")
  )

  ce1 <- CacheEntry(
    family = "fid1",
    meta = cm1
  )

  ce2 <- CacheEntry(
    family = "fid2",
    meta = cm2
  )
  cel <- CacheEntryList(
    entries = list(
      "FamilyA" = ce1,
      "FamilyB" = ce2
    )
  )
  cache_write(cel, cache_dir = tmp, quiet = TRUE)
  # write fake files
  fs::file_create(fs::path(tmp, "FamilyA-Regular.ttf"))
  fs::file_create(fs::path(tmp, "FamilyB-Regular.ttf"))
  cel <- cache_read(tmp)
  # Remove a single family. Accept both in-place and returned-object semantics.
  res <- cache_remove(
    cel,
    families = "fid1"
  )
  res_none <- cache_remove(cel)
  # res is CacheEntryList with one entry
  expect_s7_class(res, CacheEntryList)
  expect_true(length(res@entries) == 1)
  # res_none is CacheEntryList with no entry
  expect_s7_class(res_none, CacheEntryList)
  expect_true(length(res_none@entries) == 0)
  # remove on-disk
  cache_remove(cel, families = "fid1", cache_dir = tmp)
  expect_false(fs::file_exists(fs::path(tmp, "FamilyA-Regular.ttf")))
  expect_true(fs::file_exists(fs::path(tmp, "FamilyB-Regular.ttf")))
  cache_remove(cel, families = NULL, cache_dir = tmp)

  expect_false(fs::file_exists(fs::path(tmp, "FamilyB-Regular.ttf")))
})

test_that("cache_remove works with empty CacheEntryList", {
  cel_empty <- CacheEntryList(entries = list())
  res <- cache_remove(cel_empty, families = NULL)
  expect_s7_class(res, CacheEntryList)
  expect_true(length(res@entries) == 0)
})

########################
## cache_clean tests
########################

test_that("cache_clean on-disk empties the cache and removes files", {
  tmp <- tempfile("af-cache-")
  dir.create(tmp)
  on.exit(unlink(tmp, recursive = TRUE), add = TRUE)

  # create CacheEntryList with two entries
  cm1 <- CacheMeta(
    family_id = "fid1",
    source = "bunny",
    files = list("400" = "FamilyA-Regular.ttf")
  )
  cm2 <- CacheMeta(
    family_id = "fid2",
    source = "bunny",
    files = list("400" = "FamilyB-Regular.ttf")
  )

  ce1 <- CacheEntry(
    family = "fid1",
    meta = cm1
  )
  ce2 <- CacheEntry(
    family = "fid2",
    meta = cm2
  )
  cel <- CacheEntryList(
    entries = list(
      "FamilyA" = ce1,
      "FamilyB" = ce2
    )
  )
  cache_write(cel, cache_dir = tmp, quiet = TRUE)
  # write fake files
  fs::file_create(fs::path(tmp, "FamilyA-Regular.ttf"))
  fs::file_create(fs::path(tmp, "FamilyB-Regular.ttf"))
  cel <- cache_read(tmp)
  # Remove a single family. Accept both in-place and returned-object semantics.
  cache_clean(
    cache_dir = tmp,
    families = "fid1"
  )
  expect_false(fs::file_exists(fs::path(tmp, "FamilyA-Regular.ttf")))
  expect_true(fs::file_exists(fs::path(tmp, "FamilyB-Regular.ttf")))
  cache_clean(
    cache_dir = tmp,
    families = NULL
  )
  expect_false(fs::file_exists(fs::path(tmp, "FamilyB-Regular.ttf")))

  # verify cache is empty
  cel_after <- cache_read(tmp)
  expect_s7_class(cel_after, CacheEntryList)
  expect_true(length(cel_after@entries) == 0)

  # reset cache
  cache_clean(
    cache_dir = tmp,
    families = NULL,
    reset = TRUE
  )
  cel_reset <- cache_read(tmp)
  expect_s7_class(cel_reset, CacheEntryList)
  expect_true(length(cel_reset@entries) == 0)
})

###########################
## cache_get_weights tests
###########################

test_that("cache_get_weights returns available and missing weights", {
  fn <- getFromNamespace("cache_get_weights", "AddFonts")

  # Create entry with weights 400 and 700
  meta <- CacheMeta(
    family_id = "test",
    source = "bunny",
    files = list(
      "400" = "/tmp/test-400.ttf",
      "400italic" = "/tmp/test-400italic.ttf",
      "700" = "/tmp/test-700.ttf"
    )
  )
  entry <- CacheEntry(family = "Test", meta = meta)

  # Check for weights that exist
  result <- fn(entry, c(400, 700))
  expect_type(result, "logical")
  expect_equal(result, c(TRUE, TRUE))
})

test_that("cache_get_weights identifies missing weights", {
  fn <- getFromNamespace("cache_get_weights", "AddFonts")

  # Create entry with only weight 400
  meta <- CacheMeta(
    family_id = "test",
    source = "bunny",
    files = list("400" = "/tmp/test-400.ttf")
  )
  entry <- CacheEntry(family = "Test", meta = meta)

  # Check for weights 400 and 700
  result <- fn(entry, c(400, 700))
  expect_equal(result, c(TRUE, FALSE))
})

test_that("cache_get_weights handles all missing weights", {
  fn <- getFromNamespace("cache_get_weights", "AddFonts")

  # Create entry with weight 300
  meta <- CacheMeta(
    family_id = "test",
    source = "bunny",
    files = list("300" = "/tmp/test-300.ttf")
  )
  entry <- CacheEntry(family = "Test", meta = meta)

  # Check for weights 400 and 700 (both missing)
  result <- fn(entry, c(400, 700))
  expect_equal(result, c(FALSE, FALSE))
})

test_that("cache_get_weights validates arguments", {
  fn <- getFromNamespace("cache_get_weights", "AddFonts")

  meta <- CacheMeta(
    family_id = "test",
    source = "bunny",
    files = list("400" = "/tmp/test.ttf")
  )
  entry <- CacheEntry(family = "Test", meta = meta)

  # Invalid entry
  expect_error(
    fn("not an entry", c(400)),
    "Can't find method for"
  )

  # Invalid weights
  expect_error(
    fn(entry, numeric(0)),
    "must be a non-empty numeric vector"
  )

  expect_error(
    fn(entry, "not numeric"),
    "must be a non-empty numeric vector"
  )
})
