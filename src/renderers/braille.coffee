_      = require 'lodash'
chroma = require 'chroma-js'
ansi   = require '../ansi-codes'
Octree = require '../octree'

class BrailleColorTable
  @UTF8_BRAILLE_MAP : [
    0x1, 0x8
    0x2, 0x10
    0x4, 0x20
    0x40, 0x80
  ]

  constructor : (@config) ->
    @tree = new Octree()
    for ansiCode in @config.ansiCodes
      @tree.insert new Octree.Point(ansiCode.color.lab()...), ansiCode
    return

  getTransparentDistance : (colors) ->
    return colors
      .map((c) => if c.alpha() < @config.alphaCutoff then 0 else 100)
      .reduce((a, b) -> a + b)

  getNearestColor : (colors) ->
    # Get nearest point to CIELAB centroid
    labs    = colors.map((c) -> new Octree.Point(c.lab()...))
    lab     = Octree.Point.centroid(labs)
    nearest = @tree.nearest(lab)
    nearest.distance *= colors.length

    # # Compare to transparent
    # transparentDistance = @getTransparentDistance(colors)
    # if transparentDistance is 0
    #   return {
    #     distance : transparentDistance
    #     value    : null
    #   }

    # Rescale distance
    return nearest

  decodeBrailleOffset : (pixels, offset, invert = false) ->
    return _.filter(pixels, (p, i) ->
      mask = BrailleColorTable.UTF8_BRAILLE_MAP[i]
      return ((offset & mask) is mask) ^ invert
    )

  ###
  Finds the best foreground/background match to the four pixel block.

  Pixel layout:
    [p0][p1]
    [p2][p3]
  ###
  getNearest : (pixels) ->
    candidates = [
      char  : '\u0020'
      fg    :
        distance : @getTransparentDistance(pixels)
        value    : null
      bg    :
        distance : 0
        value    : null
    ]

    for i in [0x40..0xFF]
      offset = 0x2800 + i
      fgPixels = @decodeBrailleOffset(pixels, i, false)
      bgPixels = @decodeBrailleOffset(pixels, i, true)
      candidates.push cand = {
        char : String.fromCharCode(offset)
        fg   : @getNearestColor(fgPixels)
        bg   : @getNearestColor(bgPixels)
      }


    best = _.min(candidates, (c) -> c.fg.distance + c.bg.distance)
    return {
      fg   : best.fg.value?.fg
      bg   : best.bg.value?.bg
      char : best.char
    }

render = (image, config) ->
  colorTable = new BrailleColorTable(config)

  for y in [0...(image.height - 4)] by 4
    line = []
    for x in [0...(image.width - 2)] by 2
      pixels = [
        image.colorAt(x, y)
        image.colorAt(x + 1, y)
        image.colorAt(x, y + 1)
        image.colorAt(x + 1, y + 1)
        image.colorAt(x, y + 2)
        image.colorAt(x + 1, y + 2)
        image.colorAt(x, y + 3)
        image.colorAt(x + 1, y + 3)
      ]
      line.push colorTable.getNearest(pixels)

    config.write ansi.joinLineEscapes(line) + '\n'
  config.write ansi.ANSI_RESET
  return

module.exports = {render, charHeight : 1}