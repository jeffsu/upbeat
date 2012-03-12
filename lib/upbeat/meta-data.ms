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

    this.rise = config.rise || 1;
    this.fall = config.fall || 1;

    this.downTime     = 0;
    this.upTime       = 0;

    this.totalResTime = 0;
    this.totalCount   = 0;
    this.lastErrorMessage = null;
    this.lastResponseTime = null;

    this.upCount      = 0;
    this.downCount    = 0;
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

    this.mark(resTime);
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

  function mark(time) {
    this.totalResTime    += time;
    this.lastResponseTime = time;

    this.times.push(time); 
    if (this.times.length > HISTORICAL_COUNT) this.times.shift();
  }


}
