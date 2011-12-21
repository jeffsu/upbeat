var Base  = require('./base-strategy');
var redis = require('redis');

export class Redis extends Base {

  static var TIMEOUT  = 2000;
  static var INTERVAL = 10000;

  function initialize(config) {
    this.host = config.host;
    this.port = config.port;

    this.running = false;
    this.createClient();
    this.id = 'redis://' + this.host + ':' + this.port;
  }

  function createClient() {
    var $this = this;

    try {
      this.client = redis.createClient(this.port, this.host);
    } catch(e) {
      console.log("Couldn't find the redis package: npm-g install redis or npm install redis.");
    }

    this.client.on('error',   #{ $this.running = false })
    this.client.on('connect', #{ $this.running = true })
  }

  function check(callback) {
    if (! this.running) return callback(false);

    this.client.echo("hello", #(err, reply) {
      if (err) {
        callback(false);
      } else {
        callback(true);
      }
    });
  }

  function clear() {
    this.client.end();
  }
}
