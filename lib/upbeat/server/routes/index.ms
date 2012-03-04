
/*
 * GET home page.
 */

module.exports = #(app, upbeat) {

  app.get('/', #(req, res, next) {
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

  app.get('/processes/:idx.tail', #(req, res) {
    var idx = parseInt(req.params.idx);
    var process = upbeat.processes[idx];
    res.writeHead(200, { 'Content-type': 'text/html', 'Transfer-encoding': 'chunked' });
    res.write("<html><body>");
    process.addListener(res, req);
  });


  app.get('/processes/:idx', #(req, res) {
    var idx = parseInt(req.params.idx);
    var process = upbeat.processes[idx];
    res.render('process', { process: process }); 
  });

};
