var http = require('http');
var MetaData = require('./meta-data');

export class Action {
  private {
    var STRAGETIES = {
      http:    './strategies/http',
      redis:   './strategies/redis',
      process: './strategies/process',
      mysql:   './strategies/mysql',
      tcp:     './strategies/tcp',
      upbeat:  './strategies/upbeat',
      oauth:   './strategies/oauth'
    };

    var N_HOSTORICAL_TICKS = 100;
  }

  static function registerStrategy(name, req) {
    STRAGETIES[name] = req;
  }

  function snapshot() {
    var m = this.meta;
    this.meta.snapshot();
  }

  function getSnapshots() {
    return this.snapshots;
  }

  function initialize(config, service) {
    this.service = service;
    this.config  = config;
    this.running = false;

    this.meta = new MetaData();

    this.strategy = this.getStrategy(config);
    this.timeout  = config.timeout;
    this.interval = config.interval;

    this.rise = config.rise || 1;
    this.fall = config.fall || 1;

    this.timeout  = this.timeout  || 5000;
    this.interval = this.interval || 10000;

    this.maxResponse = config['max-response-time'] || this.timeout;
    this.id = config.name || config.id || this.strategy.id;
  }

  function on() {
    var meta = this.meta;
    meta.on.apply(meta, arguments);
  }

  function getStrategy(config) {
    if (STRAGETIES[config.strategy]) {
      var Strategy  = require(STRAGETIES[config.strategy]);
      strategy = new Strategy(config);

      this.timeout  = this.timeout  || Strategy.TIMEOUT;
      this.interval = this.interval || Strategy.INTERVAL;

      return strategy;
    }
    
    else if (typeof config.strategy == 'object') {
      return config.strategy;
    }

    else {
      throw "Could not find strategy: " + config.strategy;
    }
  }

  function processCheck(startTime, error) {
    var resTime = (new Date()).getTime() - startTime;

    if (! error && this.maxRepsonse < resTime) {
      error = "Response time was " + resTime + "ms.";
    }

    this.meta.setStatus(error, resTime);
  }

  function check() {
    if (this.checking) return;

    var timeoutId = null;

    var startTime = (new Date()).getTime();

    if (this.timeout) {
      timeoutId = this.timeoutId = setTimeout(#{ 
        self.strategy.clear();
        self.processCheck(startTime, "Timed Out");
        self.checking = false;
        timeoutId = null;
      }, this.timeout);
    }

    try { 
      this.checking = true;
      this.strategy.check(#(passed, errorMsg) {
        self.checking = false;

        if (timeoutId) clearTimeout(timeoutId);
        timeoutId = null;
        self.processCheck(startTime, passed ? false : (errorMsg || 'Failed'));
      });
    } 
    
    catch(e) {
       
    }
  }

  function times(n) {
    var times = this.meta.times;
    var idx = Math.max(0, times.length-n);
    return times.slice(idx);
  }

  function averageTime() {
    return this.meta.averageResponseTime();
  }

  function start() {
    if (this.running) return;
    this.running = true;
    this.intervalId = setInterval(#{ self.check() }, this.interval);
    this.check();
  }

  function stop() {
    if (this.timeoutId)  clearTimeout(this.timeoutId);
    if (this.intervalId) clearInterval(this.intervalId);
  }

  function toJSON() {
    return this.meta.toJSON();
  }

  function isUp() {
    return this.meta.up;
  }

}
