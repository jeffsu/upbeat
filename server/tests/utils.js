var http   = require('http');
var upbeat = require('../index');

module.exports.unhealthySensor = function (cb) {
  var PORT = 2100;
  var server = http.createServer(function (req, res) {
    res.end('hello');
  });

  server.listen(PORT);

  var sensor = new upbeat.Sensor({ strategy: 'http', url: 'http://localhost:' + PORT, interval: 500 });
  sensor.run();

  var count = { beat: 0, pass: 0, fail: 0, up: 0, down: 0 };

  sensor.on('beat', function () { count.beat++; });
  sensor.on('pass', function () { count.pass++; });
  sensor.on('fail', function () { count.fail++; });
  sensor.on('up',   function () { count.up++; });
  sensor.on('down', function () { count.down++; });

  setTimeout(function () {
    server.close();
  }, 1000);

  setTimeout(function () {
    sensor.pause();
    cb(count);
  }, 2000);
}

module.exports.healthySensor = function (cb) {
  var PORT = 2100;
  var server = http.createServer(function (req, res) {
    res.end('hello');
  });

  server.listen(PORT);

  var sensor = new upbeat.Sensor({ strategy: 'http', url: 'http://localhost:' + PORT, interval: 500 });
  sensor.run();

  var count = { beat: 0, pass: 0, fail: 0, up: 0, down: 0 };

  sensor.on('beat', function () { count.beat++; });
  sensor.on('pass', function () { count.pass++; });
  sensor.on('fail', function () { count.fail++; });
  sensor.on('up',   function () { count.up++; });
  sensor.on('down', function () { count.down++; });

  setTimeout(function () {
    sensor.pause();
    server.close();
    cb(count);
  }, 2000);
}
