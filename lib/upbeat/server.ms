require('js-yaml');

var express = require('express');
var Service = require('./service');
var http    = require('http');
var Process = require('./process');

export class Server {

  include $m.EventEmitter;

  function initialize() {
    this.processHash = {};
    this.processes   = [];

    this.serviceHash  = {};
    this.services     = [];
  }

  function addService(service) {
    console.log("Adding service: " + service.name);
    this.services.push(service);
    this.serviceHash[service.name] = service;

    service.on('down',   #{ self.emit('down', $1, $2) });
    service.on('up',     #{ self.emit('up', $1) });
    service.on('change', #{ self.emit('change', $1) });
    service.on('fail', #{ self.emit('fail', $1, $2) });
    service.on('pass', #{ self.emit('pass', $1, $2) });

    this.emit('service-added', service);

    return service;
  }

  function wrapEvt(e) {
    e.server = this;
    return e;
  }

  function addProcess(process) {
    console.log("Adding process: " + process.name);
    this.processHash[process.name] = process;
    this.processes.push(process);
  }

  function stop() {
    if (this.app) this.app.close();

    for (var name in this.services) {
      this.services[name].stop();
    }

    if (this.checkIntervalId) clearInterval(this.checkIntervalId); 
  }

  function start() {
    foreach (var s in this.services) {
      s.start();
    }
  }

  function getAction(service, actionIdx) {
    return this.services[service].actions[actionIdx];
  }

  function getService(name) {
    return this.services[name];
  }
}
