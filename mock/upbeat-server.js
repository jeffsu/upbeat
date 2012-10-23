require('mochiscript');
require('js-yaml');

require('http').globalAgent.maxSockets = 100;
var upbeat = require('../lib/upbeat');
var config = require('./example.yml');
var server = new upbeat.Server(config);
server.run();
