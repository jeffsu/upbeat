var utils = require('./utils');
var upbeat = require('../');

exports['test server toHash'] = function (test) {
  var server  = new upbeat.Server();
  var service = server.service("foo");
  var sensor  = service.sensor('bar', { strategy: 'http', url: 'http://www.google.com', interval: 500 });
  server.start();

  setTimeout(function () {
    server.stop();
    var hash = server.toHash();
    test.ok(typeof(hash) == 'object');
    test.ok(Object.keys(hash).length == 1);
    test.ok(hash["foo"]["sensors"]["bar"]["healthy"])
    test.done();
  }, 1000);
}
