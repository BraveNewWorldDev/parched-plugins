var flow = require('gulp-flowtype');

module.exports = function (Parched) {
  Parched.createPlugin({
    displayName: 'parched-flow',
    src: [
      '*.jsx',
      '*.js'
    ],

    getDefaultOptions: function () {
      return {
        all: true
      }
    },

    lint: function () {
      return flow(this.options);
    }
  })
}
