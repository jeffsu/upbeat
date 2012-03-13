var Process = require('./process');
var Service = require('./service');
var Server  = require('./server');


export class Configurer {
  function initialize(config) {
    this.config = config;
    this.configure(config);
  }

  function configure(config, server) {
    var server = new Server();

   
    if (config.snapshotInterval) {
      server.snapshotInterval = parseInt(config.snapshotInterval);
    }

    if (config.checkInterval) {
      server.checkInterval = parseInt(config.checkInterval);
    }

    if (config.webApp !== false) {
      var WebApp  = require('./www/app');
      this.webApp = new WebApp(server);
    }

    if (config.logging !== false) {
      var Logger  = require('./logger');
      this.logger = new Logger(server);
    }

    this.addProcesses(config, server);
    this.addServices(config, server); 

    this.server = server;
  }

  function addServices(config, server) {
    var services = config.services;
    if (!services) return;

    for (var name in services) {
      var service = new Service(name, services[name]);
      server.addService(service);
    }
  }

  function addProcesses(config, server) {
    var p = config.processes;
    if (p) {
      for (var name in p) {
        var options = p[name];
        var checks  = options.checks;

        delete options['checks'];

        var service = null;
        if (checks) {
          service = new Service(name, checks);
          server.addService(service);
        }

        var process = new Process(name, options, service);
        server.addProcess(process);
      }
    }
  }

  function start() {
    this.server.start();
    if (this.logger) this.logger.start();
    if (this.webApp) this.webApp.start(this.config.port || 2468);
  }

  function stop() {
    this.server.stop();
    if (this.logger) this.logger.stop();
    if (this.webApp) this.webApp.stop();
  }

}
