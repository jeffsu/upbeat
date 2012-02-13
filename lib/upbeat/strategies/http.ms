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
        params[key] = JSON.stringify(params[key]);
      }
    }

    var data = params ? QS.stringify(params) : null;
    var url  = config.url;

    if (method == 'get' && data) {
      url = url + '?' + data; 
    } 

    var parsedUrl = URL.parse(url, false);
    var host = config.host || parsedUrl.host || '127.0.0.1';
    host = host.replace(/\:\d+$/, '');

    return {
      host: host,
      port: config.port || parsedUrl.port || 80,
      path: parsedUrl.pathname + (parsedUrl.query ? '?' + parsedUrl.query: ''),
      method: method.toUpperCase()
    };
  }

  function initialize(config) {
    this.interval = config.interval || 5000;
    this.timeout  = config.timeout  || 1000;
    this.method   = 'get';
    this.status   = config.status || '200';
    
    this.matches  = this.getRegexes(config.matches);
    this.lambdas  = this.getLambdas(config.lambda);

    this.options = KLASS.getRequestOptions(config);
    this.url = "http://" + this.options.host + ':' + this.options.port + this.options.path;

    this.id = this.url;
  }

  function getRegexes(regexStrings) {
    if (regexStrings == null) return [];
    if (typeof regexStrings == 'string') regexStrings = [ regexStrings ];

    var ret = [];
    foreach (var rs in regexStrings) {
      try {
        ret.push(new RegExp(rs));
      } catch(e) {
        throw "Failed to compile regex: \n" + rs;
      }
    }

    return ret;
  }

  function getLambdas(lambdaStrings) {
    if (lambdaStrings == null) return [];
    if (typeof lambdaStrings == 'string') lambdaStrings = [ lambdaStrings ];

    var ret = [];
    foreach (var s in lambdaStrings) {
      try {
        eval("var l = " + s + "; ret.push(l)");
      } catch(e) {
        throw "Error evaluating lambda: \n" + s;
      }
    }
    return ret;
  }

  function getRequest(callback) {
    return http.request(this.options, callback);
  }

  function check(callback) {
    var $this = this;
    
    this.req = this.getRequest(#(resp) { 
      var data = [];
      $this.resp = resp;
      resp.on('data', #{ data.push($1) });
      resp.on('end',  #{
        $this.calculatePass(resp, data.join(''), #(passed) {
          callback(passed);
        });
      }); 
    });

    if (this.data) this.req.write(this.data + "\n");

    this.req.on('error', #{ callback(false) });
    this.req.end();
  }

  function calculatePass(resp, data, callback) {
    var passedMatch  = true;
    var passedLambda = true;

    foreach (var m in this.matches) {
      if (! m.test(data)) {
         passedMatch = false;
         break;
      }
    }

    if (passedMatch) {
      foreach (var l in this.lambdas) {
        if (! l(data, resp)) {
           passedLambda = false;
           break;
        }
      }
    }

    var stat = resp.statusCode == this.status;

    if (!passedMatch) console.log("Failed to match regex.");
    if (!passedLambda) console.log("Failed to pass the given lambda.");
    if (!stat) console.log("Failed to get " + this.status + " from: " + this.url + " --- " + resp.statusCode);

    return callback(passedMatch && passedLambda && stat);
  }

  function clear() {
    if (this.resp) this.resp.close();
    if (this.req) this.req.abort();
  }
}
