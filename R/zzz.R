.onAttach <- function(libname, pkgname) {
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
      "  - Windows:             https://github.com/google/woff2"
    )
  } else {
    packageStartupMessage(
      "AddFonts loaded successfully. woff2_decompress found at: ",
      woff2_cmd
    )
  }
}
