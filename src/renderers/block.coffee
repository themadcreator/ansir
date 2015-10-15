chroma = require 'chroma-js'
ansi   = require '../ansi-codes'
Octree = require '../octree'

class ColorTable
  constructor : (@config) ->
    @tree = new Octree()
    for ansiCode in @config.ansiCodes
      @tree.insert new Octree.Point(ansiCode.color.lab()...), ansiCode

  # Finds the nearest color by using euclidean distance in CIELAB colorspace.
  # We insert all the colors in the color table into an octree so that nearest
  # neighbor searches are very fast.
  getNearest : (color) ->
    if color.alpha() < @config.alphaCutoff then return null
    return @tree.nearest(new Octree.Point(color.lab()...)).value.bg

render = (image, config) ->
  colorTable = new ColorTable(config)

  for y in [0..image.height]
    line = []
    for x in [0..image.width]
      color = colorTable.getNearest(image.colorAt(x, y))
      line.push {
        char : '\u0020'
        fg   : null
        bg   : color
      }
    config.write ansi.joinLineEscapes(line) + '\n'
  config.write ansi.ANSI_RESET
  return

module.exports = {render}