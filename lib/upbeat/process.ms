
// Wrapper around forever
export class Process {
  function initialize(name, options, service) {
    var forever = require('forever');
    this.command = this.parseCommand(options);

    this.name = options.name;
    delete options['name'];

    this.child    = forever.start(this.command, options);
    this.service = service;

    this.errors = [];
    this.stderr = [];
    this.stdout = [];

    this.setupChild(this.child);
  }

  function parseCommand(options) {
    var cmd = [];
    if (options.command) cmd.push(options.command);
    if (options.options) cmd = cmd.concat(options.options);

    delete options['command'];
    delete options['options'];

    return cmd;
  }

  function isUp() {
    if (!this.child) return false;
    return this.service ? true : this.service.isUp();
  }

  function getPid() {
    try {
      return this.child ? this.child.child.pid : null;
    } catch(e) {
      return null;
    }
  }

  function setupChild(child) {
    child.on('error',   #{ self.append(self.errors, $1) });
    child.on('stdout',  #{ self.append(self.stdout, $1) });
    child.on('stderr',  #{ self.append(self.stderr, $1) });
  }

  function append(array, str) {
    array.push(str);
    var over = array.length - 20;
    while (over-- > 0) array.shift();
  }
}
