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
