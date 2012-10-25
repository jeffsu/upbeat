
class Assembler {
  private {
    var required = false;
    var path   = null;
    var upbeat = require('upbeat-server');
  }

  function assemble(config) {
    if (typeof config == 'string') 
      config = this.parseFile(config);

    var server = new upbeat.Server();

    this.buildStats(server, config.stats);
    this.buildLogging(server, config.log);
    this.buildSync(server, config.sync);
    this.buildServices(server, config.services);

    if (config.dashboard) 
      this.buildDash(server, config);

    return server;
  }

  function buildDash(server, config) {
    var dash = require('upbeat-dashboard') 
    dash.setup(server, config);
  }

  function buildSync(server, config) {
    if (!config) return;
    if (config.redis) server.buildRedis(config.redis);
  }

  function buildStats(server, config) {
    if (!config) return;
    for (var k in config) server.addStats(new Stats(config[k]));
  }

  function buildServices(server, config) {
    if (!config) return;
    for (var k in config) server.addService(k, this.buildService(config[k]));
  }

  function buildService(config) {
    var service = new upbeat.Service();
    for (var k in config) 
      service.addSensor(k, this.buildSensor(config[k]));

    return service;
  }

  function buildSensor(config) {
    return new Sensor(config);
  }

  function buildLogging(server, config) {
    if (!config) return;
    foreach (var log in config) 
      server.trackedEvents[log] = true;
  }

  function parseFile(file) {
    if (!required) { 
      require('js-yaml');
      required = true;
      path = require('path');
    }

    return require(path.join(process.cwd(), file));
  }
}

module.exports = new Assembler();
