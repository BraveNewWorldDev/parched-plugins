// Generated by CoffeeScript 1.8.0
var Crypto, sha1;

Crypto = require('crypto');

sha1 = function(input, size, type) {
  var digest;
  if (type == null) {
    type = 'utf8';
  }
  digest = Crypto.createHash('sha1').update(input, type).digest('hex');
  if (size != null) {
    return digest.slice(0, size);
  } else {
    return digest;
  }
};

module.exports = {
  sha1: sha1
};
