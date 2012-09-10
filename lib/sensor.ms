var strategies = require('./strategies');
var tempo      = require('tempo');
var Stats      = require('./stats');

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
    this.options  = options;
    this.strategy = options.strategy;
    if (typeof this.strategy == 'string') this.strategy = strategies[this.strategy](options);

    this.timeout  = options.timeout  || TIMEOUT;
    this.interval = options.interval || INTERVAL;

    this.slow = options.slow;
    this.fast = options.fast;

    this.fall     = -1 * (options.fall || 1);
    this.up       = options.up || 1;

    this.totalCount = 0; // total requests
    this.passCount  = 0; // total passed requests
    this.failCount  = 0; // total failed requests

    this.downTime = 0;
    this.upTime   = 0;
    this.runningTime = 0;

    this.stacked  = 0; // number of stacked up requests

    this.stats = new Stats({ strategy: 'sensor' });

    this.status = 'paused';
    this.isHealthy   = null;
    this.healthCount = 0;
    this.lastHealth  = null;
    this.isSlow      = null;

    this.setEvents();

    this.lastChange = null;
    this.on('change', #(isHealthy) {
      var now = (new Date).getTime();

      if (!self.lastChange) 
        this[isHealthy ? 'uptime' : 'downtime'] += self.lastChange - now;

      self.lastChange = now;
    });
  }

  function sync(time, redis, name, cb) {
    this.stats.syncTime(time, redis, name, cb);
  }

  function getTempo(time) {
    return this.stats.getTempo(time);
  }

  function getData(time) {
    return this.stats.getData(time);
  }

  function setEvents() {
    this.on('fail', #(time) {
      self.lastFailure = (new Date);
      self.stats.inc("fail");
      self.stats.inc("total");
      self.stats.inc("time", time);
    });

    this.on('pass', #(time) {
      self.stats.inc("pass");
      self.stats.inc("total");
      self.stats.inc("time", time);

      self.isSlow = self.slow && time > self.slow;
      if (self.isSlow) self.stats.inc('slow');
      self.isFast = self.fast && time < self.fast;
      if (self.isFast) self.stats.inc('fast');
    });

    this.on('timeout', #{
      self.stats.inc("timeout");
      self.isSlow = true;
      self.stats.inc('slow');
    });
  }

  function run() {
    if (this.status == 'running') return;
    this.status = 'running';

    function repeat() {
      self.check();
      if (self.status == 'running') 
        setTimeout(repeat, self.interval);
    }

    repeat();
  }

  function pause() {
    this.status = 'paused';
  }

  function respond(err, meta, time, cb) {
    var passed = !err;
    if (err == 'timeout') this.emit('timeout');

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

    if (cb) cb(err);
  }

  function perf(cc, time, cb) {
    var results = { pass: 0, fail: 0, time: 0 };
    var stopAt = time + (new Date).getTime();
    for (var i=0; i<cc; i++) {
      this.checkSimple(results, stopAt);
    }
    setTimeout(#{ cb(results) }, time);
  }

  function checkSimple(results, stopAt) {
    var start = (new Date).getTime();
    if (stopAt <= start) return;

    this.strategy(#(err, meta) {
      if (err) results.fail++;
      else {
        results.pass++;
        results.time += (new Date).getTime() - start;
      }
      self.checkSimple(results, stopAt);
    });
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
      self.respond('timeout', null, startTime, cb);
      stopped = true;
    }, this.timeout);

    this.strategy(#(err, meta) {
      self.stacked--;
      if (!stopped) self.respond(err, meta, startTime, cb);
      stopped = true;
    });
  }
}
