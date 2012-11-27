var health = require('../');

exports['test interval'] = function (test) {
  var http = health.http("http://www.google.com");
  var checker = health.checker(http, { interval: 100 });
  checker.start();

  var healthy = 0;
  var beat    = 0;

  checker.on('healthy', function () { healthy++ });
  checker.on('beat', function () { beat++ });

  setTimeout(function () { 
    checker.stop(); 
  }, 600);

  setTimeout(function () {
    test.ok(beat > 2);
    test.equal(healthy, 1);
    test.done();
  }, 1000);
};
