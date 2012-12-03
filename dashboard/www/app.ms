
/**
 * Module dependencies.
 */

module.exports.setup = #(server, options) {
  options = options || {};

  var express = require('express')
    , routes = require('./routes')
    , http = require('http')
    , path = require('path');

  var app = express();

  app.locals.color = #(model) {
    return model.isHealthy() ? 'green' : 'red';
  };

  app.configure(function(){
    app.set('port', options.port || process.env.PORT || 2468);
    app.set('views', __dirname + '/views');
    app.set('view engine', 'jade');
    app.use(express.favicon());
    app.use(express.logger('dev'));
    app.use(express.bodyParser());
    app.use(express.methodOverride());

    app.use(function (req, res, next) {
      res.locals.server = server;
      next();
    });

    app.use(app.router);
    app.use(express.static(path.join(__dirname, 'public')));
  });

  app.configure('development', function(){
    app.use(express.errorHandler());
  });

  require('./routes').setup(server, app);

  http.createServer(app).listen(app.get('port'), function(){
    console.log("Express server listening on port " + app.get('port'));
  });
};
