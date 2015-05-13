Crypto = require 'crypto'


sha1 = (input, size, type='utf8') ->
  digest = Crypto
    .createHash 'sha1'
    .update input, type
    .digest 'hex'

  if size?
    digest[0...size]
  else
    digest


module.exports = {
  sha1
}
