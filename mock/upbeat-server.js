require('mochiscript');
require('js-yaml');

var upbeat = require('../lib/upbeat');
var config = require('./example.yml');
var server = new upbeat.Server(config);
server.run();
