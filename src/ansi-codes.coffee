chroma = require 'chroma-js'

ansiEscape = (code) -> "\x1b[#{code}m"

ANSI_RESET = ansiEscape('0')

ANSI_COLOR_DEFAULT = {
  fg : ansiEscape('39')
  bg : ansiEscape('40')
}

ANSI_COLORS_BASIC = [
  color : chroma('red')
  fg    : ansiEscape('31')
  bg    : ansiEscape('41')
,
  color : chroma('yellow')
  fg    : ansiEscape('33')
  bg    : ansiEscape('43')
,
  color : chroma('green')
  fg    : ansiEscape('32')
  bg    : ansiEscape('42')
,
  color : chroma('cyan')
  fg    : ansiEscape('36')
  bg    : ansiEscape('46')
,
  color : chroma('blue')
  fg    : ansiEscape('34')
  bg    : ansiEscape('44')
,
  color : chroma('magenta')
  fg    : ansiEscape('35')
  bg    : ansiEscape('45')
,
  color : chroma('black')
  fg    : ansiEscape('30')
  bg    : ansiEscape('40')
,
  color : chroma('white')
  fg    : ansiEscape('37')
  bg    : ansiEscape('47')
]

# Convert an extended ANSI color code into its RGB value.
# See: http://stackoverflow.com/questions/27159322/rgb-values-of-the-colors-in-the-ansi-extended-colors-index-17-255
convertAnsiExtended = (code) ->
  if code >= 232
    g = (code - 232) * 10 + 8
    return {
      color : chroma(g, g, g)
      fg    : ansiEscape "38;5;#{code}"
      bg    : ansiEscape "48;5;#{code}"
    }
  else
    r = Math.floor((code - 16) / 36)
    r = if r > 0 then 55 + r * 40 else 0

    g = Math.floor(((code - 16) % 36) / 6)
    g = if g > 0 then 55 + g * 40 else 0

    b = (code - 16) % 6
    b = if b > 0 then 55 + b * 40 else 0

    return {
      color : chroma(r, g, b)
      fg    : ansiEscape "38;5;#{code}"
      bg    : ansiEscape "48;5;#{code}"
    }

ANSI_COLORS_EXTENDED = [16...256].map(convertAnsiExtended)

joinLineEscapes = (line) ->
  lastFg = null
  lastBg = null
  s      = ''

  for pixel in line

    if lastBg isnt pixel.bg or lastFg isnt pixel.fg
      s += ANSI_RESET
      if pixel.bg? then s += pixel.bg
      if pixel.fg? then s += pixel.fg
      lastBg = pixel.bg
      lastFg = pixel.fg

    s += pixel.char

  return s

module.exports = {
  ANSI_RESET
  ANSI_COLOR_DEFAULT
  ANSI_COLORS_BASIC
  ANSI_COLORS_EXTENDED
  joinLineEscapes
}