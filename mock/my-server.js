var express = require('express');
var upbeat  = require('../lib/upbeat');

var SPEEDS = {
  'slow':    300,
  'fast':    100,
  'average': 200
};

var UPTIME = {
  'perfect': 100,
  'good':    80,
  'average': 50,
  'bad':     30
};

var upbeatClient = new upbeat.Client({ redis: { port: 6379, host: '127.0.0.1' } });
var urls    = upbeatClient.getStats('urls');
var times   = upbeatClient.getStats('response-times');
var success = upbeatClient.getStats('success');

var app = express();
app.configure(function () {
  app.use(express.favicon());
  app.use(express.logger('dev'));
  app.use(app.router);
});

app.get('/:speed/:uptime', function (req, res) {
  var shortest = (SPEEDS[req.params.speed] || SPEEDS.average) - 100;
  var delta    = Math.round(Math.random() * 200);
  var speed    = shortest + delta;

  var st    = (UPTIME[req.params.uptime] || UPTIME.average) >= (Math.random() * 100);

  urls.inc(req.path);
  times.inc('count');
  times.inc('sum', speed);
  success.inc(st ? 'pass' : 'fail');

  setTimeout(function () { 
    res.send(st ? 200 : 500, st ? 'PASSED' : 'FAILED') 
  }, speed);
});

app.listen(3001);
