require('js-yaml');

var express = require('express');
var Service = require('./service');
var http    = require('http');
var Process = require('./process');

export class Server {

  include $m.EventEmitter;

  function initialize(config) {
    this.processes = {};
    this.services  = {};
    this.servicesArray = [];
    this.snapshots     = [];
  }

  function snapshot() {
    var snapshot = {};
    for (var key in this.services) {
      snapshot[key] = s.snapshot();
    }

    this.snapshots.push(snapshot);
    this.emit('snapshot', snapshot);
  }

  function getSnapshots() {
    return this.servicesArray#map { $1.getSnapshots() }; 
  }

  function addService(service) {
    console.log("Adding service: " + service.name);
    this.services[service.name] = service;
    this.servicesArray.push(service);

    service.on('down',   #{ self.emit('down', $1) });
    service.on('up',     #{ self.emit('up', $1) });
    service.on('change', #{ self.emit('change', $1) });

    return service;
  }

  function wrapEvt(e) {
    e.server = this;
    return e;
  }

  function addProcess(process) {
    console.log("Adding process: " + process.name);
    this.processes[process.name] = process;
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

    if (this.snapshotInterval) 
      this.snapshotIntervalId = setInterval(#{ self.snapshot() }, this.snapshotInterval);
  }

  function snapshot() {
    var ret = {};

    for (var key in this.services) {
      ret[key] = this.services[key].snapshot(); 
    }

    this.snapshots.push(ret);
    this.emit('snapshot', ret);
  }

  function getAction(service, actionIdx) {
    return this.services[service].actions[actionIdx];
  }

  function getService(name) {
    return this.services[name];
  }
}
