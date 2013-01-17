var Service = require('./service');
var Sensor  = require('./sensor');
var Stats   = require('./stats');
var Store   = require('./store');

var Base   = require('./base');

export class Server extends Base {
  include $m.EventEmitter;

  function initialize(options) {
    this.services = this.children = {};
  }

  function run() {
    this.start();
  }

  function service(name, options) {
    return this.addChild(Service, name, options);
  }

  function store(options) {
    if (!this._store) {
      options = options || {};
      this._store = new Store(this, options);
    }

    return this._store;
  }

  function eachService(cb) {
    for (var k in this.services) cb(k, this.services[k]); 
  }
}
