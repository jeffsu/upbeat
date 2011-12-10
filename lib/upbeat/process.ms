var Base  = require('./base-strategy');
var spawn = require('child_process').spawn;
var fs    = require('fs');

export class Process extends Base {
  function initialize(config) {  
    this.pidfile = config.pidfile;
    this.id      = this.pidfile;
  }

  function check(callback) {
    var $this = this;
    fs.readFile(this.pidfile, 'utf8', #(err, data) {
      if (err) {
        $this.log("error", "Error: File doesn't exist");
        callback(false);
      } else {
        $this.kill = spawn('kill', [data.replace(/\s+/g, '')]);
        $this.kill.on('exit', #(code){ callback(code == 0); });
      }
    });
  }

  function clear() {
    if (this.kill) this.kill.kill('SIGINT'); 
  }
}
