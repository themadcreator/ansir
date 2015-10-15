png       = require './src/png'
configure = require './src/config'
commander = require 'commander'

commander
  .usage('<png>')
  .description('Generate UTF-8 Art from PNG using ANSI color codes.')
  .option('-s, --scale <float>', 'Proportionally rescale image')
  .option('-w, --width <integer>', 'Target output width (in characters)')
  .option('-h, --height <integer>', 'Target output height (in lines)')
  .option('--colors <basic|extended>', '''
\n      The ANSI colorspace. Use "basic" for the most compatible 8-color
    palette. The default is "extended" for the 256-color palette supported by
    most major terminals that have any color at all.''', 'extended')
  .option('--background <light|dark>', '''
\n      Applies only to "shaded" mode. Specifies whether the target terminal
    will have a light or dark background. This determines color matching for
    shaded UTF-8 block characters. Default is "dark", which means we interpret
    a shaded block character as darker than a solid one.''',
    'dark')
  .option('--alpha-cutoff <float>', '''
\n      The minimum alpha value of a pixel that should be converted to a ansi
    color utf-8 block character. Valid values are 0.0-1.0. Default is
    0.95.''', '0.95')
  .option('--mode <block|shaded|sub>', '''
\n      The rendering mode. Default is "block". The options are:

    "block" - Use the ANSI background escape sequence to create seamless blocks.

    "shaded" - Use the ANSI foreground escape sequence on unicode block character.
      ░ LIGHT SHADE
      ▒ MEDIUM SHADE
      ▓ DARK SHADE
      █ FULL BLOCK

    "sub" - Use the ANSI foreground escape sequence on unicode quadrant block
            characters. NOTE: These characters can cause slowness when used
            with some common terminal fonts such as Consolas.
      ▘ QUADRANT UPPER LEFT
      ▝ QUADRANT UPPER RIGHT
      ▖ QUADRANT LOWER LEFT
      ▗ QUADRANT LOWER RIGHT
      ▚ QUADRANT UPPER LEFT AND LOWER RIGHT
      ▞ QUADRANT UPPER RIGHT AND LOWER LEFT
      █ FULL BLOCK

''', 'block')
  .action((pngPath, options) ->
    config = configure(options)
    png.loadPng(options.args[0]).then((pngObj) ->
      image = png.createRescaledImage(pngObj, options)
      config.renderer.render(image, config)
    )
  )

commander.parse(process.argv)
