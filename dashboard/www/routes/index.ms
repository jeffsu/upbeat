
/*
 * GET home page.
 */

module.exports.setup = #(server, app) {
  app.get('/', #(req, res) {
    res.render('index');
  });

  var statusAttrs = [ 'lastPassTime', 'lastFailTime', 'lastFailMessage', 'downTime', 'upTime' ];
  app.get('/status.json', #(req, res) {
    var ret = {};
    server.eachService(#(name, service) {
      var hash = ret[name] = {};
      service.eachSensor(#(name, sensor) {
        var sensorData = hash[name] = {
          isHealthy: sensor.isHealthy()
        };

        statusAttrs.forEach(#(attr) { sensorData[attr] = sensor[attr] });
      });
    });

    res.json(ret);
  });

  app.get('/services/:service', #(req, res) {
    var name    = req.params.service;
    var service = server.services[name];
    res.render('services', {
      serviceName: name,
      service:     service
    });
  });

  app.get('/services/:service/:sensor', #(req, res) {
    //TODO
  });
};

