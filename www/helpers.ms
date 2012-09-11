module.exports = #(app) {
  var SUFFIXES = {
    min: 'seconds ago',
    hour: 'minutes ago',
    day:  'hours ago',
    week: 'days ago'
  };

  app.locals.affirm = #(val) {
    return val ? "yes" : "no";
  };

  app.locals.breadcrumbs = #(path) {
    path = path || this.path;
    var splitted = path.split('/');
    var bc = [];
    var last = "";
    var linked = true;
    foreach (var ele:i in splitted) {
      if (i !== 0) {
        if (i==3 && ele == 'sensors') {
          linked = false;
        } else {
          linked = true;
        }
        last += '/' + ele;
        bc.push({ name: ele, href: last, linked: linked });
      }
    }
    return bc;
  };

  app.locals.health = #(passed, up, down) {
    return passed ?
       '<span style="color: green">' + (up || 'up') + '</span>' :
       '<span style="color: red">'   + (down || 'down') + '</span>';
  };

  app.locals.humanTime = #(time) {
    var now = (new Date()).getTime();
    var sec = 0, min = 0, hr = 0;
    sec = secondsAgo(time);

    function secondsAgo(t) {
      return Math.floor((now - t)/1000);
    }
     
    if (sec >= 60) {
      min = Math.floor(sec/60);
      sec = sec % 60;
      if (min >= 60) {
        hr  = Math.floor(min/60);
        min = min % 60
      }     
    }
    var hrMinSec = { hour: hr, minute: min, second: sec };
    var timeTxt = '';

    for (var division in hrMinSec) {
      var t = hrMinSec[division];
      if (t > 0 || division == 'second') {
        timeTxt += (t.toString() + ' ' + division + (t != 1 ? 's ago ' : ' ago '));
      }
    }
    return timeTxt;
  };

  app.locals.dateTime = #(t) {
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

  app.locals.suffixes = SUFFIXES;


};
