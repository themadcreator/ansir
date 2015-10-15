{expect} = require 'chai'
chroma   = require 'chroma-js'
fs       = require 'fs'
api      = require '../ansir-api'

describe 'Renderers', ->

  pngPromise = api.png.loadPng("#{__dirname}/../sample/in.png")

  compareRenderToCanonical = (rendererType, scale) ->
    pngPromise.then((pngObj) ->
      strs   = []
      config =
        ansiCodes          : api.ansi.ANSI_COLORS_EXTENDED
        terminalBackground : chroma('black')
        scale              : scale
        alphaCutoff        : 0.95
        write              : (str) -> strs.push(str)

      # Render using ansir API
      image = png.createRescaledImage(pngObj, config)
      api.renderer[rendererType].render(image, config)

      # Compare output to canonical
      expect(strs.join('')).to.equal(fs.readFileSync("#{__dirname}/renders/#{rendererType}.txt", 'utf8'))
      return
    )

  it '"block" renderer matches canonical', (done) ->
    compareRenderToCanonical('block', 0.05).then(done)

  it '"shaded" renderer matches canonical', (done) ->
    compareRenderToCanonical('shaded', 0.05).then(done)

  it '"sub" renderer matches canonical', (done) ->
    compareRenderToCanonical('sub', 0.1).then(done)