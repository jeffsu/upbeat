var Service = require('./service');
var Sensor  = require('./sensor');
var Stats   = require('./stats');

export class Server {
  include $m.EventEmitter;

  private {
    var EVENTS = [ 'fail', 'pass', 'up', 'down', 'change' ];
  }

  static function fromFile(file) {
    require('js-yaml');
    var config = require(file);
    return this.fromConfig(config);
  }

  static function fromConfig(config) {
    return new KLASS(config);
  }

  function getServices() {
    var services = [];
    for (var k in this.services) services.push(this.services[k]);
    return services;
  }

  function sync(redis, time, cb) {
    var count = 0;
    function fin() {
      if (--count == 0) return cb ? cb() : null;
    }

    for (var serviceName in this.services) {
      var service = this.services[serviceName];
      for (var sensorName in service.sensors) {
        var sensor = service.sensors[sensorName];
        count++;
        sensor.sync(time, redis, "upbeat:services:" + serviceName + ":" + sensorName, fin);
      }
    }

    for (var k in this.stats) {
      count++;
      this.stats[k].syncTime(time, redis, k, fin);
    }
  }

  function run() {
    if (this.status == 'running') return;
    this.status = 'running';
    this.getServices().forEach(#{ $1.run() });
    foreach (var run in this.toRun) run();
  }

  function pause() {
    this.status = 'paused';
    this.getServices().forEach(#{ $1.pause() });
  }

  function initialize() {
    this.services = {};
    this.stats    = {};
    this.toRun    = [];
    this.logger   = require('winston');
    this.trackedEvents = {};

    this.on('sensor', #(serviceName, sensorName, type, sensor, data1, data2) {
      if (self.trackedEvents[type]) self.log(serviceName, sensorName, type, sensor, data1, data2);
    });
  }

  function buildRedis(config) {
    if (!config) return;
    var redis = require('redis').createClient(config);
    this.redisConnected = false;
    redis.on('error',   #{ self.redisConnected = false }); 
    redis.on('connect', #{ self.redisConnected = true }); 
    
    var configIntervals = config.intervals || {};

    var intervals = {
      min:  configIntervals.min  || 3000,
      hour: configIntervals.hour || 30000,
      day:  configIntervals.day  || 60000,
      week: configIntervals.week || 360000
    };

    for (var k in intervals) 
      this.setSyncInterval(k, intervals[k], redis);
  }

  function setSyncInterval(time, interval, redis) {
    function run() {
      if (self.status != 'running') return;
      if (self.redisConnected) self.sync(redis, time, beat);
      else beat();
    }

    function beat() {
      setTimeout(run, interval);
    }

    self.toRun.push(run);
  }

  function addStats(name, stats) {
    this.stats[name] = stats;
  }

  function addService(name, service) {
    this.services[name] = service;
    for (var k in service.sensors) {
      var sensor = service.sensors[k];  
      for (var e in EVENTS) 
        this.addEvents(sensor, e, name, k);
    }
  }

  function addEvents(sensor, eventName, serviceName, sensorName) {
    var args = arguments;
    sensor.on(eventName, #{ self.emit('sensor', serviceName, sensorName, eventName, sensor, $1, $2) });
  }

  function log(serviceName, sensorName, eventType, sensor, data1, data2) {
    this.logger.info(serviceName + '/' + sensorName + ': ' + eventType + ' - ' + (new Date).toString());
  }

}
