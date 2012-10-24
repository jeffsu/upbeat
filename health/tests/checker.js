var health = require('../');

exports['test interval'] = function (test, assert) {
  var http = health.http("http://www.google.com");
  var checker = health.checker(http, { interval: 100 });
  checker.start();

  var healthy = 0;
  var beat    = 0;

  checker.on('healthy', function () { healthy++ });
  checker.on('beat', function () { beat++ });

  setTimeout(function () { 
    checker.stop(); 
  }, 500);

  setTimeout(function () {
    assert.ok(beat > 2);
    assert.equal(healthy, 1);
    test.finish();
  }, 1000);
};
