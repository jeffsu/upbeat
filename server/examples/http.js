var upbeat = require('../');
var server = new upbeat.Server();

var service = new upbeat.Service();
var sensor  = new upbeat.Sensor({
  strategy: 'http',
  url: 'http://www.google.com'
});

service.addSensor('http', sensor);

server.addService('google', sensor);
server.run();
