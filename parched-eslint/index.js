var eslint = require('gulp-eslint')

module.exports = function (Parched) {
  Parched.createPlugin({
    displayName: 'parched-eslint',
    src: [
      '*.js',
      '*.jsx',
    ],

    lint: function () {
      var stream = [
        eslint(this.options),
        eslint.format(),
      ]

      if (this.isProduction()) {
        stream.push(eslint.failAfterError())
      }

      return stream
    }
  })
}

module.exports.eslint = eslint
