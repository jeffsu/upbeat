
var Base = require('./base-strategy');
var net = require('net');
export class Tcp extends Base {
  static var TIMEOUT  = 2000;
  static var INTERVAL = 3000;

  function initialize(config) {
    this.port = config.port || 80;
    this.host = config.host || '127.0.0.1';
    this.id = this.host + ':' + this.port;
  }

  function check(callback) {
    this.client = net.connect(this.port, this.host, #{
      callback(true);
      self.client.end(); 
      self.client = null;
    });

    this.client.on('error', #{ callback(false); self.client.end(); self.client = null; });
  }

  function clear() {
    if (this.client) this.client.end();
  }
}
