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
        if (i==3 && ele == 'sensors' || i == splitted.length - 1) {
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

  app.locals.suffixes  =  SUFFIXES;

};
