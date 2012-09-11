var cp = require('child_process');

var exiting = false;

console.log('forking upbeat');
var upbeat   = cp.fork(__dirname + '/upbeat-server.js');

console.log('forking test server');
var myServer = cp.fork(__dirname + '/my-server.js');
