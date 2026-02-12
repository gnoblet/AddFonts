subset = "latin"
family = "roboto"
weight = 400
provider_l = get_provider_details("bunny")
subset = "latin"
style = 'normal'

cache_variant_paths(
  weight = weight,
  family = family,
  provider_l = provider_l,
  subset = "latin",
  style = style
)

download_variant_generic(
  provider_l = provider_l,
  family = family,
  weight = weight,
  style = style,
  subset = "latin",
  cache_dir = NULL
)
