
var fs      = require('fs');
var tempos  = require('./tempos');
var Service = require('./service');

// Wrapper around forever
export class Process {
  function initialize(config, server) {
    this.name = config.name;
    this.pidFile = config.pidFile;

    this.child = this.getChild(config);

    if (config.actions) {
      this.service = new Service({
        actions: config.actions,
        name:    config.name
      });
      server.addService(this.service);
    }

    this.key = 'process:' + this.name;

    this.errors = [];
    this.stderr = [];
    this.stdout = [];
  }

  function getChild(config) {
    var options  = config.forever || {};
    this.command = config.command;

    if (!this.command) return null;

    config.pidFile = config.pidFile || this.pidFile;

    var forever = require('forever');
    return forever.start(this.command, options);
  }

  function start() {
    if (this.intervalId) return;
    this.checkin();
    this.intervalId = setInterval(#{ self.checkin() }, 10000);
  }

  function stop() {
    if (this.intervalId) {
      clearInterval(this.intervalId);
      this.intervalId = null;
    }
  }

  function checkin() {
    this.getSupposedPid(#(err, pid) {
      if (err) {
        tempos.increment(this.key, 'fail-count', 1);
      } else {
        tempos.increment(this.key, 'pass-count', 1);
        tempos.increment(this.key, 'memory', this.getMemory(pid));
      }
    });
  }

  function getMemory() {
    return 10;
  }

  function isUp() {
    if (!this.child) return false;
    return this.service ? true : this.service.isUp();
  }

  function getSupposedPid(cb) {
    fs.readFile(this.pidFile, #(err, data) {
      if (err) {
        return this.getPid();
        console.warn("Error reading pidfile: " + this.pidFile);
        this.state = "Error reading pidfile: " + this.pidFile;
        cb(err);
      } else {
        cb(false, parseInt(data)); 
      }
    });
  }

  function getPid() {
    try {
      return this.child ? this.child.child.pid : null;
    } catch(e) {
      return null;
    }
  }

  function setupChild(child) {
    child.on('error',   #{ self.append(self.errors, $1) });
    child.on('stdout',  #{ self.append(self.stdout, $1) });
    child.on('stderr',  #{ self.append(self.stderr, $1) });
  }

  function append(array, msg) {
    if (array.length == 100) {
      array.shift();
    }

    array.push(msg);
  }
}
