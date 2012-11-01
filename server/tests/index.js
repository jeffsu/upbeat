require('mochiscript');
var reporter = require('nodeunit').reporters.default;
reporter.run([ 'tests/sensor.ms', 'tests/service.ms', 'tests/stats.ms' ]);
