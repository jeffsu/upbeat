var ups = require('upbeat-server');

var server  = new ups.Server();
var service = server.service('google');
var sensor  = service.sensor('http', { strategy: 'http', url: "http://www.google.com" });
server.start();

var store = new ups.Store(server);

require('../').setup(server);
