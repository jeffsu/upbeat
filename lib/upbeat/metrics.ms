var tempos = require('./tempos');

public class Base {
  var BASE_DEFAULTS = { interval: 5000 };
  var DEFAULTS      = { unit: 'unknown', vals: 1 };

  function initialize(namespace, name, config) {
    this.name = name;
    this.namespace = namespace;
    this.id = namespace + ':' + name;
    this.setup(config);
  }

  function setId(id) {
    this.id = id;
  }

  function setup(config) {
    config = config || {};
    this.config = {};

    for (var key in this.BASE_DEFAULTS) {
      this.config[key] = (key in config) ? config[key] : this.BASE_DEFAULTS[key];
    }

    for (var key in this.DEFAULTS) {
      this.config[key] = (key in config) ? config[key] : this.DEFAULTS[key];
    }

    this.unit   = this.config.unit;
    this.labels = this.config.labels;
  }

  function plot(period) {
    period = period || 'min';
    var header = [ period ].concat(this.labels);
    var array  = [ header ];

    var tempo = tempos.get(period);
    var args = [ this.id, 'count' ].concat(this.labels);
    var rows = tempo.getHistory.apply(tempo, args);

    foreach (var row:i in rows) {
      var newRow = [ tempos.calculatePeriod(i, period) ];
      foreach (var label:j in this.labels) {
        newRow.push(row[0] ? (row[j+2] / row[1]) : null);
      }
      array.push(newRow);
    }

    return array;
  }

  function start() {
    this.stop();
    this.measure();
    this.interval = setInterval(#{ self.measure() }, this.config.interval);
  }

  function stop() {
    if (this.interval) clearInterval(this.interval);
  }

  function measure() { }

  function set(vals) {
    tempos.increment(self.id, 'count', 1);
    foreach (var label:i in this.labels) {
      tempos.increment(self.id, label, vals[i]);
    }
  }
}

public class Load extends Base {
  var DEFAULTS = { unit: 'Load', labels: [ 'load' ] };

  function measure() {
    var exec  = require('child_process').exec;
    var child = exec('uptime', #(error, out, err) {
      var m = out.toString().match(/load average: ([\d\.]+)/);
      if (m) {
        var load = parseFloat(m[1]);
        self.set([ load ]);
      }
    })
  }
}

public class SysMem extends Base {
  var DEFAULTS = { unit: 'Memory (GB)', labels: [ 'total', 'used', 'free' ] };

  function measure() {
    var exec  = require('child_process').exec;
    var child = exec('free -m', #(error, out, err) {
      var m = out.toString().match(/Mem:\s+(\d+)\s+(\d+)\s+(\d+)/);
      if (m) self.set([ parseFloat(m[1]) / 1024, parseFloat(m[2]) / 1024, parseFloat(m[3]) / 1024 ]);
    })
  }
}



module.exports.lookup = {
  load: Load,
  sysmem: SysMem
};
  
