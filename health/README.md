# Upbeat Health

This is a variety of strategies upbeat uses to test the health of various services.
They are simple and can be used outside of upbeat-server.

# Usage
```javascript
var health = require('upbeat-health');
var tcp = health.tcp("localhost:3000");
tcp(function (err) { console.log(err ? err : "No error") });
```

# API

## Main object (health = require('upbeat-health'))
### health.strategyName([options])

Returns a function that you can call that accepts one callback.  This callback's 
provides the error status of the check.

```javascript
  var http = health.http('http://www.google.com');
  http(function (err) { console.log(err) });
```

### health.checker(strategy, [options]);

Returns a checker object that allows 

## Checker

This class allows for getting events on an health checks on an interval timer.

### checker.start()

Start running checks

### checker.stop()

Stop running checks.  Will still handle the last check if its in the process of running it.

### health.checker(strategy, [options])

  * strategy: strategy to be wrapped by a checker
  * options (Object)
    * interval (integer): the number of milliseconds to wait before calling the next health check

## Strategies
### http
### tcp
### redis
### mysql
### custom
