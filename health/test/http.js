var health  = require('../');

exports['test http not ok'] = function (test, assert) {
  var http = health.http("http://adsfadsf.adsfasfd.com:3000");
  http(function (err) { 
    assert.ok(err); 
    test.finish();
  });
};

exports['test http ok'] = function (test, assert) {
  var http = health.http("http://www.google.com");
  http(function (err) { 
    assert.ok(!err); 
    test.finish();
  });
};
