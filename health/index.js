require('mochiscript');
var strategies = [];
[ 'http', 'tcp', 'pidfile', 'redis', 'tcp' ].forEach(function (strategy) {
  module.exports[strategy] = function (options) {
    if (!strategies[strategy]) 
      strategies[strategy] = require('lib/' + strategy)(options);

    return strategies[strategy](options);
  };
});

module.exports.register = function (name, funct) { module.exports[name] = funct; }
