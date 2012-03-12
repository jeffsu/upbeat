

export class Logger {
  private {
    winston = require('winston');
  }

  function initialize(server) {
    this.server = server;
    this.logger = winston.Logger();

    this.server.on('down',     #{ self.error($1.service.name + ' down: ' + $2) });
    this.server.on('up',       #{ self.info($1.service.name + ' up: ' + $1.action.meta.lastResponseTime + 'ms.') });
    this.server.on('change',   #{ self.info($1.service.name + ' changed.') });
    this.server.on('snapshot', #{ self.info('Server snapshotted') });
  }

  function addConsole(level) {
    level = level || 'debug';
    this.logger.add(winston.transports.Console, { colorize: true, level: level });
  }

  function addFile(file, level) {
    level = level || 'debug';
    this.logger.add(winston.transports.File, { filename: file, level: level });
  }

  function start() {
    this.running = true;
  }

  function stop() {
    this.running = false;
  }

  function error(msg) {
    if (this.running) this.logger.error(msg);
  }

  function info(msg) {
    if (this.running) this.logger.info(msg);
  }

}
