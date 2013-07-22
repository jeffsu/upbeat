var tempos = require('./tempos');

var fs      = require('fs');
var tempos  = require('./tempos');
var Service = require('./service');

// Wrapper around forever
export class Process {
  private {
    var PS = "ps -o rss=,vsz= -p ";
    var exec = require('child_process').exec;
  }

  function initialize(config, server) {
    this.name    = config.name;
    this.pidFile = config.pidFile;
    this.child   = this.getChild(config);

    if (config.actions) {
      this.service = new Service({
        actions: config.actions,
        name:    config.name
      });
      server.addService(this.service);
    }

    this.key = 'process:' + this.name;

    this.mem  = 0;
    this.vmem = 0;

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
    this.intervalId = setInterval(#{ self.checkin() }, 1000);
  }

  function stop() {
    if (this.intervalId) {
      clearInterval(this.intervalId);
      this.intervalId = null;
    }
  }

  function plotMemory(period) {
    period = period || 'min';
    return tempos.get(period)
      .getHistory(this.key, 'mem', 'mem-counter')
      .map(#(row) { console.log(row); =>row[2] ?  Math.round(row[1] / row[2]) : null });
  }

  function checkin() {
    this.getSupposedPid(#(err, pid) {
      if (err) {
        self.logFail();
      } else {
        self.pid = pid;
        self.checkProcess(pid);
      }
    });
  }

  function checkProcess(pid) {
    exec('kill -0 ' + pid, #(err, stdout, stderr) {
      if (err) {
        self.logFail();
      } else {
        tempos.increment(self.key, 'pass-count', 1);
      }
    });

    exec(PS + pid, #(err, stdout, stderr) {
      if (err) return;
      var splitted = stdout.trim().split(/\s+/);
      self.mem  = parseInt(splitted[0]);
      self.vmem = parseInt(splitted[1]);

      tempos.increment(self.key, 'mem', self.mem);
      tempos.increment(self.key, 'vmem', self.vmem);
      tempos.increment(self.key, 'mem-counter');
    });
  }

  function isUp() {
    if (!this.child) return false;
    return this.service ? true : this.service.isUp();
  }

  function logFail() {
    tempos.increment(self.key, 'fail-count', 1);
  }

  function getSupposedPid(cb) {
    fs.readFile(this.pidFile, #(err, data) {
      if (err) {
        return self.getPid(cb);
        console.warn("Error reading pidfile: " + this.pidFile);
        this.state = "Error reading pidfile: " + this.pidFile;
        cb(err);
      } else {
        cb(false, parseInt(data));
      }
    });
  }

  function getPid(cb) {
    try {
      var pid = this.child ? this.child.child.pid : null;
      if (pid) {
        cb(false, pid);
      } else {
        cb(true);
      }
    } catch(e) {
      cb(false, pid);
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
