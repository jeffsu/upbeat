var http = require('http');
var Action = require('./action');

export class Service {
  include $m.EventEmitter;

  function initialize(name, actions) {
    this.name    = name;
    this.actions = [];
    this.up = true;

    foreach (var action in actions) {
      this.addAction(new Action(action, this));
    }
  }

  function addAction(action) {
    this.actions.push(action);
    var meta = action.meta;
    var evt = { service: this, action: action };

    action.on('fail', #{ self.emit('fail', evt); });
    action.on('pass', #{ self.emit('pass', evt); });

    action.on('down', #{ 
      var wasUp = self.up;
      self.up = false;
      self.emit('down', evt, $1); 
      if (wasUp) self.emit('change', evt);
    });

    action.on('up', #{ 
      var changed = false;
      if (!self.up) {
        foreach (var a in self.actions) {
          if (! a.up) break;
        }

        self.up = true;
        changed = true;
      }

      self.emit('up', evt) 
      if (changed) self.emit('change', evt);
    });
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

  function snapshot() {
    foreach (var a in this.actions) {
      a.snapshot();
    }
  }

  function getAction(idx) {
    return this.actions[idx];
  }

  function start() {
    foreach (var action in this.actions) {
      action.start();
    }
  }

  function stop() {
    foreach (var action in this.actions) {
      action.stop();
    }
  }

  function respondJSON(res) {
    var code = this.up ? 200 : 400;
    res.writeHead(code, {'Content-Type':'application/json'});
    res.write('[');

    foreach (var action:i in this.actions) {
      if (i!=0) res.write(',');
      res.write(action.toJSON()); 
    }

    res.end(']');
  }
}
