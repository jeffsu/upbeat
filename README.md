# Upbeat 

Upbeat is a high performance node-based healthcheck/dashboard.  Upbeat allows you to run health checks and provides a dashboard to chart the performance.  It also allows you to proxy and cache these health checks so they don't tax your system.  You can now reduces the number of health checks to a service from O(N) to O(1).

## Installation

As executable
```bash
npm install -g upbeat
```

Run upbeat
```bash
upbeat config.yml
```

As library
```bash
npm install upbeat
```

```js
var upbeat = require('upbeat');
var server = new upbeat.Server(configObject);
server.run();
```

## Configuration

Quickstart config:

```yaml
dashboard:
  port: 2468

sync:
  redis: 
    port: 6379
    host: localhost
  
services:
  google:
    www:
      strategy: http
      url: http://www.google.com
    connection:
      strategy: tcp
      host: google.com
      port: 80
```

### Services

Services are a way of grouping several sensor checks together.  In the example above, we have a "google" service w
hich we check by making a get request to "http://www.google.com" and also seeing if we have a connection to port 8
0 on the "google.com" host.  In the yaml config, a service is a "hash" of sensors where the keys are the names of
the sensors and the values are the configuration.

### Sensors

Sensors are a way of describing a health check.  Each sensor config MUST at least have a strategy.  Common configuration
options accross all strategies are:

  * timeout: number (milliseconds) to define how long it will allow a check before declaring it a failure
  * interval: number (milliseconds) of time to wait between health checks (called after the result of a check)
  * fall: number of fails to be considered down
  * rise: number of passes to be considered up

Here are some 
examples of how you can use sensors and their strategies:

*tcp*
```yaml
strategy: tcp
host: google.com
port: 80
```

*http*
```yaml
strategy: http
url: http://www.google.com
```

*pidfile*
```yaml
strategy: pidfile
pidfile: /var/pids/mysql.pid
```

