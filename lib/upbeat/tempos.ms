var tempo = require('tempo');

export class Tempos {
  function initialize() {
    this.minute = new tempo.DataStore(temp.MIN);
    this.day    = new tempo.DataStore(temp.DAY);
    this.hour   = new tempo.DataStore(temp.HOUR);
    this.week   = new tempo.DataStore(temp.WEEK);
  }

  function increment(key, attr, val) {
    this.minute.increment(key, attr, val); 
    this.day.increment(key, attr, val); 
    this.hour.increment(key, attr, val); 
    this.week.increment(key, attr, val); 
  }
}
