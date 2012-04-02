var tempos = require('./tempos');

// handles overall uptitude
export class MetaData {
  include $m.EventEmitter;

  private {
    var HISTORICAL_COUNT = 100;
  }

  function initialize(config, id) {
    this.up = false;
    this.times = [];
    this.start = new Date();
    this.firstTime = true;
    this.id        = id;

    this.rise = config.rise || 1;
    this.fall = config.fall || 1;

    this.downTime     = 0;
    this.upTime       = 0;

    this.totalResTime = 0;
    this.totalCount   = 0;
    this.lastErrorMessage = null;
    this.lastResponseTime = null;

    this.passCount    = 0;
    this.failCount    = 0;
    this.runningCount = 0;
  }

  function setStatus(error, resTime) {
    var passed = ! error;

    // credit uptime
    var now = (new Date()).getTime();
    if (this.firstTime) {
      this.up = passed;
      this.firstTime = false;
    }

    if (this.lastTime) {
      var delta = now - this.lastTime;
      if (this.up) {
        tempos.increment(this.id, 'uptime', delta);
      } else {
        tempos.increment(this.id, 'downtime', delta);
      }
    } 

    this.lastTime = now;
    this.totalCount++;

    var wasUp = this.up;

    if (passed) {
      this.passCount++;
    } else {
      this.failCount++;
    }

    this.mark(passed, resTime);
    this.emit((passed ? 'pass' : 'fail'), error);
    this.lastCheck = passed;

    if (wasUp == passed) {
      this.runningCount++;
    } else {
      this.runningCount = 1;
    }

    if (passed && this.runningCount == this.rise) {
      this.up = passed;
      this.emit('up');
      this.emit('change');
    } else if (!passed && this.runningCount == this.fall) {
      this.up = passed;
      this.emit('down', error);
      this.emit('change');
    }
  }

  function uptime() {
    return tempos.day.getVal(this.id, 'uptime');
  }

  function downtime() {
    return tempos.day.getVal(this.id, 'downtime');
  }

  function times(n, period) {
    var tempo = tempos[period];
    var history = tempo.getHistory(this.id, 'resp', 'count');
    
  }


  function averageResponseTime() {
    var totalResp  = tempos.day.getTotal(this.id, 'resp');
    var totalCount = tempos.day.getTotal(this.id, 'count');

    if (this.totalCount == 0) return null;
    return Math.round(totalResp / totalCount);
  }

  function mark(passed, time) {
    tempos.increment(this.id, 'resp', time);
    tempos.increment(this.id, 'count', 1);
    tempos.increment(this.id, (passed ? 'passed' : 'failed'), 1);

    this.totalResTime    += time;
    this.lastResponseTime = time;

    this.times.push([ passed, time ]); 
    if (this.times.length > HISTORICAL_COUNT) this.times.shift();
  }


}
