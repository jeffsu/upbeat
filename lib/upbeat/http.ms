var Base = require('./base-strategy');
var QS   = require('querystring');
var URL  = require('url');
var http = require('http');

export class Http extends Base {

  static var TIMEOUT  = 10000;
  static var INTERVAL = 10000;

  static function getRequestOptions(config) {
    var method = 'get';

    if (config.post) {
      method = 'post';
    } else if (config.put) {
      method = 'put';
    } 

    // setup data
    var params = config[method];
    for (var key in params) {
      if (typeof params[key] == 'object') {
        params[key] = JSON.stringify(this.params[key]);
      }
    }

    var data = params ? QS.stringify(params) : null;
    var url  = config.url;

    if (method == 'get' && data) {
      url = url + '?' + data; 
    } 

    var parsedUrl = URL.parse(url, false);

    return {
      host: config.host || parsedUrl.host || '127.0.0.1',
      port: config.port || parsedUrl.port || 80,
      path: parsedUrl.pathname + (parsedUrl.query ? '?' + parsedUrl.query: ''),
      method: method.toUpperCase()
    };
  }

  function initialize(config) {
    this.interval = config.interval || 5000;
    this.url      = config.url      || 'http://localhost:3000/';
    this.timeout  = config.timeout  || 1000;
    this.method   = 'get';

    this.options = KLASS.getRequestOptions(config);

    this.id = this.url;
  }

  function check(callback) {
    var $this = this;

    this.req = http.request(this.options, #(resp) { 
      $this.calculatePass(resp, #(passed) {
        callback(passed);
        if (!passed) console.log("Failed to get 200 from: " + $this.url + " --- " + resp.statusCode);
      });
    });

    if (this.data) this.req.write(this.data + "\n");

    this.req.on('error', #{ callback(false) });
    this.req.end();
  }

  function calculatePass(resp, callback) {
    return callback(resp.statusCode == '200');
  }

  function clear() {
    if (this.req) this.req.end();
  }
}


