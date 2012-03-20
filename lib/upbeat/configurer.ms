var Service = require('./service');
var Server  = require('./server');

require('js-yaml');

export class Configurer {
  function initialize(config) {
    this.config = config;
    this.configure(config);
  }

  function configure(config, server) {
    var server = this.server = new Server();
   
    if (config.snapshotInterval) {
      server.snapshotInterval = parseInt(config.snapshotInterval);
    }

    if (config.checkInterval) {
      server.checkInterval = parseInt(config.checkInterval);
    }

    if (config.webapp !== false) {
      var WebApp  = require('./www/app');
      this.webApp = new WebApp(server, config.webapp || {});
    }

    if (config.logging !== false) {
      var Logger  = require('./logger');
      this.logger = new Logger(server, config.logging);
    }


    this.addProcesses(config);
    this.addServices(config); 
  }

  function addService(name, config) {
    var service = config ? new Service(name, config) : name;
    this.server.addService(service);
  }

  function addServices(config) {
    var services = config.services;
    if (!services) return;

    for (var name in services) {
      this.addService(name, services[name]);
    }
  }

  function addProcess(name, config) {
    if (config) {
      var Process = require('./process');
      var process = new Process(name, config);
      var checks  = config.checks;
      delete config['checks'];

      var service = null;
      if (checks) {
        service = new Service(name, checks);
        this.server.addService(service);
      }

      var process = new Process(name, options, service);
      this.server.addProcess(process);
    } else {
      this.server.addProcess(name);
    }
  }

  function addProcesses(config) {
    var p = config.processes;
    if (p) {
      for (var name in p) this.addProcess(name, p[name]);
    }
  }

  function start() {
    this.server.start();
    if (this.logger) this.logger.start();
    if (this.webApp) this.webApp.start();
  }

  function stop() {
    this.server.stop();
    if (this.logger) this.logger.stop();
    if (this.webApp) this.webApp.stop();
  }

}
