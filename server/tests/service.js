var utils = require('./utils');
var upbeat = require('../');

exports['test service'] = function (test, assert) {
  var service = new upbeat.Service('stuff');
  var sensor  = new upbeat.Sensor({ strategy: 'http', url: 'http://www.google.com', interval: 500 });

  service.addSensor('stuff', sensor);
  service.run();
  setTimeout(function () {
    service.pause();
    assert.ok(service.getHealth());
    test.finish();
  }, 1000);
}

exports['test service not healthy'] = function (test, assert) {
  var service = new upbeat.Service('stuff');
  service.addSensor('google', new upbeat.Sensor({ strategy: 'http', url: 'http://www.google.com', interval: 500 }));
  service.addSensor('broken', new upbeat.Sensor({ strategy: 'http', url: 'http://localhost:22', interval: 500 }));
  service.run();

  setTimeout(function () {
    service.pause();
    assert.ok(!service.getHealth());
    test.finish();
  }, 1000);
}

