var upbeat = require('upbeat-server');
var health = require('upbeat-health');
// TODO: publish to npm
// var dash   = require('upbeat-dashboard');
var dash   = require('../dashboard');
var main   = module.exports;

for (var k in upbeat) main[k] = upbeat[k];
main.health = health;
main.dash   = dash;
