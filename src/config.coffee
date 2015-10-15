chroma = require 'chroma-js'
ansi   = require './ansi-codes'

configure = (options) ->
  ansiCodes = switch options.colors
    when 'basic'    then ansi.ANSI_COLORS_BASIC
    when 'extended' then ansi.ANSI_COLORS_EXTENDED
    else throw new Error("Unknown ANSI color space #{options.colors}")

  terminalBackground = switch options.background
    when 'light' then chroma('white')
    when 'dark'  then chroma('black')
    else throw new Error("Unknown background option #{options.background}")

  renderer = switch options.mode
    when 'block'  then require './renderers/block'
    when 'shaded' then require './renderers/shaded-block'
    when 'sub'    then require './renderers/sub-block'
    else throw new Error("Unknown mode option #{options.mode}")

  alphaCutoff = parseFloat(options.alphaCutoff)

  write = (str) -> process.stdout.write(str)

  return {
    ansiCodes
    terminalBackground
    alphaCutoff
    renderer
    write
  }


module.exports =configure