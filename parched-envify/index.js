var envify = require('envify')
var envifyCustom = require('envify/custom')

module.exports = function (Parched) {
  Parched.createPlugin({
    displayName: 'parched-envify',
    src: '!*',
    getDefaultOptions: function () {
      return {
        global: true,
      }
    },
    modifyBrowserifyObject: function (b) {
      var transformOpts = { global: this.options.global }

      if (Object.keys(this.options).length) {
        b.transform(envifyCustom(this.options), transformOpts)
      } else {
        b.transform(envify, transformOpts)
      }
    }
  })
}
