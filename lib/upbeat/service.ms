var http = require('http');
var Checker = require('./checker');

export class Service {
  function initialize(actions) {
    this._status = false;

    this.checkers = [];
    foreach (var action in actions) {
      this.checkers.push(new Checker(action, this));
    }
  }

  function setStatus(bool) {
    this._status = bool;
  }

  function respond(res) {
    var code = $this._status ? 200 : 400;
    res.writeHead(code, {'Content-Type':'text/plain'});
    var out = [];

    foreach (var checker in $this.checkers) {
      out.push(checker.toString()); 
    }

    res.end(out.join("\n"));
  }
}
