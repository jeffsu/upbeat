
module.exports = #(options) {
  var http = require('http');
  var URL  = require('url');

  if (typeof options == 'string') options = { url: options };

  var url = URL.parse(options.url);

  var httpOptions = {
    method:   options.method || 'GET',
    hostname: url.hostname,
    path:     url.path,
    port:     url.port,
    headers:  options.headers,
    auth:     options.auth,
    agent:    options.agent || false
  };

  var timeout = options.timeout || 10000;

  return #(cb) {
    var returned = false;
    
    function fin(err) {
      if (returned) return;
      returned = true;

      if (id) clearTimeout(id);
      id = null;

      if (cb) cb(err);
    }

    var id = setTimeout(#{ fin('timeout') }, timeout);

    var req = http.request(httpOptions, #(res) {
      var code = res.statusCode;
      fin(parseInt(code) >= 400 ? code : null);
    });

    req.on('error', fin);
    req.end();
  };
};
