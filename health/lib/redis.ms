module.exports = #(options) {
  try {
    var redis  = require('redis');
    var client = redis.createClient(options);
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
    client.exec(command, cb); 
  };
};
