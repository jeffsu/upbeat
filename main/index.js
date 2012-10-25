var upbeat = require('upbeat-server');
var health = require('upbeat-health');
var dash   = require('upbeat-dash');
var main   = module.exports;

for (var k in upbeat) main[k] = upbeat[k];
main.health = health;
main.dash   = dash;
