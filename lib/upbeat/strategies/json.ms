var Http = require('./http');
var exec = require('child_process').exec;

export class JSONCheck extends Http {
  function calculatePass(resp, data, callback) {
    try {
      var status = JSON.parse(data);
      var isUp = self.statusCheck(status);
    } catch (e) {
      var isUp = false;
    }
    return callback(isUp);
  }

  // Check object's fields for true status. Recursively checks
  // nested fields as well.
  function statusCheck(status) {
    for (var key in status) {
      if (typeof(status[key]) == 'object') {
        var result = self.statusCheck(status[key]);
      } else {
        var result = status[key];
      }

      if (result != true) {
        return false;
      }
    }
    return true;
  }

  // TODO: enable user specified field checks in addition to
  // checking if everything is true
}
