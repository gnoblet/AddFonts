# provider

# font should check that existing fonts family is from the right provider before registering from cache
# but for that the registered entry should be provider_family in database 
# as are files paths right

# review provider url template and sprintf approach for other providers

# for now download get a warning for each version.... italic and weights


> add_font('oswald')
✔ Converted /home/gnoblet/.cache/AddFonts/bunny-oswald-latin-400-normal.woff2 to TTF: /home/gnoblet/.cache/AddFonts/bunny-oswald-latin-400-normal.ttf
✔ Downloaded variant: bunny-oswald-latin-400-normal.ttf
✔ Font "oswald" registered and added to cache.
this is not the right order for messages, conver no message

# more reobust validator for  font files paths

# for all classes, check for default values when missing