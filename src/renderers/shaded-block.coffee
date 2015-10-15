chroma = require 'chroma-js'
ansi   = require '../ansi-codes'
Octree = require '../octree'

class ColorTable
  @UTF8_SHADED_BLOCK_CHARS : [
    '\u2591' # ░ LIGHT SHADE
    '\u2592' # ▒ MEDIUM SHADE
    '\u2593' # ▓ DARK SHADE
    '\u2588' # █ FULL BLOCK
  ]

  constructor : (@config) ->
    @tree = new Octree()
    for ansiCode in @config.ansiCodes
      for blockChar, i in ColorTable.UTF8_SHADED_BLOCK_CHARS
        opacity = (i + 1) / 4.0
        color = chroma.mix(@config.terminalBackground, ansiCode.color, opacity, 'hsl')
        entry = {
          blockChar
          ansiCode
        }
        @tree.insert new Octree.Point(color.lab()...), entry
    return

  # Finds the nearest color by using euclidean distance in CIELAB colorspace.
  # We insert all the colors in the color table into an octree so that nearest
  # neighbor searches are very fast.
  getNearest : (color) ->
    if color.alpha() < @config.alphaCutoff then return null
    return @tree.nearest(new Octree.Point(color.lab()...)).value

render = (image, config) ->
  colorTable = new ColorTable(config)

  for y in [0..image.height]
    line = []
    for x in [0..image.width]
      nearest = colorTable.getNearest(image.colorAt(x, y))
      if nearest?
        line.push {
          char : nearest.blockChar
          fg   : nearest.ansiCode.fg
          bg   : null
        }
      else
        line.push {
          char : '\u0020'
          fg   : null
          bg   : null
        }

    config.write ansi.joinLineEscapes(line) + '\n'
  config.write ansi.ANSI_RESET
  return

module.exports = {render}