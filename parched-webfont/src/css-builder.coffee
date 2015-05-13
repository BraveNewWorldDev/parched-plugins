Fs = require 'fs'
Path = require 'path'
Eco = require 'eco'


module.exports = class CSSBuilder
  supportedStates: ['hover', 'target', 'active', 'focus']
  supportedPreprocessors: ['css', 'sass', 'scss']

  constructor: (@options, @callback) ->
  allDone: -> @callback?()

  build: ->
    Fs.writeFileSync @options.outputCSS, @compiled(), 'utf8'
    @allDone()

  templateData: ->
    ret = @options
    ret.cssClassPrefix = @options.cssClassPrefix
    ret.usePlaceholderSelectors = @options.usePlaceholderSelectors

    ret.leader = if @preprocessor() is 'css'
      '.'
    else
      if @options.usePlaceholderSelectors then '%' else '.'

    ret.baseclasses = for key of @options.codepoints
      ".#{ret.cssClassPrefix}-#{key}"

    ret.baseclassesJoined = ret.baseclasses.join ', '

    ret

  compiled: ->
    templateData = @templateData()
    templateData.halved = (n) -> Math.ceil n / 2

    templatePath = @templatePath @preprocessor()
    templateContents = Fs.readFileSync templatePath, 'utf8'

    compiled = Eco.render templateContents, templateData
    compiled.replace(/(\r?\n){2,}/g, "\n\n").trim()

  templatePath: (template) ->
    relative = Path.join __dirname, '..',
        'templates', "template.#{template}.eco"
    Path.normalize relative

  preprocessor: ->
    outputCSS = @options.outputCSS
    for processor in @supportedPreprocessors
      if ///\.#{processor}$///.test outputCSS
        return processor

    throw new Error "Svg2PngSprite doesn't know how to write `#{outputCSS}`"
