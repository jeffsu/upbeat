require('js-yaml');
require('mochiscript');

var upbeat  = require('./lib/upbeat');

var file = "./examples/simple.yml";

var config = require(file)[0];
var configurer = new upbeat.Configurer();
var server = new upbeat.Server(config);
configurer.configure(config, server);

server.start();
server.listen();
