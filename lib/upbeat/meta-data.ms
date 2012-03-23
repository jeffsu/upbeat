// handles overall uptitude
export class MetaData {
  include $m.EventEmitter;

  private {
    var HISTORICAL_COUNT = 100;
  }

  function initialize(config) {
    this.up = false;
    this.times = [];
    this.snapshots = [];
    this.start = new Date();
    this.firstTime = true;

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

  function snapshot() {
    this.snapshots.push({
      up:      this.up,
      resTime: this.averageResponseTime()
    });
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
        this.upTime += delta;
      } else {
        this.downTime += delta;
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

  function averageResponseTime() {
    if (this.totalCount == 0) return null;
    return Math.round(this.totalResTime / this.totalCount);
  }

  function mark(passed, time) {
    this.totalResTime    += time;
    this.lastResponseTime = time;

    this.times.push([ passed, time ]); 
    if (this.times.length > HISTORICAL_COUNT) this.times.shift();
  }


}
