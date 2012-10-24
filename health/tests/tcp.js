var health  = require('../');

var net = require('net');
var server = net.createServer(function (c) {
  setTimeout(function () { c.end() }, 1000);
}).listen(4023);

setTimeout(function () { server.close() }, 2000);

exports['test tcp not ok'] = function (test, assert) {
  var tcp = health.tcp("127.0.0.1:65");
  tcp(function (err) { 
    assert.ok(err); 
    test.finish();
  });
};

exports['test tcp ok'] = function (test, assert) {
  var tcp = health.tcp({ host: 'www.google.com', port: 80, timeout: 10000 });
  tcp(function (err) { 
    assert.ok(!err); 
    test.finish();
  });
};

exports['test tcp timeout'] = function (test, assert) {
  var tcp = health.tcp({ host: 'www.google.com', port: 80, timeout: 1 });
  tcp(function (err) { 
    assert.equal(err, 'timeout');
    test.finish();
  });
};
