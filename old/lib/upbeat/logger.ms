

export class Logger {
  private {
    var winston = require('winston');
  }

  function initialize(server, config) {
    config = config || {};
    this.server = server;

    var transports = [];

    if (config.console !== false) {
      transports.push(new (winston.transports.Console)({ colorize: true }));
    }

    if (config.files) {
      foreach (var f in files) {
        var isString = typeof f == 'string';

        var file  = isString ? f : f.file;
        var level = isString ? 'debug' : (f.level || 'debug');
        transports.push(new (winston.transports.File)({ filename: file, level: level }));
      }
    }

    this.logger = new (winston.Logger)({ transports: transports });

    this.server.on('down',     #{ self.error($1.service.name + ' down: ' + $2) });
    this.server.on('up',       #{ self.info($1.service.name + ' up: ' + $1.action.meta.lastResponseTime + 'ms.') });
    this.server.on('change',   #{ self.info($1.service.name + ' changed.') });
    this.server.on('snapshot', #{ self.info('Server snapshotted') });

    if (config.verbose) {
      this.server.on('pass', #{ self.info($1.service.name + '(' + $1.action.id + ') passed in ' + $1.action.meta.lastResponseTime + 'ms.') });
      this.server.on('fail', #{ self.error($1.service.name + '(' + $1.action.id + ') failed in ' + $1.action.meta.lastResponseTime + 'ms: ' + $2) });
    }

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
