var request = require('request');
var URL     = require('url');

module.exports = #(options) {
  var newOpts = {};
  newOpts.__proto__ = options;
  newOpts.url = URL.parse(options.url);

  return #(cb) {
    var req = request(newOpts, #(e, r, body) {
      if (e) return cb(e);
      var code = r.statusCode;
      if (parseInt(code) >= 400) return cb('error status code ' + code);
      cb();
    });
  };
};
