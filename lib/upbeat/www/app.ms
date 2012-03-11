
export class WebApp {
  function initialize(server) {
    this.server = server;
  }

  function start(port) {
    var express = require('express');
    var app = express.createServer();

    app.configure(#{
      app.set('views', __dirname + '/views');
      app.set('view engine', 'jade');
      app.set('view options', { serer: self.server });
      app.use(express.bodyParser());
      app.use(express.methodOverride());
      app.use(app.router);
      app.use(express.static(__dirname + '/public'));
      app.use(express.errorHandler({ dumpExceptions: true, showStack: true }));
    });

    require('./routes')(app, this.server)
    this.app = app;
    console.log('starting web app on port: ' + port);
    this.app.listen(port);

    return app;
  }

  function stop() {

  }
}
