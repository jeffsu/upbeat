require('mochiscript');
var reporter = require('nodeunit').reporters.default;
reporter.run([ 'tests/checker.ms', 'tests/http.ms', 'tests/tcp.ms', 'tests/redis.ms' ]);
