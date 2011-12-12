var http     = require('http');

export class Action {
  private {
    var Strategies = {
      http:    './http',
      redis:   './redis',
      process: './process',
      mysql:   './mysql',
      tcp:     './tcp',
      upbeat:  './upbeat'
    };
  }

  static function registerStrategy(name, req) {
    Strategies[name] = req;
  }

  function initialize(config, listener) {
    this.listener = listener;
    this.alive = true;

    this.meta = {
      count        : 0,
      passedCount  : 0,
      up           : false,
      lastErrorMsg : "Not Started",
      riseCount    : 0,
      fallCount    : 0
    };

    this.timeout  = config.timeout;
    this.interval = config.interval;

    this.rise = config.rise || 1;
    this.fall = config.fall || 1;

    if (Strategies[config.strategy]) {
      var Strategy  = require(Strategies[config.strategy]);
      this.strategy = new Strategy(config);

      this.timeout  = this.timeout  || Strategy.TIMEOUT;
      this.interval = this.interval || Strategy.INTERVAL;
    }
    
    else if (typeof config.strategy == 'object') {
      this.strategy = config.strategy;
    }

    else {
      throw "Could not find strategy: " + config.strategy;
    }

    this.timeout  = this.timeout  || 5000;
    this.interval = this.interval || 10000;

    this.meta.id = this.id = config.name || this.strategy.id;
  }

  function log(type, msg) {
    if (this.logger) {
      this.logger[type](msg);
    } else {
      console.log(type, msg);
    }
  }

  function check(callback) {
    var start = (new Date()).getMilliseconds();
    var $this = this;
    this.meta.count++;
    
    var timeoutId = null;
    if (this.timeout) {
      timeoutId = setTimeout(#{ 
        $this.log('info', "Timeout: " + $this.strategy.id);
        $this.strategy.clear(); 
        $this.updateStatus(false);
        $this.meta.lastErrorMsg = "Timed Out";
        callback();
      }, this.timeout);
    }

    try { 
      this.strategy.check(#(passed) {
        if (passed) {
          $this.log('debug', "Passed: " + $this.strategy.id);
        } else {
          $this.log('info', "Failed: " + $this.strategy.id);
          $this.meta.lastErrorMsg = "Failed";
        }

        $this.updateStatus(passed);

        if (timeoutId) clearTimeout(timeoutId);
        if (passed) $this.updateResponse(start, (new Date()).getMilliseconds());
        callback();
      });
    } catch(e) {
      $this.log('error', "Error: " + $this.strategy.id + "\n" + e.stack);
    }
  }

  function updateStatus(passed) {
    if (passed) {
      this.meta.riseCount += 1;
      if (this.meta.up) this.meta.fallCount = 0;
    } else {
      this.meta.fallCount += 1;
      if (! this.meta.up) this.meta.riseCount = 0;
    }

    if (this.meta.riseCount >= this.rise && ! this.meta.up) {
      this.meta.up = true;
      this.meta.fallCount = 0;
    } else if (this.meta.fallCount >= this.fall && this.meta.up) {
      this.meta.up = false;
      this.meta.riseCount = 0;
    } 
  }

  function run() {
    var $this = this;
    if (! $this.alive) return;

    // first time so just run it
    $this.timeoutId = setTimeout(#{ $this.check(#{ $this.run() }) }, $this.interval);
  }

  function stop() {
    clearTimeout($this.timeoutId);
    this.alive = false;
  }

  function updateResponse(start, end) {
    var time = end - start;
    if (time < 0) time = 0;
    this.meta.lastResponse = time;

    var avg   = this.meta.avgResponse;
    var count = this.meta.passedCount;

    if (avg) {
      this.meta.avgResponse = Math.floor(((avg * count) + time) / (count + 1));
    } else {
      this.meta.avgResponse = time;
    }

    this.meta.passedCount = count + 1;
  }

  function toString() {
    return JSON.stringify(this.meta);
  }

  function flush() {
    this.meta = { count: 0 };
  }
}
