_      = require 'lodash'
chroma = require 'chroma-js'
ansi   = require '../ansi-codes'
Octree = require '../octree'

class SubBlockColorTable
  @UTF8_SUB_BLOCK_CHARS : [
    '\u2598' # ▘ QUADRANT UPPER LEFT
    '\u259D' # ▝ QUADRANT UPPER RIGHT
    '\u2596' # ▖ QUADRANT LOWER LEFT
    '\u2597' # ▗ QUADRANT LOWER RIGHT
    '\u259A' # ▚ QUADRANT UPPER LEFT AND LOWER RIGHT
    '\u259E' # ▞ QUADRANT UPPER RIGHT AND LOWER LEFT
    '\u2588' # █ FULL BLOCK
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

    # Compare to transparent
    transparentDistance = @getTransparentDistance(colors)
    if transparentDistance is 0
      return {
        distance : transparentDistance
        value    : null
      }

    # Rescale distance
    return nearest

  ###
  Finds the best foreground/background match to the four pixel block.

  Pixel layout:
    [p0][p1]
    [p2][p3]
  ###
  getNearest : ([p0, p1, p2, p3]) ->
    candidates = [
      char  : '\u0020'
      fg    :
        distance : @getTransparentDistance([p0, p1, p2, p3])
        value    : null
      bg    :
        distance : 0
        value    : null
    ,
      char : SubBlockColorTable.UTF8_SUB_BLOCK_CHARS[0]
      fg   : @getNearestColor([p0])
      bg   : @getNearestColor([p1, p2, p3])
    ,
      char : SubBlockColorTable.UTF8_SUB_BLOCK_CHARS[1]
      fg   : @getNearestColor([p1])
      bg   : @getNearestColor([p0, p2, p3])
    ,
      char : SubBlockColorTable.UTF8_SUB_BLOCK_CHARS[2]
      fg   : @getNearestColor([p2])
      bg   : @getNearestColor([p0, p1, p3])
    ,
      char : SubBlockColorTable.UTF8_SUB_BLOCK_CHARS[3]
      fg   : @getNearestColor([p3])
      bg   : @getNearestColor([p0, p1, p2])
    ,
      char : SubBlockColorTable.UTF8_SUB_BLOCK_CHARS[4]
      fg   : @getNearestColor([p0, p3])
      bg   : @getNearestColor([p1, p2])
    ,
      char : SubBlockColorTable.UTF8_SUB_BLOCK_CHARS[5]
      fg   : @getNearestColor([p1, p2])
      bg   : @getNearestColor([p0, p3])
    ]

    best = _.min(candidates, (c) -> c.fg.distance + c.bg.distance)
    return {
      fg   : best.fg.value?.fg
      bg   : best.bg.value?.bg
      char : best.char
    }

render = (image, config) ->
  colorTable = new SubBlockColorTable(config)

  # Since we go by 2, we have to end on an even index
  maxX = image.width - (image.width % 2)
  maxY = image.height - (image.height % 2)
  for y in [0...maxY] by 2
    line = []
    for x in [0...maxX] by 2
      pixels = [
        image.colorAt(x, y)
        image.colorAt(x + 1, y)
        image.colorAt(x, y + 1)
        image.colorAt(x + 1, y + 1)
      ]
      line.push colorTable.getNearest(pixels)

    config.write ansi.joinLineEscapes(line) + '\n'
  config.write ansi.ANSI_RESET
  return

module.exports = {render}