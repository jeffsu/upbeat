var strategies = require('./strategies');
var tempo      = require('tempo');
var Stats      = require('./stats');
var health     = require('upbeat-health')
var Base       = require('./base');

export class Sensor {
  include $m.EventEmitter;

  function initialize(options) {
    this.options  = options || {};
    this.strategy = options.strategy;

    if (typeof this.strategy == 'string') this.strategy = health[this.strategy](options);
    this.checker = health.checker(this.strategy, { interval: options.interval })

    this.checker.on('healthy', #{ 
      self._health = true 
      self.emit('healthy');
      self.emit('up');
    });

    this.checker.on('unhealthy', #{ 
      self._health = false
      self.emit('unhealthy', $1);
      self.emit('down', $1);
    });

    this.checker.on('check', #(err, time) { 
      self.emit((err ? 'fail' : 'pass'), time);
      self.emit('check', err, time); 
    });
  }

  function start() {
    if (this.isRunning) return;
    this.isRunning = true;
    this.checker.start();
  }

  function resume() {
    this.start();
  }

  function pause() {
    this.stop();
  }

  function stop() {
    if (!this.isRunning) return;
    this.isRunning = false;
    this.checker.stop();
  }

  function isHealthy() {
    return this._health;
  }
}
