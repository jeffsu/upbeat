module.exports = #(options) {
  var host = options.host;
  var port = options.port;
  var net  = require('net');

  return #(cb) {
    var socket = new net.Socket();
    var returned = false;

    socket.connect(port, host, #{
      if (!returned) cb();
      socket.end();
    });

    socket.on('error', #{
      returned = true;
      socket.destroy();
      cb('error');
    });
  };
};
