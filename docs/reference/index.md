# Package index

## All functions

- [`CacheEntry()`](http://guillaume-noblet.com/AddFonts/reference/CacheEntry.md)
  : S7-backed cache entry (CacheEntry)

- [`CacheEntryList()`](http://guillaume-noblet.com/AddFonts/reference/CacheEntryList.md)
  : S7 list of cache entries (CacheEntryList)

- [`CacheMeta()`](http://guillaume-noblet.com/AddFonts/reference/CacheMeta.md)
  : S7-backed cache metadata (CacheMeta)

- [`FontProvider()`](http://guillaume-noblet.com/AddFonts/reference/FontProvider.md)
  : Base font provider class (FontProvider)

- [`FontProviderDirectURL()`](http://guillaume-noblet.com/AddFonts/reference/FontProviderDirectURL.md)
  : Sentinel provider for direct-URL font downloads (provider = "url")

- [`FontProviderFile()`](http://guillaume-noblet.com/AddFonts/reference/FontProviderFile.md)
  : File-based font provider (FontProviderFile)

- [`FontProviderLocal()`](http://guillaume-noblet.com/AddFonts/reference/FontProviderLocal.md)
  : Sentinel provider for local font files (provider = "file")

- [`FontProviderWeight()`](http://guillaume-noblet.com/AddFonts/reference/FontProviderWeight.md)
  : Weight-based font provider (FontProviderWeight)

- [`add_font()`](http://guillaume-noblet.com/AddFonts/reference/add_font.md)
  : Add a font to the local cache and register it for use

- [`as_CacheEntryList()`](http://guillaume-noblet.com/AddFonts/reference/as_CacheEntryList.md)
  : Read from list

- [`as_FontProvider()`](http://guillaume-noblet.com/AddFonts/reference/as_FontProvider.md)
  : Construct a FontProvider subclass from a named list

- [`as_list()`](http://guillaume-noblet.com/AddFonts/reference/as_list.md)
  : As list

- [`cache_clean()`](http://guillaume-noblet.com/AddFonts/reference/cache_clean.md)
  : Clean cache entries

- [`cache_file_path()`](http://guillaume-noblet.com/AddFonts/reference/cache_file_path.md)
  : Compute canonical cache path for a file-based (symbolic-variant)
  font file

- [`cache_get()`](http://guillaume-noblet.com/AddFonts/reference/cache_get.md)
  : Get certain families from CacheEntryList

- [`cache_get_variants()`](http://guillaume-noblet.com/AddFonts/reference/cache_get_variants.md)
  : Check which symbolic variant keys are present in a CacheEntry

- [`cache_get_weights()`](http://guillaume-noblet.com/AddFonts/reference/cache_get_weights.md)
  : Check which weights are available in a cache entry

- [`cache_read()`](http://guillaume-noblet.com/AddFonts/reference/cache_read.md)
  : Read cache entry from disk

- [`cache_remove()`](http://guillaume-noblet.com/AddFonts/reference/cache_remove.md)
  : Delete entry from cache

- [`cache_set()`](http://guillaume-noblet.com/AddFonts/reference/cache_set.md)
  : Set cache entries

- [`cache_ttf_filename()`](http://guillaume-noblet.com/AddFonts/reference/cache_ttf_filename.md)
  : Compose canonical filename for a cached TTF

- [`cache_ttf_path()`](http://guillaume-noblet.com/AddFonts/reference/cache_ttf_path.md)
  : Compute canonical cache path for a TTF file

- [`cache_variant_paths()`](http://guillaume-noblet.com/AddFonts/reference/cache_variant_paths.md)
  : Compute paths used for caching provider artifacts and any conversion
  intermediate files.

- [`cache_write()`](http://guillaume-noblet.com/AddFonts/reference/cache_write.md)
  : Write CacheEntryList to disk as JSON

- [`conv_fun()`](http://guillaume-noblet.com/AddFonts/reference/conv_fun.md)
  :

  Resolve a conversion name to the converter function used by the
  package (currently only `woff2_to_ttf`).

- [`copy_and_cache_local()`](http://guillaume-noblet.com/AddFonts/reference/copy_and_cache_local.md)
  : Copy local font files to cache and create a cache entry

- [`copy_variant_to_cache()`](http://guillaume-noblet.com/AddFonts/reference/copy_variant_to_cache.md)
  : Copy one local font file into the cache

- [`delete_files()`](http://guillaume-noblet.com/AddFonts/reference/delete_files.md)
  : Delete files

- [`.add_font_direct_url()`](http://guillaume-noblet.com/AddFonts/reference/dot-add_font_direct_url.md)
  : Route add_font() for provider = "url" (direct download)

- [`.add_font_file()`](http://guillaume-noblet.com/AddFonts/reference/dot-add_font_file.md)
  : Route add_font() for a file-based provider

- [`.add_font_local()`](http://guillaume-noblet.com/AddFonts/reference/dot-add_font_local.md)
  : Route add_font() for provider = "file" (local copies)

- [`.add_font_weight()`](http://guillaume-noblet.com/AddFonts/reference/dot-add_font_weight.md)
  : Route add_font() for a weight-based provider

- [`.fetch_url_to_cache()`](http://guillaume-noblet.com/AddFonts/reference/dot-fetch_url_to_cache.md)
  : Download a URL to a local file via httr2

- [`.persist_cache_entry()`](http://guillaume-noblet.com/AddFonts/reference/dot-persist_cache_entry.md)
  : Build a CacheEntry, persist the cache index, and return the entry

- [`.validate_variants()`](http://guillaume-noblet.com/AddFonts/reference/dot-validate_variants.md)
  : Validate a variants list

- [`download_and_cache()`](http://guillaume-noblet.com/AddFonts/reference/download_and_cache.md)
  : Download font variants and add to cache

- [`download_and_cache_file()`](http://guillaume-noblet.com/AddFonts/reference/download_and_cache_file.md)
  : Download all variants of a file-based font and add to cache

- [`download_and_cache_url()`](http://guillaume-noblet.com/AddFonts/reference/download_and_cache_url.md)
  : Download direct-URL font variants and add to cache

- [`download_variant_file()`](http://guillaume-noblet.com/AddFonts/reference/download_variant_file.md)
  : Download one font file from a file-based provider

- [`download_variant_generic()`](http://guillaume-noblet.com/AddFonts/reference/download_variant_generic.md)
  : Download and (if needed) convert a provider artifact to a local TTF
  file for a given family/weight/style and return the local path.

- [`download_weights()`](http://guillaume-noblet.com/AddFonts/reference/download_weights.md)
  : Download font files for specified weights

- [`get_cache_dir()`](http://guillaume-noblet.com/AddFonts/reference/get_cache_dir.md)
  : Get the package cache directory for fonts

- [`get_provider_details()`](http://guillaume-noblet.com/AddFonts/reference/get_provider_details.md)
  : Get provider details from internal data

- [`list_providers()`](http://guillaume-noblet.com/AddFonts/reference/list_providers.md)
  : List all available font providers

- [`maybe_show_first_use()`](http://guillaume-noblet.com/AddFonts/reference/maybe_show_first_use.md)
  : Show a provider's first-use message, at most once per session

- [`preview_font()`](http://guillaume-noblet.com/AddFonts/reference/preview_font.md)
  : Preview a font by ensuring it's installed and drawing a sample
  string

- [`register_from_cache()`](http://guillaume-noblet.com/AddFonts/reference/register_from_cache.md)
  :

  Validate a cache entry and register the font with sysfonts if the
  required files exist. Returns the prepared `files` list or `NULL` when
  registration cannot proceed.

- [`register_provider()`](http://guillaume-noblet.com/AddFonts/reference/register_provider.md)
  : Register a font provider for the current session

- [`safe_id()`](http://guillaume-noblet.com/AddFonts/reference/safe_id.md)
  : Create a filesystem-safe id from a name

- [`unregister_provider()`](http://guillaume-noblet.com/AddFonts/reference/unregister_provider.md)
  : Remove a font provider from the session registry

- [`update_download_and_cache()`](http://guillaume-noblet.com/AddFonts/reference/update_download_and_cache.md)
  : Download missing weights and update an existing cache entry

- [`woff2_to_ttf()`](http://guillaume-noblet.com/AddFonts/reference/woff2_to_ttf.md)
  : Convert a .woff2 font to .ttf using the system 'woff2_decompress'
  tool
