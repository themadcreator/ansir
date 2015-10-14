fs      = require 'fs'
{PNG}   = require 'pngjs'
Promise = require 'bluebird'
chroma  = require 'chroma-js'

loadPng = (pngPath) ->
  return new Promise (resolve, reject) ->
    fs.createReadStream(pngPath)
      .pipe(new PNG({filterType : 4}))
      .on('parsed', -> resolve(@))
      .on('error', reject)

createRescaledImage = (png, options) ->
  # default is no scaling
  width  = png.width
  height = png.height
  x      = (i) -> i
  y      = (i) -> i

  if options.scale?
    s      = parseFloat options.scale
    sx     = s * 2 # since block chars are half as wide as tall
    sy     = s
    width  = Math.floor(png.width * sx)
    height = Math.floor(png.height * sy)
    x      = (i) -> Math.floor(i / sx)
    y      = (i) -> Math.floor(i / sy)
  else
    if options.width?
      width = parseInt(options.width)
      x     = (i) -> Math.floor(i * png.width / width)
    if options.height?
      height = parseInt(options.height)
      y      = (i) -> Math.floor(i * png.height / height)

  colorAt = (xi, yi) ->
    idx = (png.width * y(yi) + x(xi)) << 2
    [r,g,b,a] = png.data.slice(idx, idx + 4)
    return chroma([r, g, b]).alpha((a ? 0) / 255.0)

  return {
    width, height, colorAt
  }

module.exports = {
  loadPng
  createRescaledImage
}