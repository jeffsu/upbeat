var http = require('http');

export class Action {
  private {
    var Strategies = {
      http:    './http',
      redis:   './redis',
      process: './process',
      mysql:   './mysql',
      tcp:     './tcp',
      upbeat:  './upbeat',
      oauth:   './oauth'
    };

    var N_HOSTORICAL_TICKS = 100;
  }

  static function registerStrategy(name, req) {
    Strategies[name] = req;
  }

  function initialize(config, service) {
    this.service = service;
    this.alive = true;
    this.config = config;

    this.meta = {
      count        : 0,
      passedCount  : 0,
      up           : false,
      lastErrorMsg : "Not Started",
      lastFailure  : null,
      riseCount    : 0,
      fallCount    : 0,
      responseTimes: []
    };

    this.strategy = this.getStrategy(config);
    this.timeout  = config.timeout;
    this.interval = config.interval;

    this.rise = config.rise || 1;
    this.fall = config.fall || 1;

    this.timeout  = this.timeout  || 5000;
    this.interval = this.interval || 10000;
    this.maxResponse = config['max-response-time'] || this.timeout;

    this.meta.id = this.id = config.name || this.strategy.id;
  }

  function getStrategy(config) {
    if (Strategies[config.strategy]) {
      var Strategy  = require(Strategies[config.strategy]);
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

  function log(type, msg) {
    var str = msg + " (" + this.service.name + "): " + this.id;
    if (this.logger) {
      this.logger[type](str);
    } else {
      console.log(type, str);
    }
  }

  function check(callback) {
    var start = (new Date()).getTime();
    var $this = this;
    this.meta.count++;
    
    var timeoutId = null;
    if (this.timeout) {
      timeoutId = setTimeout(#{ 
        $this.log('info', "Failed - Timed Out");
        $this.strategy.clear(); 
        $this.updateStatus(false);
        $this.meta.lastErrorMsg = "Timed Out";
        $this.meta.lastFailure = start;
        callback();
      }, this.timeout);
    }

    try { 
      this.strategy.check(#(passed) {
        if (passed) {
          $this.log('debug', "Passed");
        } else {
          $this.log('info', "Failed");
          $this.meta.lastErrorMsg = "Failed";
          $this.meta.lastFailure = start;
          $this.updateStatus(false);
        }


        if (timeoutId) clearTimeout(timeoutId);
        if (passed) {
          var endTime = (new Date()).getTime();
          var responseTime = $this.updateResponse(start, endTime); 
          if ($this.maxResponse < responseTime) {
            $this.log('info', "Failed - Too Slow");
            $this.meta.lastErrorMsg = "Too slow";
            $this.meta.lastFailure = start;
            $this.updateStatus(false);
          } else {
            $this.updateStatus(true);
          }
        }

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

  function benchmark(count, emitter, callback) {
    count = count || 1; 

    var meta = { 
      count: 0,
      errors: 0
    };
    
    var strategy  = this.getStrategy(this.config);
    var startTime = (new Date()).getTime()

    var alive = true;
    if (emitter) emitter.on('end', #{ alive = false });

    var recurse = #{
      if (!alive || meta.count == count) {
        meta.totalTime = (new Date()).getTime() - startTime;
        callback(meta);
        return;
      }

      try {
        strategy.check(#(passed){ 
          if (!passed) meta.errors++;
          recurse(); 
        });
      } 
      
      catch(e) {
        meta.errors++;
        recurse(); 
      }

      meta.count++;
    };

    recurse();
  }

  function run() {
    if (! this.alive) return;

    // first time run immediately
    if (this.firstTime) {
      this.firstTime = false;
      this.check(#{ $this.run() });
    } else {
      var $this = this;
      this.timeoutId = setTimeout(#{ $this.check(#{ $this.run() }) }, this.interval);
    }
  }

  function stop() {
    if (this.timeoutId) clearTimeout(this.timeoutId);
    this.alive = false;
  }

  function updateResponse(start, end) {
    var time = end - start;

    if (time < 0) {
      this.meta.count--;
      return 0;
    }

    this.meta.lastResponse = time;

    var avg   = this.meta.avgResponse;
    var count = this.meta.passedCount;

    if (avg) {
      this.meta.avgResponse = Math.floor(((avg * count) + time) / (count + 1));
    } else {
      this.meta.avgResponse = time;
    }

    this.meta.passedCount = count + 1;

    var times = this.meta.responseTimes;
    while (times.length > N_HOSTORICAL_TICKS) times.shift();
    times.push(time);

    return time;
  }

  function toString() {
    return JSON.stringify(this.meta);
  }

  function flush() {
    this.meta = { count: 0 };
  }
}
