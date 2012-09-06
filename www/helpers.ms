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
    foreach (var ele:i in splitted) {
      last += '/' + ele;
      bc.push({ name: ele, href: last });
    }
    return bc;
  };

  app.locals.health = #(passed, up, down) {
    return passed ?
       '<span style="color: green">' + (up || 'up') + '</span>' :
       '<span style="color: red">'   + (down || 'down') + '</span>';
  };

  app.locals.humanTime = #(t) {
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
