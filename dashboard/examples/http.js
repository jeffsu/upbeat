var Server = require('upbeat-server').Server;

var server  = new Server();
var service = server.service('google');
var sensor  = service.sensor('http', { strategy: 'http', url: "http://www.google.com" });
server.start();

require('../').setup(server);
