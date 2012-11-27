export class Checker {
  include $m.EventEmitter;

  private {
    var UNHEALTHY = 'unhealthy';
    var HEALTHY   = 'healthy';
    var DEFAULT_INTERVAL = 3000;
  }

  function initialize(strategy, options) {
    this.strategy = strategy;
    this.options  = options || {};
    this.running  = false;
    this.stat     = null;
  }

  function start() {
    this.running = true;
    var interval = this.options.interval || DEFAULT_INTERVAL;

    var startTime = null;
    var time      = null

    function run() {
      startTime = (new Date).getTime();
      self.strategy(beat);
    }

    function beat(err) {
      time = (new Date).getTime() - startTime;
      self.handle(err) 
      self.emit('beat', err, time);
      self.emit('check', err, time);
      if (err == 'timeout') self.emit('timeout', time);

      if (self.running) setTimeout(run, interval);
    }

    run();
  } 

  function handle(err) {
    var stat = this.stat;
    this.stat = err ? UNHEALTHY : HEALTHY;

    if (err) {
      if (stat != UNHEALTHY) this.emit(UNHEALTHY, err);
    } else {
      if (stat != HEALTHY) this.emit(HEALTHY);
    }
  }


  function stop() {
    self.running = false;
  }
}
