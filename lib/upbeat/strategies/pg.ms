var Base = require('./base-strategy');

try {
	var pg = require('pg');
} catch (err) {
	throw "Please install the pg driver: npm install pg";
}

export class Pg extends Base {
  static var TIMEOUT  = 5000;
  static var INTERVAL = 10000;

  function initialize(config) {
    var username = config.username || "postgres";
    var password = config.password ? ":" + config.password : '';
    var host     = config.host || "127.0.0.1";
    var port     = config.port || "5432";
    var db       = config.db || "template1";

    this.sql     = config.sql || "SELECT DATNAME FROM PG_DATABASE";
    this.lambdas = this.getLambdas(config.lambda);
    this.conStr  = [
      "tcp://", username, password,
      "@", host, ":", port,
      "/", db
    ].join("");
  }

  function check(callback) {
    pg.connect(this.conStr, #(err, client, done) {
      if (err) return callback(false);

      client.query(self.sql, #(err, result) {
        //call `done()` to release the client back to the pool
        done();

        if (err) return callback(false);

        var passedLambda = true;
        foreach (var l in self.lambdas) {
          if (! l(result)) {
            passedLambda = false;
            break;
          }
        }

        callback(passedLambda);
      });
    });
  }

  function clear() {
    return true;
  }
}
