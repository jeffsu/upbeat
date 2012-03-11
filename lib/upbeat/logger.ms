

export class Logger {
  function initialize(server) {
    this.server = server;
    this.winston = require('winston');

    this.server.on('down',     #{ self.error($1.service.name + ' down.') });
    this.server.on('up',       #{ self.info($1.service.name + ' up: ' + $1.action.meta.lastResponseTime + 'ms.') });
    this.server.on('change',   #{ self.info($1.service.name + ' changed.') });
    this.server.on('snapshot', #{ self.info('Server snapshotted') });
  }

  function start() {
    this.running = true;
  }

  function stop() {
    this.running = false;
  }

  function error(msg) {
    if (this.running) this.winston.error(msg);
  }

  function info(msg) {
    if (this.running) this.winston.info(msg);
  }

}
