var health  = require('../');

exports['test http not ok'] = function (test) {
  var http = health.http("http://adsfadsf.adsfasfd.com:3000");
  http(function (err) { 
    test.ok(err); 
    test.done();
  });
};

exports['test http ok'] = function (test) {
  var http = health.http("http://www.google.com");
  http(function (err) { 
    test.ok(!err); 
    test.done();
  });
};

exports['test http timeout'] = function (test) {
  var http = health.http({ url: "http://www.google.com", timeout: 10 });

  http(function (err) { 
    test.equal(err, 'timeout'); 
    test.done();
  });
};
