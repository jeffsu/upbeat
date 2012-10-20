var health  = require('../');

var http = health.http("http://adsfadsf.adsfasfd.com:3000");
http(function (err) { console.log(err); });

var checker = health.checker(http);
checker.start();
checker.on('error', #{ console.log('error') });
checker.on('error', #{ console.log('error') });
