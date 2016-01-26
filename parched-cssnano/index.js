var cssnano = require('gulp-cssnano');

module.exports = function(Parched) {
  return Parched.createPlugin({
    displayName: 'parched-cssnano',
    src: '*.css',
    minify: function() {
      return cssnano(this.options);
    }
  });
};
