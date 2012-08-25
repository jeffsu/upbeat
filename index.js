var upbeat = require('./lib');
var server = upbeat.Server.fromConfig({
  services: {
    google: {
      standard: {
        strategy: 'http',
        url: 'https://www.google.com'
      }
    }
  },
  log: [ 'fail', 'pass' ]
});


server.run();
