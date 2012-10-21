
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

  return #(cb) {
    var req = request(newOpts, #(e, r, body) {
      if (e) return cb(e);

      var code = r.statusCode;
      return cb((parseInt(code) >= 400) ? code : null);
    });
  };
};
