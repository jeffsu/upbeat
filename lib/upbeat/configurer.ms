var Process = require('./process');
var Service = require('./service');

export class Configurer {

  function configure(config, server) {
    this.addProcesses(config, server);
    this.addServices(config, server); 

    if (config.snapshotInterval) {
       server.snapshotInterval = parseInt(config.snapshotInterval);
    }

    if (config.checkInterval) {
       server.checkInterval = parseInt(config.checkInterval);
    }
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

}
