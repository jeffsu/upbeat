var Base = require('./base-strategy');
var QS   = require('querystring');
var URL  = require('url');

export class Http extends Base {
  function initialize(config) {
    this.interval = config.interval || 5000;
    this.url      = config.url      || 'http://localhost:3000/';
    this.timeout  = config.timeout  || 1000;
    this.method   = 'get';
    this.http     = require('http');

    if (config.post) {
      this.method = 'post';
    } else if (config.put) {
      this.method = 'put';
    } 

    // setup data
    this.params = config[this.method];
    for (var key in this.params) {
      if (typeof this.params[key] == 'object') {
        this.params[key] = JSON.stringify(this.params[key]);
      }
    }
    var data = this.params ? QS.stringify(this.params) : null;

    if (this.method == 'get' && data) {
      this.url = this.url + '?' + data; 
    } else if (data) {
      this.data = QS.stringify(this.params);
    }

    var url = URL.parse(this.url, false);

    this.options = {
      host: url.host,
      port: url.port || '80',
      path: url.pathname + (url.querystring || ''),
      method: this.method.toUpperCase()
    };

    console.log("Setup Action:");
    console.log(this.options);

    this.id = this.url;
  }

  function check(callback) {
    var $this = this;

    this.req = this.http.request(this.options, #(resp) { 
      var passed = resp.statusCode == '200';
      callback(passed);
      if (!passed) console.log("Failed to get 200 from: " + $this.url + " --- " + resp.statusCode);
    });

    if (this.data) this.req.write(this.data + "\n");

    this.req.on('error', #{ callback(false) });
    this.req.end();
  }

  function clear() {
    if (this.req) this.req.end();
  }
}


