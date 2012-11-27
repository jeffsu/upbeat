# Upbeat Health

This is a variety of strategies upbeat uses to test the health of various services.
They are simple and can be used outside of upbeat-server.

# Usage

For a simple one-time health check:
```javascript
var health = require('upbeat-health');
var tcp = health.tcp("localhost:3000");
tcp(function (err) { console.log(err ? err : "No error") });
```

For an interval based health check:
```javascript
var health = require('upbeat-health');
var checker = health.checker(health.http("http://www.google.com"));
checker.on('unhealthy', function () { console.log('unhealthy') });
checker.on('healthy', function () { console.log('healthy') });
checker.start();
```

# API

## Main object (health = require('upbeat-health'))
### health.http([options])

Returns a function that you can call that accepts one callback.  This callback's 
provides the error status of the check if failed.  Error is null if passed. NOTE: http 
can be any strategy name. eg: health.tcp([options]), health.http([optios]), etc...

For a list of strategies, look below.


```javascript
  var http = health.http('http://www.google.com');
  http(function (err) { console.log(err) });
```

### health.checker(strategy, [options]);

  1. strategy: strategy function
  1. options (Object)
    1. interval (integer): the number of milliseconds to wait before calling the next health check

Returns a checker object.


## Checker

```javascript
  var checker = new health.Checker(strategy, options);
  // or
  var checker = health.checker(strategy, options);
```

### checker.start()

Start running checks.  Intervals start after the completion (or timeout) of each check.  This means that 
the time between checks is interval+checkTime.

### checker.stop()

Stop running checks.  Will still handle the last check if its in the process of running it.

## Strategies and Options

### health.http([options]) or health.http([url])

If options is used:
 
  * url (String) eg: "http://www.google.com" (use of port in string is also valid)
  * method (String) defaults to GET.
  * hostname (String)
  * path (String) defaults to '/'
  * port (Integer) defaults to 80
  * headers (Object) defaults to {}
  * auth (Object) defaults to null
  * agent (Object) defaults to false
  * timeout (Integer) defaults to 10000

### health.tcp([options]) or health.tcp("host:port");

If options is used:
   
  * hostname (String)
  * port (Integer)
  * timeout (Integer) defaults to 2000
