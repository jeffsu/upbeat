require('mochiscript');
require('js-yaml');

var upbeat = require('../lib/upbeat');
var config = require('./example.yml');
var server = new upbeat.Server(config);
server.run();
setInterval(function () { 
  var start = (new Date).getTime();
  global.gc() 
  console.log('gc: ' + ((new Date).getTime() - start) + 'ms');
}, 10000);
