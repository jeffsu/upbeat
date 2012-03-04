// Wrapper around forever
export class Process {
  function initialize(name, command, child, service) {
    this.name    = name || command;
    this.command = command;
    this.child   = child;
    this.service = service;

    this.errors = [];
    this.stderr = [];
    this.stdout = [];

    this.setupChild(this.child);
  }

  function isUp() {
    return this.service ? true : this.service.isUp();
  }

  function getPid() {
    return this.child.child.pid;
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
