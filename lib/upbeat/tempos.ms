var tempo = require('tempo');

class Tempos {
  function initialize() {
    this.min  = tempo.min();
    this.hour = tempo.hour();
    this.day  = tempo.day();
    this.week = tempo.week();
  }

  function increment(key, attr, val) {
    var newKey = key + ":" + attr;

    this.min.increment(newKey, val); 
    this.day.increment(newKey, val); 
    this.hour.increment(newKey, val); 
    this.week.increment(newKey, val); 
  }

  function get(period) {
    return this[period || 'day'];
  }
}

module.exports = new Tempos();
