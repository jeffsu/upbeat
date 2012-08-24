var Base = require('./base-strategy');

export class Mysql extends Base {

  static var TIMEOUT  = 5000;
  static var INTERVAL = 10000;

  function initialize(config) {
    this.sql    = config.sql || "SHOW DATABASES LIMIT 1";
    this.config = config;
    this.id     = this.sql;
    this.connect();
  }

  function connect() {
    try {
      var mysql = require('mysql');
    } catch(err) {
      throw "Please install the mysql driver: npm install mysql";
    }

    if (this.config.socket) {
      this.client = mysql.createClient({
        socket:   this.config.socket,
        user:     this.config.user,
        password: this.config.password
      });
    } else {
      this.client = mysql.createClient({
        host:     this.config.host || '127.0.0.1',
        port:     this.config.port || 3306,
        user:     this.config.user,
        password: this.config.password
      });
    }
    
    this.client.query('use ' + (this.config.database || "mysql"));
  }

  function check(callback) {
    if (this.client) { 
      this.client.query(this.sql, #(err, result, fields) {
        callback(!! err);
      });
    } else {
      callback(false);
    }
  }

  function clear() {
    if (this.client) {
      this.client.destroy();
      this.connect();
    }
  }
}
