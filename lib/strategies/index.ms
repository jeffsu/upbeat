

module.exports = {
  http: require('./http'),

  mysql: #(options) {
    var sql   = options.query || "SHOW TABLES";
    var mysql = require('mysql');
    var conn  = mysql.createConnection({ host: options.host, user: option.user, password: options.password });
    conn.connect();

    return #(cb) {
      conn.query(sql, #(err, rows, fields) { cb(err); });
    };
  },

  // TODO
  tcp: #(options) {
    return #(cb) {
      cb();
    }
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

  // TODO
  process: #(options) {
    return #(cb) {
      cb();
    };
  }

};
