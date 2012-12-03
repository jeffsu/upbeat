var Service = require('./service');
var Sensor  = require('./sensor');
var Stats   = require('./stats');

var Base   = require('./base');

export class Server extends Base {
  include $m.EventEmitter;

  function initialize(options) {
    this.services = this.children = {};
  }

  function service(name, options) {
    return this.addChild(Service, name, options);
  }

  function eachService(cb) {
    for (var k in this.services) cb(k, this.services[k]); 
  }
}
