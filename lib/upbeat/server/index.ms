require('js-yaml');

var express = require('express');
var Service = require('../service');
var http    = require('http');
var Status  = require('../status');
var Process = require('../process');

export class Server {

  include $m.EventEmitter;

  private {
    var DEFAULT = {
      port: 2468,
      host: '127.0.0.1'
    };
  }

  function initialize(config) {
    this.port  = config.port || DEFAULT.port;
    this.host  = config.host || DEFAULT.host;

    this.processes = {};
    this.services  = {};
    this.servicesArray = [];

    this._status = new Status();
    this.app = this.createServer();
  }

  function snapshot() {
    foreach (var s in this.servicesArray) {
      s.snapshot();
    }
  }

  function getSnapshots() {
    return this.servicesArray#map { $1.getSnapshots() }; 
  }

  function addService(service) {
    console.log("Adding service: " + service.name);
    this.services[service.name] = service;
    this.servicesArray.push(service);
    return service;
  }

  function addProcess(process) {
    console.log("Adding process: " + process.name);
    this.processes[process.name] = process;
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

    if (this.checkIntervalId) clearInterval(this.checkIntervalId); 
    if (this.snapshotIntervalId) clearInterval(this.snapshotIntervalId); 
  }

  function start() {
    foreach (var s in this.servicesArray) {
      s.start();
    }

    this.checkIntervalId = setInterval(#{ self.check() }, this.checkInterval || 5000);

    if (this.snapshotInterval) 
      this.snapshotIntervalId = setInterval(#{ self.snapshot() }, this.snapshotInterval);
  }

  function check() {
    var ret = {};
    var up  = true;

    foreach (var service in this.servicesArray) {
      var isUp = ret[service.name] = service.isUp();
      if (!isUp) up = false
    }
    var code = up ? '200' : '400';

    if (!up) this.emit('error', up, ret);
    this.emit('check', up, ret);
  }

  function snapshot() {
    var ret = {};

    for (var key in this.services) {
      ret[key] = this.services[key].snapshot(); 
    }

    this.snapshots.push(ret);
    this.logSnapshot();
  }

  function logSnapshot() {
    // no op
  }

  function listen(port) {
    console.log("listening on port: " + (port || this.port));
    this.app.listen(port || this.port);
  }
  
  function getAction(service, actionIdx) {
    return this.services[service].actions[actionIdx];
  }

  function getService(name) {
    return this.services[name];
  }
}
