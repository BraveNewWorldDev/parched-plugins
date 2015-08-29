SpriteBuilder = require './sprite-builder'
CSSBuilder = require './css-builder'


module.exports = (Parched) ->
  Parched.createPlugin {
    displayName: 'parched-svg2png'
    src: '*.svg'
    # TODO evntually handle raster files ...
    #src: ['*.svg', '*.png', '*.jpg', '*.jpeg']

    shouldProcessAssets: ->
      true

    getDefaultOptions: ->
      src: 'sprites/**/*.svg'
      #outputCSS: 'app/styles/sprites.css'
      #outputImage: 'public/images/sprite-map.png'
      usePlaceholderSelectors: true
      cssClassPrefix: 's'
      httpImagesPath: '/images/'

    transform: (context) ->
      optionsClone = Parched.vendor.xtend {}, @options
      optionsClone.taskNameUnique = context.taskNameUnique

      # Support parched-tasks-webapp bundles
      if context.bundleName
        outputCSS = optionsClone.outputCSS || 'styles/sprites.css'
        outputImage = optionsClone.outputImage || 'images/sprite-map.png'
        optionsClone.outputCSS = "#{context.bundleSrc}/#{outputCSS}"
        optionsClone.outputImage = "#{context.bundleDest}/#{outputImage}"
      else
        optionsClone.outputCSS ?= "app/styles/sprites.css"
        optionsClone.outputImage ?= "public/images/sprite-map.png"

      if typeof optionsClone.httpImagesPath is 'function'
        optionsClone.httpImagesPath = optionsClone.httpImagesPath(optionsClone)

      @processManyFiles optionsClone.src, context,
          @buildEverything(optionsClone)

    buildEverything: (optionsClone) -> (files, done) ->
      optionsClone.files = files

      cssBuilder = new CSSBuilder optionsClone
      cssBuilder.done = done

      spriteBuilder = new SpriteBuilder optionsClone
      spriteBuilder.done = (err) ->
        if err
          return done(err)

        cssBuilder.build()

      spriteBuilder.build()
  }
