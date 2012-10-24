module.exports = #(options) {
  if (typeof options == 'string') {
    var splitted = options.split(':');
    options = { host: splitted[0], port: parseInt(splitted[1]) };
  }

  var host = options.host;
  var port = options.port;
  var timeout = options.timeout || 10000;

  var net = require('net');

  return #(cb) {
    var returned = false;

    function fin(err) {
      if (returned) return;
      returned = true;

      if (err) socket.destroy();
      socket.end();

      socket = null;
      if (cb) cb(err);
      clearTimeout(id);
    }

    var id = setTimeout(#{ fin('timeout') }, timeout);
    var socket = net.connect({ port: port, host: host }, fin);
    socket.on('error', fin);
  };
};
