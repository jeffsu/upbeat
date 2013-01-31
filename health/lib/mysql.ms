module.exports = #(options) {
  var sql   = options.query || "SHOW TABLES";
  try {
    var mysql = require('mysql');
  } catch(e) {
    console.log('Please install "mysql" module');
    throw e;
  }

  var conn  = mysql.createConnection(options);

  return #(cb) {
    conn.query(sql, #(err, rows, fields) { 
      cb(err); 
    });
  };
};
