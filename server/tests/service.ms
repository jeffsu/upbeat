var utils = require('./utils');
var upbeat = require('../');

exports['test service'] = function (test) {
  var service = new upbeat.Service();
  var sensor  = service.sensor('google-http', { strategy: 'http', url: 'http://www.google.com', interval: 500 });
  service.start();

  setTimeout(function () {
    service.stop();
    test.ok(service.isHealthy());
    test.done();
  }, 1000);
}

exports['test service not healthy'] = function (test) {
  var service = new upbeat.Service('stuff');
  service.sensor('google', { strategy: 'http', url: 'http://www.google.com', interval: 500 });
  service.sensor('broken', { strategy: 'http', url: 'http://localhost:22', interval: 500 });
  service.start();

  setTimeout(function () {
    service.stop();
    test.ok(!service.isHealthy());
    test.done();
  }, 1000);
}
