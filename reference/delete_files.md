# Delete files

Attempt to delete a set of files (character vector or list of paths).

## Usage

``` r
delete_files(entries, quiet = c("full", "success", "fail", "none"))
```

## Arguments

- entries:

  (`character`) Character vector of file paths to remove.

- quiet:

  (full" \| "success" \| "fail" \| "none) If "full", capture all output
  and suppress console messages; if "success", only show success
  messages; if "fail", only show error messages; if "none", show all
  messages (default: "none").

## Value

(`list`) A list with the following elements:

- deleted: character() — paths successfully deleted

- failed: character() — paths that existed but could not be deleted

- not_found: character() — paths that were not found on disk
