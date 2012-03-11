var Base  = require('./base-strategy');
var spawn = require('child_process').spawn;
var fs    = require('fs');

export class Process extends Base {
  static var TIMEOUT  = 5000;
  static var INTERVAL = 5000;

  function initialize(config) {  
    this.pidfile = config.pidfile;
    this.id      = this.pidfile;
  }

  function check(callback) {
    var $this = this;
    fs.readFile(this.pidfile, 'utf8', #(err, data) {
      if (err) {
        callback(false);
      } else {
        self.kill = spawn('kill', [ data.replace(/\s+/g, '') ]);
        self.kill.on('exit', #(code) { callback(code == 0); });
      }
    });
  }

  function clear() {
    if (this.kill) this.kill.kill('SIGINT'); 
  }
}
