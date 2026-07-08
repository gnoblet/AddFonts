# Changelog

## AddFonts 1.0.0

- Stable release. Minimum R version lowered to 4.1.0 (was 4.5.0).
- Failed font weight downloads are now recorded in the cache to avoid
  repeated retry attempts on subsequent calls
  ([\#16](https://codeberg.org/gnoblet/AddFonts/issues/16)).
- Cleaned up exports: only user-facing functions are now exported
  (`add_font`, `cache_clean`, `preview_font`, `list_providers`,
  `register_provider`, `unregister_provider`, `FontProviderFile`,
  `FontProviderWeight`). Internal S7 classes are no longer exported
  ([\#9](https://codeberg.org/gnoblet/AddFonts/issues/9)).
- Internal refactoring: pure S7 dispatch in
  [`add_font()`](http://guillaume-noblet.com/AddFonts/reference/add_font.md),
  `CacheMeta` gains a `key_scheme` property, sentinel provider types
  replace runtime detection.

## AddFonts 0.1.0

- Rough draft release.
