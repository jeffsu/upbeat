var http = require('http');
var URL  = require('url');

module.exports = #(options) {
  var method = options.method || 'GET';
  var url    = URL.parse(options.url);

  var reqOptions = {
    host:   url.hostname,
    method: method,
    port:   url.port,
    path:   url.path
  };

  return #(cb) {
    var req = http.request(reqOptions);

    req.on('response', #(res) {
      var code = res.statusCode;
      var data = "";

      res.on('data', #(chunk) { data += chunk.toString(); });
      res.on('end', #{ cb(code != 200, data) });
      res.on('close', #(err) { cb(err) });
    });

    req.on('error', #(err) { cb(err) });
    req.end();
  };
};
