require('mochiscript');
var reporter = require('nodeunit').reporters.default;
reporter.run([ 'tests/service.ms', 'tests/sensor.ms' ]);
