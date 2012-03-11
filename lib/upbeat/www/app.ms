export class WebServer {
  function initialize(server) {
    this.server = server;
  }

  function start() {
    var app = express.createServer();
    app.configure(#{
      app.set('views', __dirname + '/views');
      app.set('view engine', 'jade');
      app.use(express.bodyParser());
      app.use(express.methodOverride());
      app.use(app.router);
      app.use(express.static(__dirname + '/public'));
      app.use(express.errorHandler({ dumpExceptions: true, showStack: true }));
    });

    require('./routes')(app, this, this.server)
    this.app = app;

    return app;
  }
}
