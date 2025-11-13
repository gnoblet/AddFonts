# List Available Fonts from Bunny.net (Direct Function)

Retrieve the list of fonts available from fonts.bunny.net using the
package's bundled database. This is a convenience function that directly
returns Bunny Fonts without going through the generic interface.

## Usage

``` r
font_list_bunny()
```

## Value

A data.frame with columns: family, familyName, category, weights,
styles, defSubset, isVariable, and url representing the fonts metadata
from Bunny Fonts.

## Examples

``` r
# List all available fonts
fonts <- font_list_bunny()
head(fonts)
#>           family     familyName   category variants.latin variants.latin-ext
#> 1        abeezee        ABeeZee sans-serif              2                  2
#> 2           abel           Abel sans-serif              1                 NA
#> 3   abhaya-libre   Abhaya Libre      serif              5                  5
#> 4        aboreto        Aboreto    display              1                  1
#> 5  abril-fatface  Abril Fatface    display              1                  1
#> 6 abyssinica-sil Abyssinica SIL      serif              1                  1
#>   variants.sinhala variants.ethiopic variants.adlam variants.greek
#> 1               NA                NA             NA             NA
#> 2               NA                NA             NA             NA
#> 3                5                NA             NA             NA
#> 4               NA                NA             NA             NA
#> 5               NA                NA             NA             NA
#> 6               NA                 1             NA             NA
#>   variants.cyrillic variants.cyrillic-ext variants.math variants.symbols
#> 1                NA                    NA            NA               NA
#> 2                NA                    NA            NA               NA
#> 3                NA                    NA            NA               NA
#> 4                NA                    NA            NA               NA
#> 5                NA                    NA            NA               NA
#> 6                NA                    NA            NA               NA
#>   variants.vietnamese variants.tifinagh variants.kannada variants.telugu
#> 1                  NA                NA               NA              NA
#> 2                  NA                NA               NA              NA
#> 3                  NA                NA               NA              NA
#> 4                  NA                NA               NA              NA
#> 5                  NA                NA               NA              NA
#> 6                  NA                NA               NA              NA
#>   variants.devanagari variants.hebrew variants.greek-ext variants.arabic
#> 1                  NA              NA                 NA              NA
#> 2                  NA              NA                 NA              NA
#> 3                  NA              NA                 NA              NA
#> 4                  NA              NA                 NA              NA
#> 5                  NA              NA                 NA              NA
#> 6                  NA              NA                 NA              NA
#>   variants.oriya variants.bengali variants.gujarati variants.gurmukhi
#> 1             NA               NA                NA                NA
#> 2             NA               NA                NA                NA
#> 3             NA               NA                NA                NA
#> 4             NA               NA                NA                NA
#> 5             NA               NA                NA                NA
#> 6             NA               NA                NA                NA
#>   variants.malayalam variants.tamil variants.khmer variants.thai
#> 1                 NA             NA             NA            NA
#> 2                 NA             NA             NA            NA
#> 3                 NA             NA             NA            NA
#> 4                 NA             NA             NA            NA
#> 5                 NA             NA             NA            NA
#> 6                 NA             NA             NA            NA
#>   variants.japanese variants.korean variants.chinese-hongkong
#> 1                NA              NA                        NA
#> 2                NA              NA                        NA
#> 3                NA              NA                        NA
#> 4                NA              NA                        NA
#> 5                NA              NA                        NA
#> 6                NA              NA                        NA
#>   variants.new-tai-lue variants.cherokee variants.armenian variants.tibetan
#> 1                   NA                NA                NA               NA
#> 2                   NA                NA                NA               NA
#> 3                   NA                NA                NA               NA
#> 4                   NA                NA                NA               NA
#> 5                   NA                NA                NA               NA
#> 6                   NA                NA                NA               NA
#>   variants.kayah-li variants.lisu variants.chinese-simplified variants.lepcha
#> 1                NA            NA                          NA              NA
#> 2                NA            NA                          NA              NA
#> 3                NA            NA                          NA              NA
#> 4                NA            NA                          NA              NA
#> 5                NA            NA                          NA              NA
#> 6                NA            NA                          NA              NA
#>   variants.limbu variants.gunjala-gondi variants.emoji variants.music
#> 1             NA                     NA             NA             NA
#> 2             NA                     NA             NA             NA
#> 3             NA                     NA             NA             NA
#> 4             NA                     NA             NA             NA
#> 5             NA                     NA             NA             NA
#> 6             NA                     NA             NA             NA
#>   variants.anatolian-hieroglyphs variants.avestan variants.balinese
#> 1                             NA               NA                NA
#> 2                             NA               NA                NA
#> 3                             NA               NA                NA
#> 4                             NA               NA                NA
#> 5                             NA               NA                NA
#> 6                             NA               NA                NA
#>   variants.bamum variants.bassa-vah variants.batak variants.bhaiksuki
#> 1             NA                 NA             NA                 NA
#> 2             NA                 NA             NA                 NA
#> 3             NA                 NA             NA                 NA
#> 4             NA                 NA             NA                 NA
#> 5             NA                 NA             NA                 NA
#> 6             NA                 NA             NA                 NA
#>   variants.brahmi variants.buginese variants.buhid variants.canadian-aboriginal
#> 1              NA                NA             NA                           NA
#> 2              NA                NA             NA                           NA
#> 3              NA                NA             NA                           NA
#> 4              NA                NA             NA                           NA
#> 5              NA                NA             NA                           NA
#> 6              NA                NA             NA                           NA
#>   variants.carian variants.caucasian-albanian variants.chakma variants.cham
#> 1              NA                          NA              NA            NA
#> 2              NA                          NA              NA            NA
#> 3              NA                          NA              NA            NA
#> 4              NA                          NA              NA            NA
#> 5              NA                          NA              NA            NA
#> 6              NA                          NA              NA            NA
#>   variants.chorasmian variants.coptic variants.cuneiform variants.cypriot
#> 1                  NA              NA                 NA               NA
#> 2                  NA              NA                 NA               NA
#> 3                  NA              NA                 NA               NA
#> 4                  NA              NA                 NA               NA
#> 5                  NA              NA                 NA               NA
#> 6                  NA              NA                 NA               NA
#>   variants.cypro-minoan variants.deseret variants.duployan
#> 1                    NA               NA                NA
#> 2                    NA               NA                NA
#> 3                    NA               NA                NA
#> 4                    NA               NA                NA
#> 5                    NA               NA                NA
#> 6                    NA               NA                NA
#>   variants.egyptian-hieroglyphs variants.elbasan variants.elymaic
#> 1                            NA               NA               NA
#> 2                            NA               NA               NA
#> 3                            NA               NA               NA
#> 4                            NA               NA               NA
#> 5                            NA               NA               NA
#> 6                            NA               NA               NA
#>   variants.georgian variants.glagolitic variants.gothic variants.grantha
#> 1                NA                  NA              NA               NA
#> 2                NA                  NA              NA               NA
#> 3                NA                  NA              NA               NA
#> 4                NA                  NA              NA               NA
#> 5                NA                  NA              NA               NA
#> 6                NA                  NA              NA               NA
#>   variants.hanifi-rohingya variants.hanunoo variants.hatran
#> 1                       NA               NA              NA
#> 2                       NA               NA              NA
#> 3                       NA               NA              NA
#> 4                       NA               NA              NA
#> 5                       NA               NA              NA
#> 6                       NA               NA              NA
#>   variants.imperial-aramaic variants.indic-siyaq-numbers
#> 1                        NA                           NA
#> 2                        NA                           NA
#> 3                        NA                           NA
#> 4                        NA                           NA
#> 5                        NA                           NA
#> 6                        NA                           NA
#>   variants.inscriptional-pahlavi variants.inscriptional-parthian
#> 1                             NA                              NA
#> 2                             NA                              NA
#> 3                             NA                              NA
#> 4                             NA                              NA
#> 5                             NA                              NA
#> 6                             NA                              NA
#>   variants.javanese variants.kaithi variants.kawi variants.kharoshthi
#> 1                NA              NA            NA                  NA
#> 2                NA              NA            NA                  NA
#> 3                NA              NA            NA                  NA
#> 4                NA              NA            NA                  NA
#> 5                NA              NA            NA                  NA
#> 6                NA              NA            NA                  NA
#>   variants.khojki variants.khudawadi variants.lao variants.linear-a
#> 1              NA                 NA           NA                NA
#> 2              NA                 NA           NA                NA
#> 3              NA                 NA           NA                NA
#> 4              NA                 NA           NA                NA
#> 5              NA                 NA           NA                NA
#> 6              NA                 NA           NA                NA
#>   variants.linear-b variants.lycian variants.lydian variants.mahajani
#> 1                NA              NA              NA                NA
#> 2                NA              NA              NA                NA
#> 3                NA              NA              NA                NA
#> 4                NA              NA              NA                NA
#> 5                NA              NA              NA                NA
#> 6                NA              NA              NA                NA
#>   variants.mandaic variants.manichaean variants.marchen variants.masaram-gondi
#> 1               NA                  NA               NA                     NA
#> 2               NA                  NA               NA                     NA
#> 3               NA                  NA               NA                     NA
#> 4               NA                  NA               NA                     NA
#> 5               NA                  NA               NA                     NA
#> 6               NA                  NA               NA                     NA
#>   variants.mayan-numerals variants.medefaidrin variants.meetei-mayek
#> 1                      NA                   NA                    NA
#> 2                      NA                   NA                    NA
#> 3                      NA                   NA                    NA
#> 4                      NA                   NA                    NA
#> 5                      NA                   NA                    NA
#> 6                      NA                   NA                    NA
#>   variants.mende-kikakui variants.meroitic variants.meroitic-cursive
#> 1                     NA                NA                        NA
#> 2                     NA                NA                        NA
#> 3                     NA                NA                        NA
#> 4                     NA                NA                        NA
#> 5                     NA                NA                        NA
#> 6                     NA                NA                        NA
#>   variants.meroitic-hieroglyphs variants.miao variants.modi variants.mongolian
#> 1                            NA            NA            NA                 NA
#> 2                            NA            NA            NA                 NA
#> 3                            NA            NA            NA                 NA
#> 4                            NA            NA            NA                 NA
#> 5                            NA            NA            NA                 NA
#> 6                            NA            NA            NA                 NA
#>   variants.mro variants.multani variants.myanmar variants.nabataean
#> 1           NA               NA               NA                 NA
#> 2           NA               NA               NA                 NA
#> 3           NA               NA               NA                 NA
#> 4           NA               NA               NA                 NA
#> 5           NA               NA               NA                 NA
#> 6           NA               NA               NA                 NA
#>   variants.nag-mundari variants.nandinagari variants.newa variants.nko
#> 1                   NA                   NA            NA           NA
#> 2                   NA                   NA            NA           NA
#> 3                   NA                   NA            NA           NA
#> 4                   NA                   NA            NA           NA
#> 5                   NA                   NA            NA           NA
#> 6                   NA                   NA            NA           NA
#>   variants.nushu variants.ogham variants.ol-chiki variants.old-hungarian
#> 1             NA             NA                NA                     NA
#> 2             NA             NA                NA                     NA
#> 3             NA             NA                NA                     NA
#> 4             NA             NA                NA                     NA
#> 5             NA             NA                NA                     NA
#> 6             NA             NA                NA                     NA
#>   variants.old-italic variants.old-north-arabian variants.old-permic
#> 1                  NA                         NA                  NA
#> 2                  NA                         NA                  NA
#> 3                  NA                         NA                  NA
#> 4                  NA                         NA                  NA
#> 5                  NA                         NA                  NA
#> 6                  NA                         NA                  NA
#>   variants.old-persian variants.old-sogdian variants.old-south-arabian
#> 1                   NA                   NA                         NA
#> 2                   NA                   NA                         NA
#> 3                   NA                   NA                         NA
#> 4                   NA                   NA                         NA
#> 5                   NA                   NA                         NA
#> 6                   NA                   NA                         NA
#>   variants.old-turkic variants.osage variants.osmanya variants.pahawh-hmong
#> 1                  NA             NA               NA                    NA
#> 2                  NA             NA               NA                    NA
#> 3                  NA             NA               NA                    NA
#> 4                  NA             NA               NA                    NA
#> 5                  NA             NA               NA                    NA
#> 6                  NA             NA               NA                    NA
#>   variants.palmyrene variants.pau-cin-hau variants.phags-pa variants.phoenician
#> 1                 NA                   NA                NA                  NA
#> 2                 NA                   NA                NA                  NA
#> 3                 NA                   NA                NA                  NA
#> 4                 NA                   NA                NA                  NA
#> 5                 NA                   NA                NA                  NA
#> 6                 NA                   NA                NA                  NA
#>   variants.psalter-pahlavi variants.rejang variants.runic variants.samaritan
#> 1                       NA              NA             NA                 NA
#> 2                       NA              NA             NA                 NA
#> 3                       NA              NA             NA                 NA
#> 4                       NA              NA             NA                 NA
#> 5                       NA              NA             NA                 NA
#> 6                       NA              NA             NA                 NA
#>   variants.saurashtra variants.sharada variants.shavian variants.siddham
#> 1                  NA               NA               NA               NA
#> 2                  NA               NA               NA               NA
#> 3                  NA               NA               NA               NA
#> 4                  NA               NA               NA               NA
#> 5                  NA               NA               NA               NA
#> 6                  NA               NA               NA               NA
#>   variants.signwriting variants.sogdian variants.sora-sompeng variants.soyombo
#> 1                   NA               NA                    NA               NA
#> 2                   NA               NA                    NA               NA
#> 3                   NA               NA                    NA               NA
#> 4                   NA               NA                    NA               NA
#> 5                   NA               NA                    NA               NA
#> 6                   NA               NA                    NA               NA
#>   variants.sundanese variants.syloti-nagri variants.braille variants.syriac
#> 1                 NA                    NA               NA              NA
#> 2                 NA                    NA               NA              NA
#> 3                 NA                    NA               NA              NA
#> 4                 NA                    NA               NA              NA
#> 5                 NA                    NA               NA              NA
#> 6                 NA                    NA               NA              NA
#>   variants.tagalog variants.tagbanwa variants.tai-le variants.tai-tham
#> 1               NA                NA              NA                NA
#> 2               NA                NA              NA                NA
#> 3               NA                NA              NA                NA
#> 4               NA                NA              NA                NA
#> 5               NA                NA              NA                NA
#> 6               NA                NA              NA                NA
#>   variants.tai-viet variants.takri variants.tamil-supplement variants.tangsa
#> 1                NA             NA                        NA              NA
#> 2                NA             NA                        NA              NA
#> 3                NA             NA                        NA              NA
#> 4                NA             NA                        NA              NA
#> 5                NA             NA                        NA              NA
#> 6                NA             NA                        NA              NA
#>   variants.chinese-traditional variants.thaana variants.tirhuta
#> 1                           NA              NA               NA
#> 2                           NA              NA               NA
#> 3                           NA              NA               NA
#> 4                           NA              NA               NA
#> 5                           NA              NA               NA
#> 6                           NA              NA               NA
#>   variants.ugaritic variants.vai variants.vithkuqi variants.wancho
#> 1                NA           NA                NA              NA
#> 2                NA           NA                NA              NA
#> 3                NA           NA                NA              NA
#> 4                NA           NA                NA              NA
#> 5                NA           NA                NA              NA
#> 6                NA           NA                NA              NA
#>   variants.warang-citi variants.yi variants.zanabazar-square variants.ahom
#> 1                   NA          NA                        NA            NA
#> 2                   NA          NA                        NA            NA
#> 3                   NA          NA                        NA            NA
#> 4                   NA          NA                        NA            NA
#> 5                   NA          NA                        NA            NA
#> 6                   NA          NA                        NA            NA
#>   variants.dogra variants.khitan-small-script variants.makasar
#> 1             NA                           NA               NA
#> 2             NA                           NA               NA
#> 3             NA                           NA               NA
#> 4             NA                           NA               NA
#> 5             NA                           NA               NA
#> 6             NA                           NA               NA
#>   variants.nyiakeng-puachue-hmong variants.old-uyghur
#> 1                              NA                  NA
#> 2                              NA                  NA
#> 3                              NA                  NA
#> 4                              NA                  NA
#> 5                              NA                  NA
#> 6                              NA                  NA
#>   variants.ottoman-siyaq-numbers variants.tangut variants.toto variants.yezidi
#> 1                             NA              NA            NA              NA
#> 2                             NA              NA            NA              NA
#> 3                             NA              NA            NA              NA
#> 4                             NA              NA            NA              NA
#> 5                             NA              NA            NA              NA
#> 6                             NA              NA            NA              NA
#>   variants.znamenny                 weights         styles defSubset isVariable
#> 1                NA                     400 italic, normal     latin      FALSE
#> 2                NA                     400         normal     latin      FALSE
#> 3                NA 400, 500, 600, 700, 800         normal     latin      FALSE
#> 4                NA                     400         normal     latin      FALSE
#> 5                NA                     400         normal     latin      FALSE
#> 6                NA                     400         normal     latin      FALSE
#>                                             url
#> 1        https://fonts.bunny.net/family/abeezee
#> 2           https://fonts.bunny.net/family/abel
#> 3   https://fonts.bunny.net/family/abhaya-libre
#> 4        https://fonts.bunny.net/family/aboreto
#> 5  https://fonts.bunny.net/family/abril-fatface
#> 6 https://fonts.bunny.net/family/abyssinica-sil

# See how many fonts are in each category
table(fonts$category)
#> 
#>     display handwriting   monospace  sans-serif       serif 
#>         460         286          41         617         324 
```
