require('js-yaml');

var Service = require('./service');
var http    = require('http');
var Status  = require('./status');

export class Server {
  function initialize(file) {
    var config = require(file).shift();
    this.port  = config.port || '2468';
    this.host  = config.host || '127.0.0.1';

    this.services = {};
    this.servicesArray = [];
    for (var name in config.services) {
      var service = new Service(config.services[name]); 
      this.addService(name, service);
      this.servicesArray.push(service);
    }

    this.statusTemplate = new Status();
  }

  function addService(name, service) {
    this.services[name] = service;
    service.name = name;
  }

  function start() {
    if (this.server) this.server.close();

    for (var name in this.services) {
      this.services[name].start();
    }

    var $this = this;
    this.server = http.createServer(#(req, res) {
      console.log(req.url);
      var paths = req.url.split(/\//);
      var service = $this.services[paths[1]];

      if (service) {
        service.respond(res);
      } else if (paths[1] == 'status') {
        res.writeHead(200, { 'Content-type': 'text/html' });
        res.end($this.statusTemplate.show($this.servicesArray));
      } else {
        res.writeHead(404);
        res.end();
      }
    });

    console.log('Starting upbeat server: http://' + this.host + ':' + this.port);
    this.server.listen(this.port, this.host);
  }

  function stop() {
    if (this.server) this.server.close();
  }
}
