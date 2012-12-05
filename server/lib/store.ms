var tempo = require('tempo');
var redis = require('redis');

export class Store {
  private {
    var TIMES = {
      min:  5000,
      hour: 30000,
      day:  60000,
      week: 60000
    };
  }

  function initialize(server, options) {
    options = options || {};

    this.counters = {};

    if (options.redis) this.redis = redis.createClient(options.redis);

    for (var time in TIMES) {
      var counter = this.counters[time] = tempo[time]();
      if (this.redis) {
        var syncer = new tempo.Syncer(this.redis);
        syncer.addCounter(counter);
        syncer.start(TIMES[time]);
      }
    }
    
    this.setEvents(server);
  }

  function setEvents(server) {
    server.eachService(#(serviceName, service) {
      service.eachSensor(#(sensorName, sensor) {
        var name = serviceName + '/' + sensorName;
        sensor.on('check', #{ self.handleCheck(name, $1, $2); });
      });
    });
  }

  function handleCheck(pre, sensor, err, time) {
    console.log('check');
    this.inc(pre + (err ? '/failures' : '/passes'));
    this.inc(pre + '/response-times', time);
    this.inc(pre + '/total');
  }

  function inc(key, n) {
    for (var name in this.counters) 
      this.counters[name].inc(key, n || 1)
  }
}
