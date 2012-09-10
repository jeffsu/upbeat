

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

  redis: require('./redis'),

  // TODO
  process: #(options) {
    return #(cb) {
      cb();
    };
  }

};
