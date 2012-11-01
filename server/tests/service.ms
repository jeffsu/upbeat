var utils = require('./utils');
var upbeat = require('../');

exports['test service'] = function (test) {
  var service = new upbeat.Service('stuff');
  var sensor  = new upbeat.Sensor({ strategy: 'http', url: 'http://www.google.com', interval: 500 });

  service.addSensor('stuff', sensor);
  service.run();
  setTimeout(function () {
    service.pause();
    test.ok(service.getHealth());
    test.done();
  }, 1000);
}

exports['test service not healthy'] = function (test) {
  var service = new upbeat.Service('stuff');
  service.addSensor('google', new upbeat.Sensor({ strategy: 'http', url: 'http://www.google.com', interval: 500 }));
  service.addSensor('broken', new upbeat.Sensor({ strategy: 'http', url: 'http://localhost:22', interval: 500 }));
  service.run();

  setTimeout(function () {
    service.pause();
    test.ok(!service.getHealth());
    test.done();
  }, 1000);
}

