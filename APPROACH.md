Overview

This document describes the high-level approach, the main responsibilities of the R files, and how the AddFonts helper functions work together.

Goals

- Keep a minimal, robust registry as a single JSON named-list (fonts_db.json) stored in the font cache.
- Use plain R (small, focused files) for provider and download helpers.
- Always attempt to obtain a regular and an italic variant (italic falls back to regular).
- Convert downloaded `.woff2` files to `.ttf` using the system `woff2_decompress` tool via the package helper.
- Register fonts for use in R via `sysfonts::font_add()`.

Data model

- Registry: a named list persisted as `fonts_db.json` in the cache directory. Each entry is keyed by `family` and contains a `meta` list with at least:
  - `source`: provider id (e.g. "bunny")
  - `family_id`: canonical id for the family
  - `files`: named list with paths for `regular`, `italic`, `bold`, `bolditalic`
  - `added`: timestamp when recorded

File layout and responsibilities (concise)

- R/get_cache_dir.R
  - `get_cache_dir()` — determines the cache dir (uses `get_font_cache_dir()` if present or `rappdirs::user_cache_dir("AddFonts")`).

- R/safe_id.R
  - `safe_id()` — make canonical, filesystem-safe font ids.

- R/make_db_filename.R / R/cache_ttf_path.R
  - `cache_ttf_filename()` and `cache_ttf_path()` — build canonical cache filenames for ttf files.

- R/cache_read.R / R/cache_write.R / R/cache_get.R / R/cache_set.R
  - Read/write helpers that operate on the single JSON file and present the cache as a named list in memory.
  - `cache_get()` provides lookups by family or by `family_id`.

- R/new_bunny_provider.R / R/provider_from_name.R / R/provider_name.R
  - Simple plain-R provider objects and helpers. Providers are lists with a `source` and `url_template`.
  - `provider_from_name()` returns the provider object from a short name.

- R/download_variant_bunny.R / R/download_and_convert.R / R/ensure_variants_for_weight.R
  - Provider-specific download of `.woff2` files (`download_variant_bunny()`), plus glue that calls `download_variant()`.
  - `download_and_convert()` validates provider shape and dispatches to provider download; then conversion is done with `.woff2_to_ttf()`.
  - `.ensure_variants_for_weight()` fetches both `normal` and `italic` for a weight and applies the italic->regular fallback.

- R/woff2_to_ttf.R
  - `.woff2_to_ttf()` — wrapper around the `woff2_decompress` system tool. Ensures the output `.ttf` exists and errors with actionable messages if the system tool is missing or conversion fails.

- R/add_font.R / R/add_font_bunny.R
  - `add_font()` is the top-level orchestration: pick/construct provider, ensure cache dir, check registry, download required variants, compute fallback mapping (regular/italic/bold/bolditalic), persist the registry entry, and call `sysfonts::font_add()` to register the family in R.
  - `add_font_bunny()` convenience wrapper for the Bunny provider.

Design notes and behavior

- Registry persistence: every successful add updates `fonts_db.json` so the index reflects converted `.ttf` files (files are stored in the cache dir).
- File naming: canonical, prefixed with the provider name to reduce collisions.
- Simplicity: providers are plain lists to keep extension simple; to add a new provider implement a `download_variant_<provider>()` function and add a `provider_from_name()` branch.
- Error handling: functions raise `cli::cli_abort()` on bad inputs and provide informative messages for missing tools or download failures.

How to extend

- To add a provider: add `R/download_variant_<name>.R` implementing `download_variant_<name>(provider, family, weight, style, subset, cache_dir)` and update `provider_from_name()` to return a new provider object.
- To change storage: the registry helper pair `read_registry()` / `write_registry()` centralize the storage format.

Quick example

- Load package and add a family from Bunny:

  - `devtools::load_all()`
  - `add_font_bunny("Merriweather")`

This will download `.woff2` files, convert to `.ttf`, persist the registry, and register the family for R plotting.

Contact

If you want different file splitting or alternate naming conventions, tell me which functions you want grouped together and I will update the layout.
