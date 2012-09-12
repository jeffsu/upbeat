

export class HumanTime {
  private {
    var SEC   = 1000;
    var MIN   = SEC * 60;
    var HOUR  = MIN * 60;
    var UNITS = [ 'd', 'h', 'm', 's' ];
    var VALS  = [ 24 * HOUR, HOUR, MIN, SEC ];
  }

  function now() {
    return this._now || (this._now = (new Date()).getTime());
  }

  function ago(t) {
    return this.now() - t;
  }

  function humanizeAgo(ms) {
    var ago = this.ago(ms);
    var human = this.humanize(ago);
    if (human === '---') return human;
    return human + ' ago';
  }

  function humanize(ms) {
    if (isNaN(ms)) return "---";

    var ret = [];
    foreach (var v:i in VALS) {
      var amount = Math.floor(ms / v);
      ms -= amount * v;
      if (amount > 0 || i == 3) ret.push(amount + UNITS[i]);
    }

    return ret.join(' ');
  }

  function pad(n) {
    return (n < 10 ? "0" : '') + n;
  }

  function dateTime(d) {
    // if (typeof t != 'number') return '';
    // var d = new Date(t);
    var date = [d.getMonth(), d.getDay(), d.getFullYear()].join('-');
    var minute = this.pad(d.getMinutes());
    var second = this.pad(d.getSeconds());
    var time = [d.getHours(), minute, second].join(':');
    return  date + ' ' + time;
  };
}
