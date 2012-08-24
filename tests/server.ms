var server = require('../lib/upbeat').Server.fromConfig({
  services: {
    google: {
      standard: {
        strategy: 'http',
        url: 'https://www.google.com'
      }
    }
  }
});

