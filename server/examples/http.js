var upbeat = require('../');
var server = new upbeat.Server();

var service = server.service('google');
var sensor  = service.sensor('http', { strategy: 'http', url: 'http://www.google.com' });
server.start();
