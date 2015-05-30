Path = require 'path'
Svgo = require 'svgo'
Async = require 'async'
Fs = require 'fs'
Mkdirp = require 'mkdirp'
CSSBuilder = require './css-builder'

types = ['eot', 'woff', 'ttf', 'svg']
UNICODE_PUA_START = 0xF101
JOB_LIMIT = require('os').cpus().length

module.exports = (Parched) ->
  Parched.createPlugin {
    displayName: 'parched-webfont'
    src: '*.svg'

    shouldProcessAssets: ->
      true

    getDefaultOptions: ->
      {
        engine: 'node'
        src: 'glyphs/**/*.svg'
        #dest: 'public/fonts'
        #outputCSS: 'app/styles/glyphs.css'
        cssClassPrefix: 'icon'
        svgoOptions: {}
        codepoints: {}
        glyphs: undefined
        usePlaceholderSelectors: true

        fontBaseName: 'icons'
        fontName: 'icons'
        httpFontsPath: 'fonts'
        outputDirectory: 'fonts'
        addHashes: true
        addLigatures: false
        types: types
        order: types
        rename: Path.basename
        autoHint: true
        startCodepoint: UNICODE_PUA_START
        normalize: true
        fontHeight: 512
        descent: 64
        ascent: 448
      }

    transform: (context) ->
      optionsClone = Parched.vendor.xtend true, {}, @options

      # Support parched-tasks-webapp bundles
      if context.bundleName
        outputCSS = optionsClone.outputCSS || 'styles/glyphs.css'
        dest = optionsClone.dest || 'fonts'
        optionsClone.outputCSS = "#{context.bundleSrc}/#{outputCSS}"
        optionsClone.dest = "#{context.bundleDest}/#{dest}"
      else
        optionsClone.outputCSS ?= "app/styles/glyphs.css"
        optionsClone.dest ?= "public/fonts"

      optionsClone.files = []

      @processManyFiles optionsClone.src, context, @__preprocess(optionsClone, context)

    __preprocess: (optionsClone, context) -> (files, done) =>
      optionsClone.done = done
      svgPreprocessTasks = []
      svgoInstance = new Svgo optionsClone.svgoOptions
      tmpDir = "tmp/parched-webfont/#{context.taskNameUnique}"

      for file in files
        svgPreprocessTasks.push do (file) -> (asyncCallback) ->
          svgContents = file.contents.toString()
          svgoInstance.optimize svgContents, (result) ->
            svgBaseName = Path.basename file.path
            tmpFileName = Path.join tmpDir, svgBaseName

            Mkdirp.sync tmpDir
            Fs.writeFileSync tmpFileName, result.data

            optionsClone.files.push tmpFileName
            asyncCallback()

      Async.parallelLimit svgPreprocessTasks, JOB_LIMIT, @__build(optionsClone)

    __build: (optionsClone) -> (err) =>
      if err
        return optionsClone.done(err)

      @__buildGlyphList optionsClone
      @__buildCodepointList optionsClone

      Mkdirp.sync optionsClone.dest

      engine = require "grunt-webfont/tasks/engines/#{optionsClone.engine}"
      engine optionsClone, (data) =>
        if data is false
          return optionsClone.done(new Error("Could not build font using #{optionsClone.engine}"))

        # For whatever reason the node engine is not passing the same arguments
        # to our callback as the fontforge one.
        if typeof data is 'function'
          optionsClone.fontNameWithHash = optionsClone.fontName
          optionsClone.fontName = optionsClone.fontBaseName
        else
          optionsClone.fontNameWithHash = data.fontName

        #optionsClone.done()

        cssBuilder = new CSSBuilder optionsClone, optionsClone.done
        cssBuilder.build()

    __buildGlyphList: (optionsClone) ->
      optionsClone.glyphs ?= for fileName in optionsClone.files
        optionsClone.rename(fileName).replace Path.extname(fileName), ''

      null

    __buildCodepointList: (optionsClone) ->
      for name in optionsClone.glyphs
        optionsClone.codepoints[name] ?= UNICODE_PUA_START++

      null
  }
