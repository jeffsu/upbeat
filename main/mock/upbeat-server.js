require('mochiscript');
require('js-yaml');

var upbeat = require('upbeat-server');
var dash   = require('upbeat-dashboard');

var config = require('./example.yml');
var server = new upbeat.Server(config);
process.nextTick(function () {
  server.run();
  dash.setup(server, config);
});

