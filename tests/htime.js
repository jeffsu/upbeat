require('mochiscript');
var assert = require('assert');
var HumanTime = require('./../www/htime');
var htime     = new HumanTime();

var now       = htime.now(); 
var mindiff   = 1000;

assert.equal(now, htime.now(), 'now is now');
