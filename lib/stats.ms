var tempo = require('tempo');

// TODO expand this out into other classes
export class Stats {
  private {
    var HOUR = 1000 * 60 * 60;
    var TIMES = [ 'min', 'hour', 'day', 'week' ];
  }

  function initialize(config) {
    this.config = config || {};


    this.exclude = config.exclude || {};
    this.min  = tempo.min();
    this.hour = tempo.hour();
    this.day  = tempo.day();
    this.week = new tempo.TimedCounter({ per: HOUR * 4, buckets: 7 * 6 });
  }

  function inc(name, n) {
    foreach (var t in TIMES) 
      if (!this.exclude[t]) this[t].inc(name, n);
  }

  function sync(redis, name, cb) {
    var n = 0;

    function onFin() {
      if (--n == 0 && cb) cb();
    }

    foreach (var t in TIMES) {
      if (!this.exclude[t]) {
        this[t].sync(redis, name + ':' + t, onFin);
        n++;
      }
    }
  }

  function getData(time, as) {
    var tempo = this.getTempo(time);
    var strategy = as || this.config.strategy;

    if (strategy == 'counter') {
      return this.counter(tempo);
    } else if (strategy == 'average') {
      return this.average(tempo);
    } else if (strategy == 'sensor') {
      return this.sensor(tempo);
    } else if (strategy == 'pie') {
      return this.pie(tempo);
    }
  }

  function sensor(tempo) {
    var data = {
      response: tempo.getAverageHistory('time', 'total'),
      pass:     tempo.getHistory('pass'),
      fail:     tempo.getHistory('fail'),
      timeout:  tempo.getHistory('timeout'),
      slow:     tempo.getHistory('slow')
    };

    return { data: data };
  }

  function average(tempo) {
    var data = { average: tempo.getAverageHistory('sum', 'count') };
    return { data: data };
  }

  function pie(tempo) {
    var keys = tempo.getKeys();
    var data = [];
    var labels = [];
    foreach (var k in keys) {
      data.push(tempo.getCount(k));
      labels.push(k);
    }

    return { data: data, labels: labels };
  }

  function counter(tempo) {
    var data = {};
    foreach (var key in tempo.getKeys()) 
      data[key] = tempo.getHistory(key);

    return { data: data };
  }

  function getTempo(time) {
    return this[time];
  }
}

