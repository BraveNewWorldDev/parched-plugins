Fs = require 'fs'
Path = require 'path'
Eco = require 'eco'


module.exports = class CSSBuilder
  supportedStates: ['hover', 'target', 'active', 'focus']
  supportedPreprocessors: ['css', 'sass', 'scss']

  constructor: (@optionsClone, @done) ->
  allDone: ->
    @done? arguments...

  build: ->
    Fs.writeFileSync @optionsClone.outputCSS, @compiled(), 'utf8'
    @allDone()

  templateData: ->
    result = {
      cssClassPrefix: @optionsClone.cssClassPrefix
      usePlaceholderSelectors: @optionsClone.usePlaceholderSelectors
      spriteMap: @normalizeSpriteMap 'spriteMap'
      spriteMap2x: @normalizeSpriteMap 'spriteMap2x'
    }

    result.leader = if @preprocessor() is 'css'
      '.'
    else
      if @optionsClone.usePlaceholderSelectors then '%' else '.'

    result.baseclasses = for key, val of result.spriteMap.coordinates
      ".#{result.cssClassPrefix}-#{key}"

    result.baseclasses2x = for key, val of result.spriteMap2x.coordinates
      ".#{result.cssClassPrefix}-#{key}"

    result.baseclasses_joined = result.baseclasses.join ', '
    result.baseclasses2x_joined = result.baseclasses2x.join ', '

    result

  compiled: ->
    templateData = @templateData()
    templateData.halved = (n) -> Math.ceil n / 2

    templatePath = @templatePath @preprocessor()
    templateContents = Fs.readFileSync templatePath, 'utf8'

    compiled = Eco.render templateContents, templateData
    compiled.replace(/(\r?\n){2,}/g, "\n\n").trim()

  templatePath: (template) ->
    relative = Path.join __dirname, '..', 'templates', "template.#{template}.eco"
    Path.normalize relative

  preprocessor: ->
    outputCSS = @optionsClone.outputCSS
    for processor in @supportedPreprocessors
      if ///\.#{processor}$///.test outputCSS
        return processor

    throw new Error "Svg2PngSprite doesn't know how to write `#{outputCSS}`"

  normalizeSpriteMap: (mapName) ->
    spriteMap = @optionsClone[mapName]
    spriteMap.httpPath = @normalizeHttpPath spriteMap.fileName

    spriteMap.width = spriteMap.properties.width
    spriteMap.height = spriteMap.properties.height
    delete spriteMap.properties

    newCoords = {}
    oldCoords = spriteMap.coordinates
    delete spriteMap.coordinates

    for fileName, coords of oldCoords
      newFileName = @normalizeFileName fileName
      spriteIsState = false

      for stateName in @supportedStates
        stateRegex = ///-#{stateName}///
        if stateRegex.test newFileName
          spriteIsState = true
          basename = newFileName.replace stateRegex, ''
          newCoords[basename] ?= {}
          newCoords[basename][stateName] = coords

      continue if spriteIsState

      newCoords[newFileName] ?= {}
      for prop in ['x', 'y', 'width', 'height']
        newCoords[newFileName][prop] = coords[prop]

    spriteMap.coordinates = newCoords
    spriteMap

  normalizeFileName: (fileName) ->
    fileName
      .replace 'tmp/parched-svg2png/', ''
      .replace '.png', ''
      .replace '/', '_'
      .replace '-2x', ''

  normalizeHttpPath: (filename) ->
    basename = Path.basename filename
    @optionsClone.httpImagesPath + basename

