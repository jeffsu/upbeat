var health  = require('../');

var net = require('net');
var server = net.createServer(function (c) {
  setTimeout(function () { c.end() }, 1000);
}).listen(4023);

setTimeout(function () { server.close() }, 2000);

exports['test tcp not ok'] = function (test) {
  var tcp = health.tcp("127.0.0.1:65");
  tcp(function (err) { 
    test.ok(err); 
    test.done();
  });
};

exports['test tcp ok'] = function (test) {
  var tcp = health.tcp({ host: 'www.google.com', port: 80, timeout: 10000 });
  tcp(function (err) { 
    test.ok(!err); 
    test.done();
  });
};

exports['test local tcp'] = function (test) {
  var tcp = health.tcp({ host: 'localhost', port: 4023, timeout: 10000 });
  tcp(function (err) { 
    test.ok(!err); 
    test.done();
  });
};

exports['test tcp timeout'] = function (test) {
  var tcp = health.tcp({ host: 'www.google.com', port: 80, timeout: 1 });
  tcp(function (err) { 
    test.equal(err, 'timeout');
    test.done();
  });
};
