module.exports = #(options) {
  try {
    var redis = require('redis');
    var port  = options.port || 6379;
    var host  = options.host || '127.0.0.1';
    var client = redis.createClient(port, host, options);
  } catch (e) {
    console.log('Please install the "redis" module.');
    throw e;
  }

  var error = false;
  client.on('error',   #{ error = true; });
  client.on('connect', #{ error = false; });

  var command = options.command || [ 'exists', 'foo' ];

  return #(cb) {
    if (error) return cb("connection error");
    client.mset(command, cb); 
  };
};
