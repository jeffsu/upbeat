module.exports = #(options) {
  var sql   = options.query || "SHOW TABLES";
  var mysql = require('mysql');
  var conn  = mysql.createClient(options);

  return #(cb) {
    conn.query(sql, #(err, rows, fields) { 
      cb(err); 
    });
  };
};
