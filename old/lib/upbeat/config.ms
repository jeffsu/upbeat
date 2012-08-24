var Service = require('./service');
var Server  = require('./server');

require('js-yaml');

export class Config {
  function initialize(config) {
    this.config = config;
    this.configure(config);
  }

  function configure(config, server) {
    var server = this.server = new Server();
   
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

  function addService(config) {
    var service = new Service(config);
    this.server.addService(service);
  }

  function addServices(config) {
    var services = config.services;
    if (!services) return;

    for (var name in services) {
      var config = services[name];
      config.name = name;
      this.addService(config);
    }
  }

  function addProcess(name, config) {
    if (config) {
      config.name = name;
      var Process = require('./process');
      var process = new Process(config, this.server);
      this.server.addProcess(process);
    } else {
      this.server.addProcess(name);
    }
  }

  function addProcesses(config) {
    var p = config.processes;
    if (p) {
      for (var name in p) {
        this.addProcess(name, p[name]);
      }
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
