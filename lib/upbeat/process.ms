var Base  = require('./base-strategy');
var spawn = require('child_process').spawn;

class Process extends Base {
  function intialize(config) {  
    this.pidFile = config.pidFile;
    this.id = this.pidFile;
  }

  function check(callback) {
    var pid = null;
    this.kill = spawn('kill', ['-0',pid]);
    var passed = true;
    this.kill.stderr.on('data', #{ passed = false });
    this.kill.stderr.on('exit', #{ callback(true) });
  }

  function clear() {
    if (this.kill) this.kill.kill('SIGINT'); 
  }
}
