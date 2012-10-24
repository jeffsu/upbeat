
module.exports = #(options) {
  try {
    var request = require('request');
  } catch (e) {
    console.log('Please install "request" package.'); 
    throw e;
  }

  var URL  = require('url');

  if (typeof options == 'string') options = { url: options };

  var newOpts = {};
  newOpts.__proto__ = options;
  newOpts.url = URL.parse(options.url);

  var timeout = options.timeout || 10000;

  return #(cb) {
    var returned = false;
    
    function fin(err) {
      if (returned) return;
      returned = true;
      if (cb) cb(err);
      clearTimeout(id);
    }

    var id = setTimeout(#{ fin('timeout') }, timeout);

    var req = request(newOpts, #(e, r) {
      if (e) return fin(e);

      var code = r.statusCode;
      fin((parseInt(code) >= 400) ? code : null);
    });

    req.on('error', fin);
  };
};
