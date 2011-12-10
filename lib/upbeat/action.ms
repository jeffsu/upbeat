var http     = require('http');

export class Action {

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

    this.timeout  = config.timeout  || 5000;
    this.interval = config.interval || 5000;

    this.rise = config.rise || 1;
    this.fall = config.fall || 1;

    if (config.strategy == 'http') {
      var Http = require('./http');
      this.strategy = new Http(config);
    } 

    else if (config.strategy == 'redis') {
      var Redis = require('./redis');
      this.strategy = new Redis(config);
    }
    
    else {
      this.strategy = config.strategy;
    }

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
