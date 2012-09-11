export class HumanTime {
  function now() {
    return this._now || (this._now = (new Date()).getTime());
  }

  function secondsAgo(t) {
    return Math.floor((self.now() - t)/1000);
  }

  function timeDistance(time) {
    var now = this.now();
    var sec = 0, min = 0, hr = 0, day = 0;
    sec = this.secondsAgo(time);
    if (isNaN(sec)) => '---';
     
    if (sec >= 60) {
      min = Math.floor(sec/60);
      sec = sec % 60;
      if (min >= 60) {
        hr  = Math.floor(min/60);
        min = min % 60;
        if (hr >= 24) {
          day = Math.floor(hr/24);
          hr  = hr % 24;
        }     
      }     
    }
    var hrMinSec = [ 
      ['d', day],
      ['h', hr],
      ['m', min],
      ['s', sec]
    ];
    var timeTxt = '';
    var nStr;

    foreach (var division in hrMinSec) {
      var t = division[1];
      if (t === 0 && division[0] != 's') continue;
      nStr = t.toString();
      timeTxt += (nStr + division[0] + ' ');
    }
    return timeTxt;
  };

  function dateTime(t) {
    if (typeof t != 'number') return '';
    var d = new Date(t);
    var date = [d.getMonth(), d.getDay(), d.getFullYear()].join('-');
    var pad = #(t) {
      if (t < 10) => '0' + t.toString();
      else return t.toString();
    }
    var minute = pad(d.getMinutes());
    var second = pad(d.getSeconds());
    var time = [d.getHours(), minute, second].join(':');
    return  date + ' ' + time;
  };
}
