.onAttach <- function(libname, pkgname) {
  #------ Database

  # create database default file if it does not exist
  cache_dir <- get_cache_dir()
  cache_file <- fs::path(cache_dir, "fonts_db.json")

  # alert user about cache location
  # if cache file exists, inform user
  # else, create empty cache and inform user
  if (fs::file_exists(cache_file)) {
    packageStartupMessage(
      "Font cache located at: ",
      cache_file
    )
  } else {
    cache_write(as_CacheEntryList(list()), cache_dir, quiet = TRUE)
    if (fs::file_exists(cache_file)) {
      packageStartupMessage(
        "Font cache created at: ",
        cache_file
      )
    } else {
      packageStartupMessage(
        "Warning: Could not create font cache at: ",
        cache_file,
        "\nYou may want to use other cache_dir options while using the package."
      )
    }
  }

  #------ woff2

  # Check if woff2_decompress is available
  woff2_cmd <- Sys.which("woff2_decompress")

  if (!nzchar(woff2_cmd)) {
    packageStartupMessage(
      "Warning: woff2_decompress not found on your system.\n",
      "AddFonts requires this tool to convert downloaded fonts.\n",
      "Install it using:\n",
      "  - macOS (Homebrew):    brew install woff2\n",
      "  - Debian/Ubuntu:       sudo apt install woff2\n",
      "  - Fedora/RHEL:         sudo dnf install woff2-tools\n",
      "  - Arch Linux:          sudo pacman -S woff2\n",
      "  - Windows or else:     Compile from: https://github.com/google/woff2"
    )
  } else {
    packageStartupMessage(
      "AddFonts loaded successfully. woff2_decompress found at: ",
      woff2_cmd
    )
  }
}

.onLoad <- function(...) {
  S7::methods_register()
}
