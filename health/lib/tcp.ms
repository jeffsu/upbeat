module.exports = #(options) {
  if (typeof options == 'string') {
    var splitted = options.split(':');
    options = { host: splitted[0], port: parseInt(splitted[1]) };
  }

  var host = options.host;
  var port = options.port;

  var noDelay = options.noDelay;
  var timeout = options.setTimeout;

  var net  = require('net');

  return #(cb) {
    var socket = new net.Socket();
    var returned = false;

    var error = null;

    function onError(err) {
      cb(error = err || true);
      socket.destroy();
      socket = null;
    }

    if (noDelay) socket.setNoDelay(true);
    if (timeout) 
      socket.setTimeout(timeout, onError);

    socket.on('error', onError);

    socket.connect(port, host, #{
      if (!error) cb();
      socket.end();
      socket = null;
    });
  };
};
