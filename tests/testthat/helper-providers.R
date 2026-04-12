# Test helper to create FontProvider objects for testing

#' Create a test FontProvider object
new_test_provider <- function(
    source = "test_source",
    url_template = "https://example.com/{family}/{family}-{subset}-{weight}-{style}.woff2",
    conversion = "woff2_to_ttf",
    conversion_ext = "woff2",
    aliases = list()
) {
    FontProvider(
        source = source,
        url_template = url_template,
        conversion = conversion,
        conversion_ext = conversion_ext,
        aliases = aliases
    )
}

#' Create a bunny-like FontProvider for testing
new_bunny_provider <- function() {
    FontProvider(
        source = "bunny",
        url_template = "https://fonts.bunny.net/{family}/files/{family}-{subset}-{weight}-{style}.woff2",
        conversion = "woff2_to_ttf",
        conversion_ext = "woff2",
        aliases = list("fonts.bunny.net")
    )
}
