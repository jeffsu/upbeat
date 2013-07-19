var http = require('http');
var MetaData = require('./meta-data');

export class Action {
  private {
    var STRAGETIES = {
      http:    './strategies/http',
      redis:   './strategies/redis',
      process: './strategies/process',
      mysql:   './strategies/mysql',
      pg:      './strategies/pg',
      tcp:     './strategies/tcp',
      upbeat:  './strategies/upbeat',
      json:    './strategies/json',
      oauth:   './strategies/oauth'
    };

    var N_HOSTORICAL_TICKS = 100;
  }

  static function registerStrategy(name, req) {
    STRAGETIES[name] = req;
  }

  function initialize(config) {
    this.service = config.service;
    this.config  = config;
    this.running = false;


    this.strategy = this.getStrategy(config);
    this.timeout  = config.timeout;
    this.interval = config.interval;

    this.timeout  = this.timeout  || 5000;
    this.interval = this.interval || 10000;

    this.maxResponse = config['max-response-time'] || this.timeout;
    this.name = config.name;
    this.id   = this.strategy.id || this.service.name + ':' + this.name;
    this.meta = new MetaData(config, this.id);
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

  function check(cb) {
    if (this.checking) return;

    var timeoutId = null;

    var startTime = (new Date()).getTime();

    if (this.timeout) {
      timeoutId = this.timeoutId = setTimeout(#{ 
        self.strategy.clear();
        self.processCheck(startTime, "Timed Out");
        self.checking = false;
        timeoutId = null;
        if (cb) cb();
      }, this.timeout);
    }

    try { 
      this.checking = true;
      this.strategy.check(#(passed, errorMsg) {
        self.checking = false;

        // haven't timed out
        if (timeoutId) {
          clearTimeout(timeoutId);
          timeoutId = null;
          self.processCheck(startTime, passed ? false : (errorMsg || 'Failed'));
          if (cb) cb();
        } 
      });
    } 
    
    catch(e) {
       
    }
  }

  function averageTime() {
    return this.meta.averageResponseTime();
  }

  function start() {
    if (this.running) return;
    this.running = true;

    var run  = #{ self.check(beat) };
    var beat = #{ if (self.running) setTimeout(run, self.interval); }

    run();
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
