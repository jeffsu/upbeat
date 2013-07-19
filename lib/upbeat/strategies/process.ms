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
        var pid = data.replace(/\s+/g, '');
        var filename = '/proc/' + pid + '/exe';
        fs.readlink(filename, #(err, linkString) {
          if (err) {
            callback(false);
          } else {
            callback(true);
          }
        });
      }
    });
  }

  function clear() { }
}
