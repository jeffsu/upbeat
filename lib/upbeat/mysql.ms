var Base = require('./base-strategy');

export class Mysql extends Base {
  function initialize(config) {
    this.sql = config.sql || "SHOW DATABASES LIMIT 1";
  }

  function check() {

  }
}
