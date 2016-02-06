var autoprefixer = require('gulp-autoprefixer')

module.exports = function (Parched) {
  Parched.createPlugin({
    displayName: 'parched-autoprefixer',
    src: '*.css',
    transform: function () {
      return autoprefixer(this.options)
    }
  })
}
