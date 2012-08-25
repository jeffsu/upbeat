
/**
 * Module dependencies.
 */

require('js-yaml');
var express = require('express')
  , routes = require('./routes')
  , http = require('http')
  , path = require('path');

var app = express();
var upbeat = require('../lib/upbeat');
var config = require(process.cwd() + '/example.yml');
var server = new upbeat.Server(config);
server.run();

function getResource(params) {
  var service = server.services[params.service];
  return params.sensor ? service.sensors[params.sensor] : service;
}

var mochi = require('mochiscript').mochi;
var jade  = require('jade');
jade.filters.mochi = #(block) {
  return ("<script>" + mochi.parse(block) + "</script>").replace(/#/g, '\\#').replace(/\n/g, '');
};


app.locals.health = #(passed, up, down) {
  return passed ?
     '<span style="color: green">' + (up || 'up') + '</span>' :
     '<span style="color: red">'   + (down || 'down') + '</span>';
};

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

app.get('/', #(req, res, next) {
  res.render('index', { params: req.params, server: server });
});

app.get('/services/:service.:format?', #(req, res, next) {
  if (req.params.format == 'json') {
    res.json(getResource(req.params).getAverageTimes('day'));
  } else {  
    res.render('service', { params: req.params, server: server });
  }
});

app.get('/services/:service/health', #(req, res, next) {
});

app.get('/services/:service/sensors/:sensor.:format?', #(req, res, next) {
  if (req.params.format == 'json') {
    res.json(getResource(req.params).getAverageTimes('min'));
  } else {
    res.render('sensor', { params: req.params, sensor: getResource(req.params) });
  }
});

app.get('/services/:service/sensors/:sensor/health', #(req, res, next) {
});

http.createServer(app).listen(app.get('port'), function(){
  console.log("Express server listening on port " + app.get('port'));
});
