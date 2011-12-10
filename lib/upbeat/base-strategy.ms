
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
}
