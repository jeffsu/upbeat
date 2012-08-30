var strategies = require('./strategies');
var tempo      = require('tempo');

export class Sensor {
  include $m.EventEmitter;

  private {
    var TIMEOUT  = 5000;
    var INTERVAL = 5000;
    var PAUSED   = 'paused';
    var SECOND   = 1000;
    var MIN      = SECOND * 60;
    var HOUR     = SECOND * 60;
    var DAY      = HOUR * 24;
    var STACKED  = 5;
  }

  function initialize(options) {
    this.strategy = options.strategy;
    if (typeof this.strategy == 'string') this.strategy = strategies[this.strategy](options);

    this.timeout  = options.timeout  || TIMEOUT;
    this.interval = options.interval || INTERVAL;

    this.fall     = -1 * (options.fall || 1);
    this.up       = options.up || 1;

    this.totalCount = 0; // total requests
    this.passCount  = 0; // total passed requests
    this.failCount  = 0; // total failed requests

    this.downTime = 0;
    this.upTime   = 0;

    this.stacked  = 0; // number of stacked up requests

    this.min  = tempo.min();
    this.hour = tempo.hour();
    this.day  = tempo.day();
    this.week = tempo.week();

    this.status = 'paused';
    this.isHealthy   = null;
    this.healthCount = 0;
    this.lastHealth  = null;

    this.setEvents();
  }

  function getTempo(time) {
    return this[time || 'day'];
  }

  function getAverageTimes(time) {
    var tempo = this.getTempo(time);
    return {
      fail: tempo.getAverageHistory('fail-time', 'fail-count'),
      pass: tempo.getAverageHistory('pass-time', 'pass-count')
    };
  }

  function setEvents() {
    this.on('fail', #(time) {
      self.min.inc("fail-count");
      self.hour.inc("fail-count");
      self.day.inc("fail-count");
      self.week.inc("fail-count");

      self.min.inc("fail-time", time);
      self.hour.inc("fail-time", time);
      self.day.inc("fail-time", time);
      self.week.inc("fail-time", time);
    });

    this.on('pass', #(time) {
      self.min.inc("pass-count");
      self.hour.inc("pass-count");
      self.day.inc("pass-count");
      self.week.inc("pass-count");

      self.min.inc("pass-time", time);
      self.hour.inc("pass-time", time);
      self.day.inc("pass-time", time);
      self.week.inc("pass-time", time);
    });
  }

  function run() {
    if (this.status == 'running') return;
    this.status = 'running';
    this.repeat(0);
  }

  function repeat(timeout) {
    if (this.status == 'running')
      setTimeout(#{ self.check(#{ self.repeat(self.interval) }) }, timeout);
  }

  function pause() {
    this.status = 'paused';
  }

  function respond(err, meta, time, cb) {
    var passed = !err;

    var now = (new Date).getTime();

    this.totalCount++;

    if (passed) {
      this.passCount++;
      this.lastPass = now;
    }

    else {
      this.failCount++;
      this.lastFail = now;
    }

    this.emit(passed ? 'pass' : 'fail', now - time, err || meta);

    if (passed != this.lastHealth) {
      this.healthCount = 0;
    } 
    
    else {
      if (err) this.healthCount--;
      else this.healthCount++;

      // handle changing
      if (this.healthCount == this.fall) {
        this.isHealthy = false;
        this.emit('change', this.isHealthy);
        this.emit('down');
      } 
      
      else if (this.healthCount == this.up) {
        this.isHealthy = true;
        this.emit('change', this.isHealthy);
        this.emit('up');
      }
    }

    this.lastHealth = passed;

    cb(err);
  }

  function check(cb) {
    if (this.stacked > 5) {
      this.isHealthy = false;
      this.emit('message', "Too many requests stacked up with no response");
      return;
    }

    this.emit('check');

    var startTime = (new Date).getTime();
    var stopped   = false;
    this.stacked++;

    setTimeout(#{ 
      if (stopped) return;
      self.respond('timed-out', null, startTime, cb);
      stopped = true;
    }, this.timeout);

    this.strategy(#(err, meta) {
      self.stacked--;
      if (!stopped) self.respond(err, meta, startTime, cb);
      stopped = true;
    });
  }
}
