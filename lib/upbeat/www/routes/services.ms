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
  app.get('/services/:service/actions/:action.:format?', #(req, res, next) {
    var service = getService(req, res);
    if (service) {
      var period = 'day';
      var action = service.actionHash[req.params.action];
      if (req.params.format == 'json') {
        res.contentType('json');
        var ret = {
          meta: {
            uptime: action.meta.uptime(period),
            downtime: action.meta.downtime(period),
            avgRespTime: action.meta.averageResponseTime(period),
            interval: action.interval,
            timeout:  action.timeout,
            passes: action.meta.total('passed-count'), 
            failures: action.meta.total('failed-count')
          },

          responseTimes: action.meta.plotResponseTimes('min')
        };

        res.send(JSON.stringify(ret));
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
