var Sensor = require('../lib/sensor');
var assert = require('assert');

var called = 0;
var fails  = 0;
var passes = 0;
var changes = 0;
var checks  = 0;
var ups     = 0;
var downs   = 0;

var sensor = new Sensor({
  strategy: #(cb) { 
    called++;
    cb(called > 5) 
  },
  interval: 100
});

sensor.on('check', #{ checks++ });
sensor.on('fail', #{ fails++ });
sensor.on('pass', #{ passes++ });
sensor.on('change', #{ changes++ });
sensor.on('up', #{ ups++ });
sensor.on('down', #{ downs++ });

sensor.run();
setTimeout(#{ 
  assert.ok(checks >= 10);
  assert.ok(fails >= 5);
  assert.equal(passes, 5);
  assert.equal(ups, 1);
  assert.equal(downs, 1);
  assert.equal(changes, 2);
}, 1010);
