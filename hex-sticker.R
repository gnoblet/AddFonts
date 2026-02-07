# Load required packages
library(ggplot2)
library(showtext)
library(AddFonts)
library(hexSticker)


# Download and register various fonts using AddFonts
fonts <- c(
  "oswald",
  "blaka-ink",
  "barrio",
  "major-mono-display",
  "merriweather",
  "montserrat",
  "sixtyfour",
  "playfair-display",
  "inter",
  "aboreto",
  "aclonica",
  "akronim",
  "babylonica"
)

for (font in fonts) {
  add_font(font)
}

# Plot the sticker design using ggplot2 and hexSticker
showtext_auto()

set.seed(12)
n_fonts <- length(fonts)
angles <- seq(0, 2 * pi, length.out = n_fonts + 1)[1:n_fonts]
radius <- runif(n_fonts, 0.15, 0.45)
font_data <- data.frame(
  x = 0.5 + radius * cos(angles),
  y = 0.57 + radius * sin(angles),
  text = rep("AddFonts", n_fonts),
  font = fonts,
  size = runif(n_fonts, 10, 22),
  angle = runif(n_fonts, -45, 45)
)

p <- ggplot(font_data, aes(x = x, y = y, label = text)) +
  geom_text(
    aes(family = font, size = size, angle = angle),
    hjust = 0.5,
    color = "#170045ff"
  ) +
  annotate(
    "text",
    x = 0.5 + 0.01,
    y = 0.18 - 0.01,
    label = "AddFonts",
    family = "inter",
    size = 32,
    hjust = 0.5,
    vjust = 0.5,
    angle = 0,
    fontface = "bold",
    color = "#ffffffff"
  ) +
  annotate(
    "text",
    x = 0.5,
    y = 0.18,
    label = "AddFonts",
    family = "inter",
    size = 32,
    hjust = 0.5,
    vjust = 0.5,
    angle = 0,
    fontface = "bold",
    color = "#170045ff"
  ) +
  scale_size_identity() +
  coord_equal() +
  xlim(0, 1) +
  ylim(0, 1) +
  theme_void()

sticker(
  p,
  package = "",
  p_size = 20,
  p_family = "inter",
  h_size = 1.8,
  h_color = "#170045ff",
  h_fill = "#e4e6ffff",
  s_x = 1,
  s_y = 1,
  s_width = 1.8,
  s_height = 1.8,
  filename = "man/figures/logo.png",
  dpi = 600
)
