

module.exports = {
  http: #(options) {
    var request = require('request');
    var args = {
      method: options.method || 'GET',
      url: options.url,
      timeout: (options.timeout || 3000) - 10 
    };
    
    return #(cb) {
      request(args, #(err, res, body) { cb(err || res.statusCode != 200); });
    };
  },

  mysql: #(options) {
    var sql   = options.query;
    var mysql = require('mysql');
    var conn  = mysql.createConnection({ host: options.host, user: option.user, password: options.password });
    conn.connect();

    return #(cb) {
      conn.query(sql, #(err, rows, fields) { cb(err); });
    };
  },

  redis: #(options) {
    try {
      var redis = require('redis');
      var client = redis.createClient(options);
    } catch (e) {
      throw "Please install the redis driver: npm install redis";
    }

    var error = false;
    client.on('error', #{ error = true; });
    client.on('connect', #{ error = false });

    var command = options.command || [ 'exists', 'foo' ];

    return #(cb) {
      if (error) return cb("connection error");
      client.exec(command, cb); 
    };
  },

  process: #(options) {
    return #(cb) {

    };
  }

};
