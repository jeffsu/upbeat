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

  function sync(redis, time) {
    for (var serviceName in this.services) {
      var service = this.services[serviceName];
      for (var sensorName in service.sensors) {
        var sensor = service.sensors[sensorName];
        sensor.sync(time, redis, "upbeat:services:" + serviceName + ":" + sensorName);
      }
    }

    for (var k in this.stats) {
      this.stats[k].syncTime(time, redis, k);
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

  function initialize(config) {
    this.services = {};
    this.stats    = {};
    this.toRun    = [];
    this.logger   = require('winston');

    this.buildServices(config.services);
    this.buildStats(config.stats);

    this.on('sensor', #(serviceName, sensorName, type, sensor, data1, data2) {
      if (self.trackedEvents[type]) self.log(serviceName, sensorName, type, sensor, data1, data2);
    });

    this.setupLogging(config.log);
    
    if (config.dashboard)
      this.buildDash(config.dashboard);

    if (config.sync) {
      this.syncConfig = config.sync;
      this.buildRedis(config.sync.redis);
    }

    process.on('uncaughtException', #{ 
      console.log('uncaught exception:' + $1);
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
      if (self.redisConnected) self.sync(redis, time);
    }

    self.toRun.push(run);
    setInterval(run, interval);
  }

  function buildService(name, config) {
    var service = new Service();
    for (var k in config) {
      service.addSensor(k, this.buildSensor(name, k, config[k]));
    }

    return service;
  }

  function buildSensor(serviceName, sensorName, config) {
    var sensor = new Sensor(config);
    foreach (var event in EVENTS) {
      this.addEvents(sensor, event, serviceName, sensorName);
    }
    return sensor;
  }

  function addEvents(sensor, eventName, serviceName, sensorName) {
    var args = arguments;
    sensor.on(eventName, #{ self.emit('sensor', serviceName, sensorName, eventName, sensor, $1, $2) });
  }

  function log(serviceName, sensorName, eventType, sensor, data1, data2) {
    this.logger.info(serviceName + '/' + sensorName + ': ' + eventType + ' - ' + (new Date).toString());
  }

  function buildStats(config) {
    if (!config) return;
    for (var k in config) {
      this.stats[k] = new Stats(config[k]); 
    }
  }

  function setupLogging(logs) {
    this.trackedEvents = {};
    if (!logs) return;
    foreach (var log in logs) 
      this.trackedEvents[log] = true;
  }

  function buildServices(config) {
    if (!config) return;

    for (var k in config) 
      this.services[k] = this.buildService(k, config[k]);
  }

  function buildDash(config) {
    this.app = require('../www/app')(this, config);
  }

}
