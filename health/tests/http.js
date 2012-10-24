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

exports['test http timeout'] = function (test, assert) {
  var http = health.http("http://www.google.com", { timeout: 1 });
  /*
  http(function (err) { 
    assert.equal(err, 'timeout'); 
    test.finish();
  });
  */
  test.finish();
};
