var http     = require('http');
var Strategy = require('./strategies');

export class Action {
  function initialize(config, listener) {
    this.listener = listener;
    this.alive = true;
    this.meta = { count: 0, passedCount: 0 };

    this.timeout  = config.timeout  || 10000;
    this.interval = config.interval || 5000;
    this.up = false;

    if (config.strategy == 'http') {
      this.strategy = new Strategy.Http(config);
    } 

    else if (config.strategy == 'redis') {
      this.strategy = new Strategy.Redis(config);
    }
    
    else {
      this.strategy = config.strategy;
    }

    this.id = config.name || this.strategy.id;
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
        $this.up = false;
        callback();
      });
    }

    try { 
      this.strategy.check(#(passed) {
        if (passed) {
          $this.log('info', "Passed: " + $this.strategy.id);
        } else {
          $this.log('error', "Failed: " + $this.strategy.id);
        }

        $this.up = passed;

        if (timeoutId) clearTimeout(timeoutId);
        if (passed) $this.updateResponse(start, (new Date()).getMilliseconds());
        callback();
      });
    } catch(e) {
      $this.log('error', "Error: " + $this.strategy.id + "\n" + e.stack);
    }
  }

  function run(notFirst) {
    var $this = this;
    if (! $this.alive) return;

    // first time so just run it
    if (notFirst) {
      $this.timeoutId = setTimeout(#{ $this.check(#{ $this.run(true) }) }, $this.interval);
    } else {
      $this.check(#{ $this.run(true) });
    }
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
    JSON.stringify(this.meta);
  }

  function flush() {
    this.meta = { count: 0 };
  }
}
