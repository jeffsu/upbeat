var Base  = require('./base-strategy');

export class Redis extends Base {

  static var TIMEOUT  = 2000;
  static var INTERVAL = 10000;

  function initialize(config) {
    this.host = config.host || 'localhost';
    this.port = config.port || 6379;

    this.running = false;
    this.createClient();
    this.id = 'redis://' + this.host + ':' + this.port;
  }

  function createClient() {
    try {
      var redis = require('redis');
      this.client = redis.createClient(this.port, this.host);
    } catch(e) {
      console.log("Couldn't find the redis package: npm-g install redis or npm install redis.");
    }

    this.client.on('error',   #{ self.running = false })
    this.client.on('connect', #{ self.running = true })
  }

  function check(callback) {
    console.log('hi');
    if (! this.running) return callback(false);

      console.log('start');
    this.client.echo("hello", #(err, reply) {
      console.log('finishied');
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
