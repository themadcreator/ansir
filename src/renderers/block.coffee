chroma = require 'chroma-js'
ansi   = require '../ansi-codes'
Octree = require '../octree'

class ColorTable
  constructor : () ->
    @tree = new Octree()
    for ansiCode in CONFIG.ansiCodes
      @tree.insert new Octree.Point(ansiCode.color.lab()...), ansiCode

  # Finds the nearest color by using euclidean distance in CIELAB colorspace.
  # We insert all the colors in the color table into an octree so that nearest
  # neighbor searches are very fast.
  getNearest : (color) ->
    if color.alpha() < CONFIG.alphaCutoff then return null
    return @tree.nearest(new Octree.Point(color.lab()...)).value.bg

CONFIG = null
render = (image, config) ->
  CONFIG = config
  colorTable = new ColorTable()

  for y in [0..image.height]
    line = []
    for x in [0..image.width]
      color = colorTable.getNearest(image.colorAt(x, y))
      line.push {
        char : '\u0020'
        fg   : null
        bg   : color
      }
    process.stdout.write ansi.joinLineEscapes(line) + '\n'
  process.stdout.write ansi.ANSI_RESET
  return

module.exports = {render}