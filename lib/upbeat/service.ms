var http = require('http');
var Action = require('./action');

export class Service {
  function initialize(actions) {
    this.actions = [];
    foreach (var action in actions) {
      this.actions.push(new Action(action, this));
    }
  }

  function start() {
    foreach (var action in this.actions) {
      action.run();
    }
  }

  function respond(res) {
    var passed = true;
    foreach (var action in this.actions) {
      if (! action.meta.up) {
        passed = false;
        break;
      }
    }

    var code = passed ? 200 : 400;
    res.writeHead(code, {'Content-Type':'text/plain'});
    var out = [];

    foreach (var action in this.actions) {
      out.push(action.toString()); 
    }

    res.end(out.join("\n"));
  }
}
