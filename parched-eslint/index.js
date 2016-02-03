var eslint = require('gulp-eslint')

module.exports = function (Parched) {
  // Seems the maintainers really don't want "treat warnings as errors"
  // functionality
  // https://github.com/eslint/eslint/issues/2309
  function failAfterWarning () {
    return eslint.results(function(results) {
      var count = results.warningCount
      if (count > 0) {
        throw new Parched.vendor.gutil.PluginError(
          'gulp-eslint',
          {
            name: 'ESLintError',
            message: 'Failed with ' + count + (count === 1 ? ' warning' : ' warnings')
          }
        )
      }
    })
  }

  Parched.createPlugin({
    displayName: 'parched-eslint',
    src: [
      '*.js',
      '*.jsx',
    ],

    getDefaultOptions: function () {
      return {
        shouldFailOnWarning: false,
      }
    },

    lint: function () {
      var stream = [
        eslint(this.options),
        eslint.format(),
      ]

      if (this.isProduction()) {
        stream.push(eslint.failAfterError())
        if (this.options.shouldFailOnWarning) {
          stream.push(failAfterWarning())
        }
      }

      return stream
    }
  })
}

module.exports.eslint = eslint
