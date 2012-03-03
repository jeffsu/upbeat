var http = require('http');
var Action = require('./action');

export class Service {
  function initialize(name, actions) {
    this.name    = name;
    this.actions = [];

    foreach (var action in actions) {
      this.actions.push(new Action(action, this));
    }
  }

  function handleConfig(config) {
    if (config.actions) {
      for (var k in config) {
        if (k == 'hosts' || k == 'actions') continue;
        foreach (var action in config.actions) {
          if (!(k in action)) action[k] = config[k];
        }
      }
    }
  }

  function getAction(idx) {
    return this.actions[idx];
  }

  function start() {
    foreach (var action in this.actions) {
      action.run();
    }
  }

  function stop() {
    foreach (var action in this.actions) {
      action.clear();
    }
  }

  function isUp() {
    foreach (var action in this.actions) {
      if (! action.meta.up) return false;
    }
    return true;
  }

  function respondJSON(res) {
    var code = this.isUp() ? 200 : 400;
    res.writeHead(code, {'Content-Type':'application/json'});
    res.write('[');

    foreach (var action:i in this.actions) {
      if (i!=0) res.write(',');
      res.write(action.toJSON()); 
    }

    res.end(']');
  }
}
