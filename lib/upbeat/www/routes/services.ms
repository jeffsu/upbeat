module.exports = #(app, upbeat) {
  function getService(req, res, cb) {
    var service = upbeat.getService(req.params.service);
    if (! service) {
      res.send("Service not found", 404);
      return false; 
    } else {
      return service
    }
  }

  // service landing page
  app.get('/services/:service', #(req, res, next) {
    var service = getService(req, res);
    if (service) res.render('service', { service: service });
  });

  // service actions times
  app.get('/services/:service/actions.json', #(req, res, next) {
    var service = getService(req, res);
    var period  = req.query.period || 'min';
    if (service) {
      var times = service.actions.map(#{ => $1.meta.plotResponseTimes('min') });
      res.contentType('json');
      res.send(JSON.stringify(times));
    }
  });

  // service actions times
  app.get('/services/:service/actions/:actionIdx.:format?', #(req, res, next) {
    var service = getService(req, res);
    if (service) {
      var action = service.actions[parseInt(req.params.actionIdx)];
      if (req.params.format == 'json') {
        res.contentType('json');
        res.send(JSON.stringify(action.meta));
      } 
      
      else {
        res.render('action', { action: action, service: service });
      }
    }
  });

  app.get('/services/:service/health', #(req, res, next) { 
    var service = getService(req, res);
    if (service) {
      if (service.up) {
        res.send("Healthy", 400);
      } else {
        res.send("Unhealthy", 400);
      }
    }
  });

};
