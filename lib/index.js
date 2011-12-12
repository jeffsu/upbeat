require('mochiscript');

var Action      = require('./upbeat/action');
exports.Action  = Action;
exports.Service = require('./upbeat/service');
exports.Server  = require('./upbeat/server');

exports.registerStrategy = function (name, req) { Action.registerStrategy(name, req) };
