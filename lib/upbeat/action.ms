var http     = require('http');

export class Action {
  function initialize(config, listener) {
    this.listener = listener;
    this.alive = true;
    this.meta = { count: 0, passedCount: 0, up: false, lastErrorMsg: "Not Started" };

    this.timeout  = config.timeout  || 5000;
    this.interval = config.interval || 5000;

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
        $this.log('error', "Timeout: " + $this.strategy.id);
        $this.strategy.clear(); 
        $this.meta.up = false;
        $this.meta.lastErrorMsg = "Timed Out";
        callback();
      }, this.timeout);
    }

    try { 
      this.strategy.check(#(passed) {
        if (passed) {
          $this.log('info', "Passed: " + $this.strategy.id);
        } else {
          $this.log('error', "Failed: " + $this.strategy.id);
          $this.meta.lastErrorMsg = "Failed";
        }

        $this.meta.up = passed;

        if (timeoutId) clearTimeout(timeoutId);
        if (passed) $this.updateResponse(start, (new Date()).getMilliseconds());
        callback();
      });
    } catch(e) {
      $this.log('error', "Error: " + $this.strategy.id + "\n" + e.stack);
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
