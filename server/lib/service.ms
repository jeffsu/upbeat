var Sensor = require('./sensor');

export class Service {
  include $m.EventEmitter;

  function initialize(name) {
    this.name    = name;
    this.sensors = {};
    this.isHealthy = null;
  }

  function getSensors() {
    var sensors = [];
    for (var k in this.sensors) sensors.push(this.sensors[k]);
    return sensors;
  }

  function toStatus() {
    var ret = {};
    for (var k in this.sensors) 
      ret[k] = this.sensors[k].toStatus();
    return ret;
  }

  function run() {
    if (this.status == 'running') return;
    this.status = 'running';
    this.getSensors().forEach(#{ $1.run() });
  }

  function pause() {
    this.status = 'paused';
    this.getSensors().forEach(#{ $1.pause() });
  }

  function addSensor(name, sensor) {
    this.sensors[name] = sensor;

    sensor.on('change', #(healthy) {
      if (!healthy) self.isHealthy = false;
      else self.isHealthy = self.getHealth();
    });

  }

  function getHealth() {
    for (var k in this.sensors) {
      if (!this.sensors[k].isHealthy) return false;
    }

    return true;
  }
}
