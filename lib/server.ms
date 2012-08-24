var Service = require('./service');
var Sensor  = require('./sensor');

export class Server {
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
  }

  function buildService(config) {
    var service = new Service();
    for (var k in config) {
      service.addSensor(k, new Sensor(config[k]));
    }

    return service;
  }

  function build(config) {
    for (var k in config.services) 
      this.services[k] = this.buildService(config.services[k]);
  }
}
