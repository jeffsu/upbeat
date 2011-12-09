require('js-yaml');

var Service = require('./service');

export class Server {
  function initialize(file) {
    var config = require(file).shift();
    this.port  = config.port || '2468';
    this.host  = config.host || '127.0.0.1';

    this.services = {};
    for (var name in config.services) {
      var service = new Service(config.services[name]); 
      this.addService(name, service);
    }
  }

  function addService(name, service) {
    this.services[name] = service;
  }

  function start() {
    if (this.server) this.server.close();

    var $this = this;
    this.server = http.createServer(#(req, res) {
      var paths = req.url.split(/\//);
      var service = $this.services[paths[1]];

      if (service) {
        service.respond(res);
      }
    });

    this.server.listen(this.host, this.port);
  }

  function stop() {
    if (this.server) this.server.close();
  }
}
