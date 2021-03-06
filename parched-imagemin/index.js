var imagemin = require('gulp-imagemin')

module.exports = function (Parched) {
  Parched.createPlugin({
    displayName: 'parched-imagemin',

    src: [
      '*.gif',
      '*.jpg',
      '*.jpeg',
      '*.png',
      '*.svg',
    ],

    shouldProcessAssets: function () {
      return true
    },

    transform: function () {
      if (!Parched.isProduction()) {
        return
      }

      return imagemin(this.options)
    },
  })
}
