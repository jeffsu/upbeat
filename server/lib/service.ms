var Sensor = require('./sensor');
var Base   = require('./base');

export class Service extends Base {
  include $m.EventEmitter;

  function initialize(name, options) {
    this.name     = name;
    this.options  = options || {};
    this.children = this.sensors = {};
  }

  function sensor(name, options) {
    if (!options.interval && this.options.interval)
      options.interval = this.options.interval;
    return this.addChild(Sensor, name, options);
  }

  function eachSensor(cb) {
    for (var k in this.sensors) cb(k, this.sensors[k]);
  }
}
