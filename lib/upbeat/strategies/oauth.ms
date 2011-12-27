var Http  = require('./http');
var NodeOAuth = require('../node-oauth/oauth').OAuth;

export class OAuth extends Http {
  function initialize(config) {
    this.$super(config);
    this.securer = new NodeOAuth(null, null, config.key, config.secret, '1.0', null, 'HMAC-SHA1');
  }

  function check(callback) {
    this.req = this.securer.get(this.url, null, null, #(err, data, result) {
      if (err) {
        callback(false);
      } else {
        callback(true);
      }
      
    });
  }

}
