var Service = require('./service');
var Sensor  = require('./sensor');

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

  function run() {
    if (this.status == 'running') return;
    this.status = 'running';
    this.getServices().forEach(#{ $1.run() });
  }

  function pause() {
    this.status = 'paused';
    this.getServices().forEach(#{ $1.pause() });
  }

  function initialize(config) {
    this.services = {};
    this.build(config);
    this.on('sensor', #(serviceName, sensorName, type, sensor, data1, data2) {
      if (self.trackedEvents[type]) self.log(serviceName, sensorName, type, sensor, data1, data2);
    });

    if (config.dashboard)
      this.buildDash(config.dashboard);
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
    sensor.on(eventName, #{ self.emit('sensor', serviceName, sensorName, eventName, sensor, $1, $2) });
  }

  function log(serviceName, sensorName, eventType, sensor, data1, data2) {
    console.log(serviceName + '/' + sensorName + ': ' + eventType + ' - ' + (new Date).toString());
  }

  function build(config) {
    this.trackedEvents = {};
    if (config.log) 
      config.log.forEach(#{ self.trackedEvents[$1] = true });

    for (var k in config.services) 
      this.services[k] = this.buildService(k, config.services[k]);
  }

  function buildDash(config) {
    this.app = require('../www/app')(this, config);
  }

}
