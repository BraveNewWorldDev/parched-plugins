var envify = require('envify')
var envifyCustom = require('envify/custom')

module.exports = function (Parched) {
  Parched.createPlugin({
    displayName: 'parched-envify',
    src: '!*',
    modifyBrowserifyObject: function (b) {
      if (Object.keys(this.options).length) {
        b.transform(envifyCustom(this.options))
      } else {
        b.transform(envify)
      }
    }
  })
}
