"use strict";

var path = require("path");
var fs = require("fs");
var execFile = require("child_process").execFile;

function getPhantomjsCmd () {
  try {
    var fromLib = require('phantomjs').path
    if (fromLib) {
      return fromLib
    }
  } catch (e) {
  }

  var paths = [
    '../node_modules/phantomjs/bin/phantomjs',
    '../node_modules/svg2png/node_modules/phantomjs/bin/phantomjs',
  ]

  for (var i = 0; i < paths.length; i++) {
    var potentialPath = path.resolve(__dirname, paths[i])

    // Because `fs.existsSync` is deprecated in Node (wut ???)
    try {
      fs.accessSync(potentialPath, fs.X_OK)
      return potentialPath
    } catch (e) {
    }
  }

}

var phantomjsCmd = getPhantomjsCmd()
var converterFileName = path.resolve(__dirname, "./converter.js");

module.exports = function svgToPng(sourceFileName, destFileName, scale, cb) {
  if (typeof scale === "function") {
    cb = scale;
    scale = 1.0;
  }

  var args = [converterFileName, sourceFileName, destFileName, scale];
  execFile(phantomjsCmd, args, function (err, stdout, stderr) {
    if (err) {
      cb(err);
    } else if (stdout.length > 0) { // PhantomJS always outputs to stdout.
      cb(new Error(stdout.toString().trim()));
    } else if (stderr.length > 0) { // But hey something else might get to stderr.
      cb(new Error(stderr.toString().trim()));
    } else {
      cb(null);
    }
  });
};
