var babelify = require('babelify');
var babel = require('gulp-babel');

module.exports = function (Parched) {
  Parched.createPlugin({
    displayName: 'parched-babel',
    src: '*.js',

    getDefaultOptions: function () {
      return {
        stage: 0,
      }
    },

    //modifyBundleOptions: function (bundleOptions) {
      //bundleOptions.extensions.push('.jsx')
    //},

    modifyBrowserifyObject: function (b) {
      b.transform(babelify.configure(this.options));
    },

    transform: function () {
      return babel(this.options);
    }
  })
}
