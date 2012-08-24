var strategies = require('./strategies');

export class Sensor {
  include $m.EventEmitter;

  private {
    var TIMEOUT  = 5000;
    var INTERVAL = 5000;
    var PAUSED   = 'paused';
    var STACKED  = 5;
  }

  function initialize(options) {
    this.strategy = options.strategy;
    if (typeof this.strategy == 'string') this.strategy = strategies[this.strategy](options);

    this.timeout  = options.timeout  || TIMEOUT;
    this.interval = options.interval || INTERVAL;

    this.fall     = -1 * (options.fall || 1);
    this.up       = options.up || 1;

    this.total    = 0; // total requests
    this.passed   = 0; // total passed requests
    this.failed   = 0; // total failed requests
    this.stacked  = 0; // number of stacked up requests

    this.status = 'paused';
    this.isHealthy   = null;
    this.healthCount = 0;
    this.lastHealth  = null;
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
    this.emit(passed ? 'pass' : 'fail', (new Date).getTime() - time, err || meta);

    if (passed != this.lastHealth) {
      this.healthCount = 0;
    } 
    
    else {
      if (err) this.healthCount--;
      else this.healthCount++;

      // handle changing
      if (this.healthCount == this.fall) {
        this.emit('change', this.isHealthy);
        this.emit('down');
        this.isHealthy = false;
      } 
      
      else if (this.healthCount == this.up) {
        this.emit('change', this.isHealthy);
        this.emit('up');
        this.isHealthy = true;
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
    this.total++;

    var startTime = (new Date).getTime();
    var stopped   = false;
    this.stacked++;

    setTimeout(#{ 
      self.respond('timed-out', null, startTime, cb);
      stopped = true;
    }, this.timeout);

    this.strategy(#(err, meta) {
      self.stacked--;
      if (!stopped) self.respond(err, meta, startTime, cb);
    });
  }
}
