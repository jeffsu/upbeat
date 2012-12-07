
/**
 * Module dependencies.
 */
var mochi = require('mochiscript');
module.exports.setup = #(server, options) {
  var store = server.store();

  options = options || {};

  var express = require('express')
    , routes = require('./routes')
    , http = require('http')
    , path = require('path');

  var app = express();

  app.locals.color = #(model) {
    return model.isHealthy() ? 'green' : 'red';
  };

  var jade = require('jade');
  jade.filters.mochi = #(text) {
    text = mochi.compile(text).replace(/\\/g, '\\\\').replace(/\n/g, '\\n');
    return "<script type='text/JavaScript'>\\n" + mochi.compile(text) + "</script>";
  };

  app.configure(function(){
    app.set('port', options.port || process.env.PORT || 2468);
    app.set('views', __dirname + '/views');
    app.set('view engine', 'jade');
    app.use(express.favicon());
    app.use(express.logger('dev'));
    app.use(express.bodyParser());
    app.use(express.methodOverride());


    app.use(#(req, res, next) {
      res.locals.server = server;
      next();
    });

    app.use(app.router);
    app.use(express.static(path.join(__dirname, 'public')));

    app.use(mochi.middleware({
      src: path.join(__dirname, "public", "javascripts"),
      prefix: "javascripts"
    }));
  });

  app.configure('development', function(){
    app.use(express.errorHandler());
  });

  require('./routes').setup(server, app);

  http.createServer(app).listen(app.get('port'), function(){
    console.log("Express server listening on port " + app.get('port'));
  });
};
