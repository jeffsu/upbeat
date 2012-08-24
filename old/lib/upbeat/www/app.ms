

var TIME = {};
TIME.sec  = 1000;
TIME.min  = 60 * TIME.sec;
TIME.hour = 60 * TIME.min;
TIME.day  = 24 * TIME.hour;
TIME.ALL  = [ 'day', 'hour', 'min', 'sec' ];

function humanTime(time) {

  if (time <= 0) return "0 secs";

  var ret = [];

  foreach (var unit in TIME.ALL) {
    var t = TIME[unit];
    var n = Math.floor(time/t);

    if (n > 0) {
      var s = (n > 1) ? 's' : '';
      ret.push(n + ' ' + unit + s);
    }
    time = time % t;
  }

  return ret.join(' ');
}

function percentage(count, total) {
  if (total > 0) {
    return (Math.round(count/total*10000) / 100) + '%';
  } else {
    return '0%';
  }
}

var range = [];
for (var i=0; i<1000; i++) range.push(i);

var categories = { 
  min: {
    text: JSON.stringify('Seconds Ago'),
    data: JSON.stringify(range.slice(0,12).map(#{ => 60 - $1 * 5 }))
  }
};

export class WebApp {

  function initialize(server, config) {
    this.server  = server;
    this.config  = config;
    this.port    = config.port || 2468;
    this.address = config.address;
  }

  function start() {
    var express = require('express');
    var app = express.createServer();

    app.configure(#{
      app.set('views', __dirname + '/views');
      app.set('view engine', 'jade');

      app.set('view options', { 
        server: self.server, 
        humanTime: humanTime,
        percentage: percentage,
        categories: categories
      });

      app.use(express.bodyParser());
      app.use(express.methodOverride());
      app.use(app.router);
      app.use(express.static(__dirname + '/public'));
      app.use(express.errorHandler({ dumpExceptions: true, showStack: true }));
    });

    require('./routes')(app, this.server)
    this.app = app;
    console.log('starting web app on port: ' + this.port);
    this.app.listen(this.port, this.address);

    return app;
  }

  function stop() {

  }
}
