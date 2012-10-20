require('mochiscript');
var Checker = require('./lib/checker');
var strategies = {};
[ 'http', 'tcp', 'pidfile', 'redis', 'tcp' ].forEach(function (strategy) {
  module.exports[strategy] = function (options) {
    if (!strategies[strategy]) 
      strategies[strategy] = require('./lib/' + strategy);

    return strategies[strategy](options);
  };
});

module.exports.register = function (name, funct) { module.exports[name] = funct; }
module.exports.checker  = function (strategy, options) { return new Checker(strategy, options) }
