
/**
 * Module dependencies.
 */

var SUFFIXES = {
  min: 'seconds ago',
  hour: 'minutes ago',
  day:  'hours ago',
  week: 'days ago'
};

var LABELS = {
  min:  [],
  hour: [],
  day:  [],
  week: []
};

for (var i=12; i>0; i--) {
  LABELS.min.push(i * 5);
  LABELS.hour.push(i * 5);
}

for (var i=24; i>0; i--) LABELS.day.push(i);
for (var i=7; i>0; i--) {
  LABELS.week.push(i);
  for (var j=0; j<5; j++) {
    LABELS.week.push('');
  }
}


module.exports = #(server, config) { 

  var express = require('express')
    , routes = require('./routes')
    , http = require('http')
    , jade = require('jade')
    , path = require('path');

  var app = express();

  function getResource(params) {
    if (params.service) {
      var service = server.services[params.service];
      return params.sensor ? service.sensors[params.sensor] : service;
    } else if (params.stats) {
      return server.stats[params.stats];
    }
  }

  var mochi = require('mochiscript').mochi;
  mochi.setupJade(jade);

  app.locals.health = #(passed, up, down) {
    return passed ?
       '<span style="color: green">' + (up || 'up') + '</span>' :
       '<span style="color: red">'   + (down || 'down') + '</span>';
  };

  app.locals.suffixes = SUFFIXES;

  app.configure(function(){
    app.set('port', process.env.PORT || 3000);
    app.set('views', __dirname + '/views');
    app.set('view engine', 'jade');
    app.use(express.favicon());
    app.use(express.logger('dev'));
    app.use(express.bodyParser());
    app.use(express.methodOverride());

    app.use(#(req, res, next) { 
      var locals = res.locals;
      req.query.time = req.query.time || 'min';
      if (!locals) return next();

      locals.server = server;
      locals.services = server.services;
      locals.stats    = server.stats;
      locals.self     = getResource(req);
      locals.path     = req.path;
      locals.query    = req.query;
      locals.body     = req.body;
      next(); 
    });

    app.use(app.router);
    app.use(express.static(path.join(__dirname, 'public')));
  });


  app.configure('development', function(){
    app.use(express.errorHandler());
  });

  app.get('/', #(req, res, next) {
    res.render('index', {});
  });

  // Services
  app.get('/services/:service', #(req, res, next) {
    var params = req.params;
    var query  = req.query;
    res.render('service', { params: req.params, service: getResource(req.params), query: query });
  });

  app.get('/services', #(req, res, next) {
    res.render('services');
  });

  app.get('/services/:service/sensors/:sensor/test', #(req, res, next) {
    res.render('sensor-test', { params: req.params, results: null });
  });

  app.post('/services/:service/sensors/:sensor/test', #(req, res, next) {
    var results = {};
    var sensor  = getResource(req.params);
    var concurrency = parseInt(req.body.concurrency);
    var time = parseInt(req.body.time) * 1000;

    sensor.perf(concurrency, time, #(results) {
      res.render('sensor-test', { params: req.params, results: results });
    });
  });

  app.get('/services/:service/sensors/:sensor.:format?', #(req, res, next) {
    var query = req.query;
    if (req.params.format == 'json') {
      var data = getResource(req.params).getData(query.time);
      data.labels = data.labels || LABELS[query.time];
      res.json(data);
    } else {
      res.render('sensor', { params: req.params, sensor: getResource(req.params), query: query });
    }
  });

  // Stats
  app.get('/stats', #(req, res, next) {
    res.render('stats');
  });

  app.get('/stats/:stats.:format?', #(req, res, next) {
    var time     = req.query.time;
    var stats    = getResource(req.params);
    var strategy = req.query.as || stats.config.strategy;

    if (req.params.format == 'json') {
      var data = stats.getData(time, strategy);
      data.labels = data.labels || LABELS[time];
      res.json(data);
    } else {
      res.render('stats/' + strategy, { config: config, stats: stats, params: req.params });
    }
  });

  app.post('/stats/:stats', #(req, res, next) {
    var stats = getResource(req.params);
    for (var k in req.body) {
      var val = parseInt(req.body[k]);
      if (val > 0) stats.inc(k, val);
    }
    res.send("ok");
  });

  // Health checks
  app.get('/services/:service/sensors/:sensor/health', #(req, res, next) {
    var sensor = getResource(req.params);
    return res.send(sensor.isHealthy ? 200 : 503);
  });

  app.get('/services/:service/health', #(req, res, next) {
    var service = getResource(req.params);
    return res.send(service.isHealthy ? 200 : 503);
  });

  http.createServer(app).listen(app.get('port'), function(){
    console.log("Express server listening on port " + app.get('port'));
  });
};
