// Generated by CoffeeScript 1.8.0
var uglify;

uglify = require('gulp-uglify');

module.exports = function(P) {
  return P.createPlugin({
    displayName: 'parched-uglify',
    src: '*.js',
    minify: function() {
      return uglify(this.options);
    }
  });
};
