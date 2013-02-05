var health  = require('../');

var port = 6379;
var host = '127.0.0.1';

exports['test redis ok'] = function (test) {
  var redis = health.redis({});
  redis(#(err){
    test.ok(!err); 
    test.done();
  });
}

exports['test redis not ok'] = function (test) {
  var options = {
    host: host,
    port: port + 1
  };
  var redis = health.redis(options);
  redis(#(err){
    test.ok(err); 
    test.done();
  });
}
