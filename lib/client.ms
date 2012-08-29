var tempo   = require('tempo');
var request = require('request');

export class Client {
  private {
    var INTERVAL = 3000;
    var HOST     = '127.0.0.1';
    var PORT     = 2468;
  }

  function initialize(config) {
    this.interval = config.interval || INTERVAL;
    this.host     = config.host || HOST;
    this.port     = config.port || PORT;

    this.stats    = {};

    this.setInterval();
    if (config.redisClient) this.redis = config.redisClient;
    else if (config.redis) this.redis = this.createRedisClient(config.redis);

    this.redis.on('error', #{ self.hasRedis = false });
    this.redis.on('connect', #{ self.hasRedis = true });
  }


  function setInterval() {
    if (this.intervalId) return;
    this.intervalId = setInterval(#{ self.sync() }, 1000);
  }

  function sync() {
    if (!this.hasRedis) return;

    for (var name in this.stats) {
      var stats = this.stats[name];
      stats.sync(this.redis, name);
    }
  }

  function createRedisClient(config) {
    var redis = require('redis');
    return redis.createClient(config);
  }

  function inc(name, n) {
    n = n || 1;
    var data = this.getData(name);
    data.inc(name, n);
  }

  function getStats(name) {
    return this.stats[name] || (this.stats[name] = new Stats());
  }

}
