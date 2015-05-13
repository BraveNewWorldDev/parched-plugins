var reactify = require('reactify');
var react = require('gulp-react');

module.exports = function (Parched) {
  Parched.createPlugin({
    displayName: 'parched-jsx',
    src: '*.jsx',

    getDefaultOptions: function () {
      return {
        stripTypes: true
      }
    },

    modifyBundleOptions: function (bundleOptions) {
      bundleOptions.extensions.push('.jsx')
    },

    modifyBrowserifyObject: function (b) {
      b.transform(reactify, this.options);
    },

    transform: function () {
      return react(this.options);
    }
  })
}
