
var Http = require('./http');

export class Upbeat extends Http {
  function initialize(config) {
    this.options = {
      path: "/status.json",
      host: config.host || '127.0.0.1',
      port: config.port || 2468,
      method: "GET"
    };

    this.id = "http://" + this.options.host + ':' + this.options.port + this.options.path;
  }

  function calculatePass(resp, callback) {
    var data = [];
    resp.on('data', #{ data.push($1); });

    resp.on('end', #{
      var services = JSON.parse(data.join(""));
      foreach (var s in services) {
        foreach (var a in s.actions) {
          if (! a.up) return callback(false);
        }
      }
      return callback(true);
    });
  }
}
