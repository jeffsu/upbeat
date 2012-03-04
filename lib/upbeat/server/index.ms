require('js-yaml');

var express = require('express');
var Service = require('../service');
var http    = require('http');
var Status  = require('../status');
var Process = require('../process');

export class Server {
  private {
    var DEFAULT = {
      port: 2468,
      host: '127.0.0.1'
    };
  }

  function initialize(config) {
    this.port  = config.port || DEFAULT.port;
    this.host  = config.host || DEFAULT.host;

    this.processes = [];

    this.services = {};
    this.servicesArray = [];

    if (config.services) {
      for (var name in config.services) {
        this.addService(name, new Service(name, config.services[name])); 
      }
    }

    this._status = new Status();
    this.app = this.createServer();

    if (config.forever) {
      for (var name in config.forever) {
        var f = config.forever[name]
        f.name = name;
        this.addProcess(f);
      }
    }
  }

  function addProcess(options) {
    var forever = require('forever');
    var command = [];

    var name   = options.name;
    var checks = options.checks;

    delete options['name'];
    delete options['checks'];

    var service = null;
    if (checks) {
      service = this.addService(name, new Service(name, checks));
    }

    if (options.command) command.push(options.command);
    if (options.options) command = command.concat(options.options);

    console.log('Starting: ', command);
    var child = forever.start(command, options);
    this.processes.push(new Process(name, command.join(' '), child, service));
  }

  function addService(name, service) {
    console.log("Adding service: " + name);
    this.services[name] = service;
    service.name = name;
    this.servicesArray.push(service);
    return service;
  }

  function getActions() {
    var ret = [];
    foreach (var s in this.servicesArray) {
      foreach (var a in s.actions) {
        ret.push(a);
      }
    }

    return ret;
  }

  function createServer() {
    var app = express.createServer();
    app.configure(#{
      app.set('views', __dirname + '/views');
      app.set('view engine', 'jade');
      app.use(express.bodyParser());
      app.use(express.methodOverride());
      app.use(app.router);
      app.use(express.static(__dirname + '/public'));
      app.use(express.errorHandler({ dumpExceptions: true, showStack: true }));
    });

    require('./routes')(app, this)

    return app;
  }

  function stop() {
    if (this.app) this.app.close();

    for (var name in this.services) {
      this.services[name].stop();
    }
  }

  function start() {
    foreach (var s in this.servicesArray) {
      s.start();
    }
  }

  function listen() {
    this.app.listen(this.port);
  }
  
  function getAction(service, actionIdx) {
    return this.services[service].actions[actionIdx];
  }

  function getService(name) {
    return this.services[name];
  }
}
