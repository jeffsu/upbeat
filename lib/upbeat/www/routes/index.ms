
/*
 * GET home page.
 */

module.exports = #(app, upbeat) {
  app.get('/', #(req, res, next) {
    res.render('index', { hasService: upbeat.services.length, services: upbeat.services, hasProcesses: upbeat.processes.length, processes: upbeat.processes })
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

  app.get('/processes/:name', #(req, res) {
    var process = upbeat.processes[req.params.name];
    res.render('process', { process: process }); 
  });

};
