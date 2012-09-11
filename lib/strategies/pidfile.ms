var exec = require('child_process').exec;
var fs = require('fs');

module.exports = #(options) {
  var pidfile = options.pidfile;
  var exec    = require('child_process').exec;
  var fs      = require('fs');

  return #(cb) {
    fs.readFile(pidfile, #(err, pid) {
      if (err) return cb('error opening file');

      var command = 'ps -p ' + pid.toString().trim() + ' -o comm=';
      exec(command, process.env, #(err, stdout, stderr) {
        if (err) return cb(err);

        var pass = stdout.toString().match(/\n/);
        if (!pass) cb('process not running');
        else cb();
      });
    });
  }
};
