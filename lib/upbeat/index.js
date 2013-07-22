require('mochiscript');

var Action      = require('./action');
exports.Action  = Action;
exports.Service = require('./service');
exports.Server  = require('./server');
exports.Config  = require('./config');

exports.registerStrategy = function (name, req) {
  Action.registerStrategy(name, req)
};
