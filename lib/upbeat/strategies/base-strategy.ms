export class Base {
  function check(callback) {
    if (callback) callback(true);
  }

  function log(type, msg) {
    if (this.logger) {
      this.logger[type](msg);
    } else {
      console.log(type, msg);
    }
  }

  function getLambdas(lambda) {
    if (lambda == null) return [];

    if (Object.prototype.toString.call(lambda) != '[object Array]') {
      lambda = [ lambda ];
    }

    return lambda.map(function (l) {
      if (typeof l != 'function') {
        try {
          eval("l = " + l + ";");
        } catch (e) {
          throw "Error evaluating lambda: \n" + l;
        }
      }

      return l;
    });
  }
}
