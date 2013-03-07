var Service = require('./service');
var Sensor  = require('./sensor');
var Stats   = require('./stats');
var Store   = require('./store');
var Base    = require('./base');

export class Server extends Base {
  include $m.EventEmitter;

  function initialize(options) {
    this.services = this.children = {};
    this.options = options || {};
  }

  function run() {
    this.start();
  }

  function service(name, options) {
    options = options || {};
    if (!options.interval && this.options.interval)
      options.interval = this.options.interval;
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

  function toHash() {
    var hash = {};
    for (var key in this.children) {
      hash[key] = this.children[key].toHash();
    }
    return hash;
  }
}
