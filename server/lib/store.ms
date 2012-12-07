var tempo = require('tempo');

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
    for (var time in TIMES) this.counters[time] = tempo[time]();
    
    this.setEvents(server);
  }

  function getHistoricalPayload(service, sensor) {

  }

  function getPayload(service, sensor, time) {
    var pre = service + '/' + sensor;
    var counter = this.counters[time];
    var data = [];
    counter.eachCount(
      pre + '/responseTime',
      pre + '/passes',
      pre + '/failures',
      pre + '/total',
    #(rt, p, f, t, time) {
        data.push({ 
          responseTime: (t == 0) ? null : Math.round(rt / t),
          total:    t,
          passes:   p,
          failures: f,
          time:     time
        });
    });

    return data;
  }

  function start(redis) {
    if (!this.syncers) {
      this.syncers = {};
      for (var time in TIMES) {
        var counter = this.counters[time];
        var syncer = new tempo.Syncer(redis);
        syncer.addCounter(counter);
        syncer.start(TIMES[time]);
        this.syncers[time] = syncer;
      }
    }
  }

  function stop() {
    for (var k in this.syncers) this.syncers[k].stop();
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
    this.inc(pre + (err ? '/failures' : '/passes'));
    this.inc(pre + '/responseTime', time);
    this.inc(pre + '/total');
  }

  function inc(key, n) {
    for (var name in this.counters) 
      this.counters[name].inc(key, n || 1)
  }

}
