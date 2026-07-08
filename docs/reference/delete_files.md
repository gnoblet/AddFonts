# Delete files

Attempt to delete a set of files (character vector or list of paths).

## Usage

``` r
delete_files(entries, quiet = FALSE)
```

## Arguments

- entries:

  (`character`) Character vector of file paths to remove.

- quiet:

  (`logical(1)`) If `TRUE`, suppress all console messages. If `FALSE`,
  show success and failure messages (default: `FALSE`).

## Value

(`list`) A list with the following elements:

- deleted: character() — paths successfully deleted

- failed: character() — paths that existed but could not be deleted

- not_found: character() — paths that were not found on disk
