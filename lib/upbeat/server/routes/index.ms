
/*
 * GET home page.
 */

module.exports = #(app, upbeat) {
  app.get('/', #(req, res, next) {
    console.log(upbeat.services['simple'].actions.length);
    res.render('index', { hasService: upbeat.servicesArray.length, services: upbeat.services, processes: upbeat.processes })
  });

  require('./services')(app, upbeat);

  app.get('/health', #(req, res) {
    var ret = {}; 
    var total = 0;
    var count = 0;
    foreach (var service in upbeat.servicesArray) {
      total++;
      if (service.isUp()) count++;
    }

    var healthy = total == count;
    var ratio = count + "/" + total;

    if (!healthy) {
      res.send("Unhealthy (" + ratio + ")", 400);
    } else {
      res.send("Healthy (" + ratio + ")", 200);
    }
  });

};
