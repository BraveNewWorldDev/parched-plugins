Path = require 'path'
Fs = require 'fs'

Async = require 'async'
SpriteSmith = require 'spritesmith'
Svg2png = require '../vendor/svg2png'
mkdirp = require 'mkdirp'

JOB_LIMIT = require('os').cpus().length

{ sha1 } = require './util'


module.exports = class SpriteBuilder
  constructor: (@optionsClone, @done) ->
    @images = []
    @images2x = []

  allDone: ->
    @done? arguments...

  build: ->
    Async.parallelLimit @makePngTasks(), JOB_LIMIT, (errPreProcess) =>
      if errPreProcess
        return @allDone(errPreProcess)

      Async.parallelLimit @spritesmithTasks(), JOB_LIMIT, (errSpriteSmith) =>
        if errSpriteSmith
          return @allDone(errSpriteSmith)

        @allDone()

  makePngTasks: ->
    tasks = []
    for file in @optionsClone.files
      tasks.push @makePng file: file.path
      tasks.push @makePng file: file.path, retina: true

    tasks

  spritesmithTasks: ->
    [
      @makeSprite {}
      @makeSprite retina: true
    ]

  makePng: (o) -> (next) =>
    [basename, scale] = @scaleForImage o
    imageCache = @images

    if o.retina
      basename = "#{basename}-2x"
      imageCache = @images2x
      scale = scale * 2

    tmpName = "tmp/parched-svg2png/#{@optionsClone.taskNameUnique}/#{basename}.png"

    Svg2png o.file, tmpName, scale, (err) ->
      imageCache.push tmpName
      next err

  scaleForImage: (o) ->
    basename = Path.basename o.file, '.svg'
    sizeHintMatch = /(_w([0-9]+))/.exec basename

    if sizeHintMatch
      data = Fs.readFileSync o.file, encoding: 'utf-8'
      svgWidthMatch = /<svg(?:.*?)width="([^"]+)"/.exec data
      svgWidth = svgWidthMatch[1].replace 'px', ''
      svgWidth = parseFloat svgWidth
      sizeHint = parseFloat sizeHintMatch[2]

      return [basename.replace(sizeHintMatch[1], ''), sizeHint / svgWidth]

    [basename, 1.0]

  makeSprite: (o) -> (next) =>
    files = @images
    output = @optionsClone.outputImage
    pluginProp = 'spriteMap'

    if o.retina
      files = @images2x
      output = output.replace '.png', '-2x.png'
      pluginProp = "#{pluginProp}2x"

    spritesmithOptions = {
      algorithm: 'binary-tree'
      format: 'png'
      src: files
    }

    SpriteSmith spritesmithOptions, (err, result) =>
      if err
        next err
        return

      uuid = sha1 result.image, 10, 'binary'
      fileName = output.replace '.png', "-#{uuid}.png"
      @optionsClone[pluginProp] = {
        coordinates: result.coordinates
        fileName: fileName
        properties: result.properties
      }

      try
        mkdirp.sync Path.dirname(fileName)
        Fs.writeFileSync fileName, result.image, 'binary'
        next()
      catch e
        next e
