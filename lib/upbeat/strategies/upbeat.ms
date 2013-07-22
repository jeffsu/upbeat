var Http = require('./http');

export class Upbeat extends Http {
  static var TIMEOUT  = 5000;
  static var INTERVAL = 5000;

  function initialize(config) {
    this.options = {
      path: "/status.json",
      host: config.host || '127.0.0.1',
      port: config.port || 2468,
      method: "GET"
    };

    this.desc = "http://" + this.options.host + ':' + this.options.port + this.options.path;
  }

  function calculatePass(resp, data, callback) {
    var services = JSON.parse(data);
    foreach (var s in services) {
      foreach (var a in s.actions) {
        if (! a.up) return callback(false);
      }
    }
    return callback(true);
  }
}
