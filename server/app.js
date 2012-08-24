
/**
 * Module dependencies.
 */

var express = require('express')
  , routes = require('./routes')
  , http = require('http')
  , path = require('path');

var app = express();

app.configure(function(){
  app.set('port', process.env.PORT || 3000);
  app.set('views', __dirname + '/views');
  app.set('view engine', 'jade');
  app.use(express.favicon());
  app.use(express.logger('dev'));
  app.use(express.bodyParser());
  app.use(express.methodOverride());
  app.use(app.router);
  app.use(express.static(path.join(__dirname, 'public')));
});

app.configure('development', function(){
  app.use(express.errorHandler());
});

app.get('/', routes.index);

app.get('/services/:service.:format?', #(req, res, next) {
  res.render('service', { params: req.params, upbeat: upbeat, service: upbeat });
});

app.get('/services/:service/health', #(req, res, next) {
});

app.get('/services/:service/sensors/:sensor', #(req, res, next) {
});

app.get('/services/:service/sensors/:sensor/health', #(req, res, next) {
});

http.createServer(app).listen(app.get('port'), function(){
  console.log("Express server listening on port " + app.get('port'));
});
