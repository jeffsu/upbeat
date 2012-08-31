var tempo = require('tempo');

// TODO expand this out into other classes
export class Stats {
  private {
    var HOUR = 1000 * 60 * 60;
  }

  function initialize(config) {
    this.config = config || {};

    this.min  = tempo.min();
    this.hour = tempo.hour();
    this.day  = tempo.day();
    this.week = new tempo.TimedCounter({ per: HOUR * 4, buckets: 7 * 6 });
  }

  function inc(name, n) {
    this.min.inc(name, n);
    this.hour.inc(name, n);
    this.day.inc(name, n);
    this.week.inc(name, n);
  }

  function sync(redis, name, cb) {
    var n = 3;

    function onFin() {
      if (--n == 0 && cb) cb();
    }

    this.min.sync(redis, name + ':min', onFin);
    this.hour.sync(redis, name + ':hour', onFin);
    this.day.sync(redis, name + ':day', onFin);
    this.week.sync(redis, name + ':week', onFin);
  }

  function getData(time) {
    var tempo = this.getTempo(time);

    if (this.config.strategy == 'counter') {
      return this.counter(tempo);
    } else if (this.config.strategy == 'average') {
      return this.average(tempo);
    } else if (this.config.strategy == 'sensor') {
      return this.sensor(tempo);
    }
  }

  function sensor(tempo) {
    return {
      response: tempo.getAverageHistory('time', 'total'),
      pass:     tempo.getHistory('pass'),
      fail:     tempo.getHistory('fail')
    };
  }

  function average(tempo) {
    return { average: tempo.getAverageHistory('sum', 'count') };
  }

  function counter(tempo) {
    var ret = {};
    foreach (var key in tempo.getKeys()) {
      ret[key] = tempo.getHistory(key);
    }
    return ret;
  }

  function getTempo(time) {
    return this[time];
  }
}

