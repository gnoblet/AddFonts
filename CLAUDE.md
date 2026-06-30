# AddFonts — Developer Reference for Claude

## Purpose

AddFonts downloads and registers fonts from GDPR-compliant providers for use in R graphics.
The main entry point is `add_font()`. Built-in provider: **Bunny Fonts** (`fonts.bunny.net`).
Users can register custom providers at runtime via `register_provider()`.
Architecture is designed to make adding new providers straightforward.

## OOP System: S7

The package uses **S7** (`S7::new_class`, `S7::new_generic`, `S7::method`) throughout.
Key rules:
- Properties are accessed with `@` (NOT `$`): `entry@family`, `meta@source`
- Type checking uses `S7::S7_inherits(obj, Class)`, not `inherits()` or `is()`
- Generics are defined with `S7::new_generic("name", "dispatch_arg", function(...) S7::S7_dispatch())`
- Methods are registered with `S7::method(generic, Class) <- function(x, ...) { ... }`
- Validators return `NULL` on success or a character string describing the error
- `S7::methods_register()` must be called in `.onLoad()` for S3 dispatch compatibility (see `zzz.R`)
- Collation order in `DESCRIPTION` is critical: `CacheMeta` → `CacheEntry` → `CacheEntryList` → `FontProvider` → `provider_registry.R` (child classes after parents; registry after `FontProvider` since it dispatches on it)

## S7 Classes

All defined in `R/` at the top of the collation list.

### `CacheMeta` (`R/CacheMeta.R`)
Describes a cached font's origin and file paths.
- `@source` — character: provider id (e.g. `"bunny"`)
- `@files` — named list: weight keys → local file paths
  - Keys: `"400"`, `"400italic"`, `"700"`, `"700italic"`, etc.

### `CacheEntry` (`R/CacheEntry.R`)
One entry in the cache index.
- `@family` — character: safe identifier (letters, digits, hyphens only)
- `@meta` — `CacheMeta`

Validator: `@family` must be a non-empty safe-id string (see `assert_pattern_with_ext`).

### `CacheEntryList` (`R/CacheEntryList.R`)
The full in-memory cache index.
- `@entries` — named list of `CacheEntry` objects

Keys are compound `"{source}::{family}"` strings (e.g. `"bunny::roboto"`).
The constructor auto-computes these keys from each entry's `@meta@source` and `@family`,
overriding any caller-supplied names. `as_CacheEntryList()` re-applies the same logic on
JSON round-trip. `as_list()` strips names before serialisation so the JSON stays a plain array.
Validator: all entries must have unique `source::family` combinations.

### `FontProvider` (`R/FontProvider.R`)
A font provider specification.
- `@source` — character: provider name (e.g. `"bunny"`)
- `@url_template` — character: **glue-style** template with named placeholders `{family}`, `{subset}`, `{weight}`, `{style}`
- `@conversion` — character | NULL: name of conversion function (`"woff2_to_ttf"` or `NULL`)
- `@conversion_ext` — character | NULL: source extension before conversion (e.g. `"woff2"`)
- `@aliases` — list: alternative names to recognise the provider

## S7 Generics

These generics dispatch on their first argument:

| Generic | Dispatch | File |
|---|---|---|
| `cache_write(x, cache_dir, quiet)` | `CacheEntryList` | `R/cache.R` |
| `cache_read(cache_dir)` | `character \| NULL` | `R/cache.R` |
| `cache_get(x, families, source, quiet)` | `CacheEntryList` | `R/cache.R` |
| `cache_set(x, family, meta)` | `CacheEntryList` | `R/cache.R` |
| `cache_remove(x, families, source, ...)` | `CacheEntryList` | `R/cache.R` |
| `cache_get_weights(x, weights)` | `CacheEntry` | `R/cache.R` |
| `as_list(x)` | `CacheMeta \| CacheEntry \| CacheEntryList` | `R/as_list.R` |
| `as_CacheEntryList(l)` | `list` | `R/as_CacheEntryList.R` |
| `as_FontProvider(x)` | `list` | `R/as_FontProvider.R` |
| `register_provider(provider, overwrite)` | `FontProvider` | `R/provider_registry.R` |
| `unregister_provider(x)` | `character \| FontProvider` | `R/provider_registry.R` |

## Key Functions (non-generic)

### Main user-facing function
**`add_font(name, provider, family, regular.wt, bold.wt, subset)`** (`R/add_font.R`)

Flow:
1. Validate args → `get_provider_details()` → `get_cache_dir()`
2. Read cache (`cache_read`) → look up family (`cache_get`)
3. **Cache hit, both weights present** → `register_from_cache()` → return
4. **Cache hit, regular only** → `update_download_and_cache()` → `register_from_cache()` → return (or fallthrough)
5. **Cache miss / wrong weights / stale** → `download_and_cache()` → `register_from_cache()` → return

### Download pipeline
- **`download_and_cache()`** (`R/download_and_cache.R`) — download all weights via `download_weights()`, build `CacheEntry`, write cache
- **`update_download_and_cache()`** (`R/update_download_and_cache.R`) — download only missing weights, merge with existing `CacheEntry`, update cache
- **`download_weights()`** (`R/download_weights.R`) — loop over weights × styles (normal + italic), call `download_variant_generic()`
- **`download_variant_generic()`** (`R/download_variant_generic.R`) — download one variant: build URL, `httr2::req_perform()`, optionally convert

### Conversion
- **`conv_fun(conversion)`** (`R/conv_fun.R`) — resolve a conversion name (e.g. `"woff2_to_ttf"`) to its function; `switch()` based
- **`woff2_to_ttf(woff2, ...)`** (`R/woff2_to_ttf.R`) — call system `woff2_decompress` via `processx` / `system2`

Currently the only supported conversion is `woff2_to_ttf`.

### Cache operations (`R/cache.R`)
- **`cache_write`** — serialize `CacheEntryList` → `fonts_db.json` via `jsonlite::write_json`
- **`cache_read`** — read `fonts_db.json` → `as_CacheEntryList()` → `CacheEntryList`
- **`cache_read_safe`** — `cache_read` wrapped in `tryCatch`; returns empty `CacheEntryList` on error
- **`cache_get`** — filter entries by family; if `source` is provided, uses O(1) key lookup, otherwise linear family-name scan; returns named list or `NULL`
- **`cache_set`** — upsert by compound `"{source}::{family}"` key (named-list assignment); source comes from `meta@source`
- **`cache_remove`** — remove by family (+ optional source for exact key); optionally delete referenced files
- **`cache_clean`** — remove entries from disk index and delete files; `reset = TRUE` recreates empty index
- **`cache_get_weights`** — logical vector: which requested weights are present in a `CacheEntry`

### Serialization round-trip
`CacheEntryList` ↔ JSON via `as_list()` (→ JSON) and `as_CacheEntryList()` (← JSON).
JSON format is a plain array of `{family, meta: {source, files}}` objects.

### Path computation (`R/cache_ttf_path.R`, `R/cache_variant_paths.R`)
- **`cache_ttf_filename(source, font_id, subset, weight, style)`** → `"{source}-{safe_id}-{subset}-{weight}-{style}.ttf"`
  - Example: `bunny-roboto-latin-400-normal.ttf`
- **`cache_ttf_path(..., cache_dir)`** → full `fs::path` to the cached TTF
- **`cache_variant_paths(provider, family, weight, style, subset, cache_dir)`** → list with `$ttf` (final TTF path) and `$to_convert` (intermediate path or `NULL`)

### Registration (`R/register_from_cache.R`)
**`register_from_cache(entry, regular.wt, bold.wt)`**
- Resolves the 4 variant paths (regular/italic/bold/bolditalic) from the `CacheEntry@meta@files`
- Fallback order: italic → regular, bold → regular, bolditalic → bold or regular
- Calls `sysfonts::font_add()` then `showtext::showtext_auto()`
- Returns `list(regular=, italic=, bold=, bolditalic=)` of local paths, or `NULL` if regular file missing/non-existent

### Provider system (`R/utils.R`, `R/provider_registry.R`, `R/sysdata.rda`, `data-raw/providers.R`)
- Built-in providers stored in `R/sysdata.rda` (rebuilt from `data-raw/providers.R`); `inst/extdata/providers.json` is the source of truth
- Session-level registry: `.provider_registry` env in `R/provider_registry.R`; session providers shadow built-ins
- **`register_provider(provider, overwrite)`** — S7 generic dispatching on `FontProvider`; registers for this R session
- **`unregister_provider(x)`** — S7 generic; dispatches on `character` (source name) or `FontProvider`
- **`list_providers()`** — merges built-in + session providers (session shadows built-in on name collision)
- **`get_provider_details(provider)`** (`R/utils.R`) — checks session registry first, then built-ins; returns `FontProvider`
- **`get_cache_dir()`** (`R/utils.R`) — `rappdirs::user_cache_dir("AddFonts")`; creates dir if missing

## Validation Helpers (`R/assert.R`)

All argument checking uses these internal functions (NOT exported):

| Function | Checks |
|---|---|
| `assert_null_or_non_empty_string(x, allow_null)` | scalar character, non-empty, non-NA |
| `assert_null_or_non_empty_character_vector(x, allow_null)` | character vector, non-empty elements |
| `assert_list_with_elements(x, required_elements)` | is a list, has required names |
| `assert_list_of_1_length_character_strings(x)` | list of scalar non-empty strings |
| `assert_pattern_with_ext(x, ext, allow_*)` | path-safe characters, optional extension check |
| `assert_string_in_set(x, choices)` | scalar string, must be in `choices` |

Error messages use `cli::cli_abort()` with `{.arg name}` inline markup.
Argument name is captured automatically with `rlang::as_label(rlang::enexpr(x))`.

## Utilities (`R/utils.R`)

- **`safe_id(name)`** — `tolower` + replace non-`[a-z0-9-]` with `-`; used for cache filenames
- **`delete_files(entries, quiet)`** — delete files, return list of `$deleted`, `$failed`, `$not_found`; `quiet = TRUE` suppresses messages

## Startup (`R/zzz.R`)

- `.onLoad` — calls `S7::methods_register()`
- `.onAttach` — checks/creates `fonts_db.json`; checks that system `woff2_decompress` is available

## URL Template Format

`glue::glue_data(list(family=family, subset=subset, weight=as.integer(weight), style=style), provider@url_template)`

Bunny template: `"https://fonts.bunny.net/{family}/files/{family}-{subset}-{weight}-{style}.woff2"`
→ `https://fonts.bunny.net/Roboto/files/Roboto-latin-400-normal.woff2`

Named placeholders: `{family}`, `{subset}`, `{weight}` (integer), `{style}`.
All four are always injected; a template only needs to use those it actually needs.
`@url_template` validator rejects templates that omit `{family}`.

## Packages Used

| Package | Role |
|---|---|
| `S7` | OOP system: classes, generics, methods |
| `cli` | User-facing error/warning/info messages (`cli_abort`, `cli_warn`, `cli_inform`, `cli_alert_success`) |
| `httr2` | HTTP requests (`request()` → `req_perform()`) |
| `fs` | Path manipulation, file/dir operations (always prefer over `file.path`, `dir.exists`, etc.) |
| `rappdirs` | Platform-appropriate user cache directory (`user_cache_dir("AddFonts")`) |
| `jsonlite` | JSON serialization (`write_json`, `read_json`) |
| `glue` | URL template interpolation (`glue_data`) and error context messages |
| `rlang` | `enexpr`/`as_label` for arg-name capture in assertions |
| `sysfonts` | Register fonts with graphics devices (`font_add`) |
| `showtext` | Enable custom fonts in R plots (`showtext_auto`) |
| `withr` | Test teardown: `local_tempdir()`, `local_options()`, etc. |
| `testthat` | Testing framework, edition 3 |

System dependency: `woff2_decompress` (the `woff2` CLI tool) must be installed.

## Testing Conventions

- **`devtools::load_all()`** exposes all functions including unexported ones — no `getFromNamespace()` needed
- **`local_mocked_bindings(fn = ..., .package = "AddFonts")`** — flat form (NOT the block form `with_mocked_bindings(..., { })`)
- **`withr::local_tempdir()`** for temp directories — NOT `tempfile()+dir.create()+on.exit(unlink(...))`
- **`withr::local_tempdir()`** even for validation tests that error before filesystem ops (for consistency)
- **Tracker env** instead of `<<-`:
  ```r
  tracker <- new.env(parent = emptyenv())
  tracker$called <- FALSE
  # inside mock closure:
  tracker$called <- TRUE
  # in assertions:
  expect_true(tracker$called)
  ```
- **`.env = parent.frame()`** is required when `local_mocked_bindings` is called inside a helper function — without it mocks are cleaned up before the test assertions run
- Each `test_that` block is fully self-contained: setup objects (including S7 objects) constructed inside the block, never at file top level
- Test helper file: `tests/testthat/helper-providers.R` — provides `new_bunny_provider()` and `new_test_provider(...)`
- Test files mirror source files 1:1: `test-add_font.R` ↔ `add_font.R`
- Use `expect_s7_class(obj, Class)` for S7 type assertions (NOT `expect_s3_class` with `"Namespace::Class"` string for S7 objects)
- Always add regexp patterns to `expect_error()` — bare `expect_error(expr)` is a weak assertion

## Cache Directory Layout

```
~/.cache/AddFonts/
  fonts_db.json                        # index: array of {family, meta}
  bunny-roboto-latin-400-normal.ttf    # cached TTF files
  bunny-roboto-latin-400italic.ttf
  bunny-roboto-latin-700-normal.ttf
  ...
```

## add_font() Decision Tree (simplified)

```
add_font("Roboto", provider = "bunny")
  │
  ├─ cache hit, has regular + bold weights?
  │    └─ register_from_cache() → return invisible(files)
  │
  ├─ cache hit, has regular only?
  │    └─ update_download_and_cache() → register_from_cache() → return
  │         (falls through to full re-download on failure)
  │
  └─ cache miss / wrong weights / stale?
       └─ download_and_cache()
            └─ download_weights()
                 └─ download_variant_generic() × (weights × styles)
                      ├─ httr2: download .woff2
                      └─ woff2_to_ttf() → .ttf
            └─ cache_write() → register_from_cache() → return
```

## Style Rules

- Use `fs::path()` not `file.path()`; `fs::dir_exists()` not `dir.exists()`
- Use `cli::cli_abort()` with inline markup for errors, NOT `stop()`
- Argument validation always at the top of each function body
- Unexported functions have no `@export` tag and no roxygen docs beyond `@typed`/`@typedreturn`
- Documentation uses `roxytypes` package: `@typed arg: type\n  Description` and `@typedreturn type\n  Description`
- `|>` native pipe, never `%>%`
- 2-space indentation, max ~80 char lines
