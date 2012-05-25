var tempo = require('tempo');

class Tempos {
  function initialize() {
    this.min  = new tempo.DataStore(tempo.MIN);
    this.hour = new tempo.DataStore(tempo.HOUR);
    this.day  = new tempo.DataStore(tempo.DAY);
    this.week = new tempo.DataStore(tempo.WEEK);
  }

  function increment(key, attr, val) {
    this.min.increment(key, attr, val); 
    this.day.increment(key, attr, val); 
    this.hour.increment(key, attr, val); 
    this.week.increment(key, attr, val); 
  }

  function get(period) {
    return this[period || 'day'];
  }

  function calculatePeriod(idx, period) {
    if (period == 'min') {
      return ((12 - idx) * 5) + ' secs';
    } else if (period == 'hour') {
      return ((12 - idx) * 5) + ' mins';
    } else if (period == 'day') {
      return (24 - idx);
    }
  }


}

module.exports = new Tempos();
