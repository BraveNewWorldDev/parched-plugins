var hmr = require('browserify-hmr')

module.exports = function (Parched) {
  Parched.createPlugin({
    displayName: 'parched-hmr',
    src: '_',
    modifyBrowserifyObject: function (b) {
      if (!global.isWatching) {
        return
      }
      b.plugin(hmr, this.options)
    }
  })
}
