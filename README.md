#Upbeat

Process monitoring with scalable health/performance checking.

Upbeat provides several useful features:

**Complex healthcheck strategies**

For accurate healthchecks, sometimes the likes of monit, nagios and/or haproxy is not enough.  An example
would be testing a mysql server to see if 1) the process is running 2) a query works 3) how fast the query was
This is just and example of what upbeat is meant to do.  It is not meant to replace the tools mentioned previously, 
but to actually play nicely with them.

**Fast and scalable remote health checking**

Upbeat leverages nodes quickness and allows service healthchecks to be temporarily cached allowing more throughout put 
in your healthchecks.  This will enable every machine to know the status of every other machine in a cluster without doing
an expotential number of "real" healthchecks.  In the context of cloud computing, where high throughput load balancing is 
non-trivial this becomes very useful.

**Web Dashboard**

See your statuses on one page or use them for scripting through an api.

**Forever Integration**

Define processes to be run and how to monitor them.

#Documentation

- [Installation](#installation)
- [Sample Config](#sample)
- [Dashboard](#dashboard)
- [Configuration](#configuration)
  - [Using Forever Process Monitoring](#forever)
  - [Services](#services)
  - [Actions](#actions)
- [Strategies](#strategies)
  - [process](#process)
  - [upbeat](#upbeat)
  - [tcp](#tcp)
  - [http](#http)
  - [redis](#redis)
  - [mysql](#mysql)
  - [oauth request](#oauth)
- [api](#api)

<a name="installation" />
##Installation

Assuming you have node and npm installed, run:

    npm-g install upbeat
    upbeat ./my/upbeat-config.yml

Now an http server will be running that you can query for health statuses

<a name="sample" />
##Example Config File:

    port: 2468
    host: 127.0.0.1

    services:
      rails-process:
        - strategy: mysql
          socket: /tmp/mysql.sock
        - strategy: process
          pidfile: /tmp/rails.pid
        - strategy: http
          url: http://localhost:3000/
        - strategy: http
          port: 3000
          host: 127.0.0.1
          interval: 3000
          timeout:  1000

      factual-api:
        - name: places
          strategy: http
          url: http://api.v3.factual.com/t/places
          get:
            KEY: <my key>
            q:   starbucks 

      google.com:
        - name: homepage
          url: http://www.google.com
          strategy: http

      redis:
        - strategy: redis
          port: 6537
          host: 127.0.0.1

      mysql:
        - strategy: mysql
          socket: /tmp/mysql.sock

<a name="dashboard" />
##Web Dashboard:

  * http://localhost:2468/ - dashboard
  * http://localhost:2468/health - health check returns 200 
  * http://localhost:2468/services/factual-api 
  * http://localhost:2468/services/factual-api/health
  * http://localhost:2468/services/google.com
  * http://localhost:2468/services/google.com/health
  * http://localhost:2468/services/redis
  * http://localhost:2468/services/redis/health

<a name="configuration" />
##Configuration:

Upbeat uses YAML for configuration.  There are several concepts to take note of when 
running configuring upbeat: server, services, actions and strategies

<a name="global" />
###Global Server Configuration:

In the top level of the yaml configuration you have 3 main options:

  * host: the ip on which the upbeat http server binds to
  * port: the port on which the upbeat http server listens on
  * services: a key/value hash where the key is the name of the service and the value is an array of action definitions

<a name="forever" />
###Forever:

You can integrate forever by using the "processes" keyword in your config.

    processes:
      NodeServer:
        command: "/usr/local/bin/node"
        options: [ "server.js" ]
        checks:
          - strategy: http
            url: http://localhost:1337
            status: 200
            interval: 3000
          - strategy: http
            url: http://localhost:1337/hello
            status: 200
            interval: 3000

<a name="services" />
###Services:

The services section in the global configuration has to be a hash where the key is 
the name of the service and the value is an array of "actions" for the service to check.

<a name="actions" />
###Actions:

Actions are a hash that have one required field: strategy. Stragety is used to tell upbeat
how to test a particular service.  Every action has these fields available to it:

**optional fields**
  
  * rise: number of times action has to pass before action can be upgraded from "down" to "up"
  * fall: number of times action has to fail before action can be downgraded from "up" to "down"
  * interval (in millisecondes): time between passed or failed checks (default depends on the strategy) 
  * timeout (in milliseconds): time allowed for the request to pass otherwise, its canceled and marked as failed (defaults depends on the strategy)
  * max-response-time: similar to timeout. If an action returns before timeout but is greater than max-response-time, it will still count as a failure
  * name: vanity name for the action used in reports

<a name="strategies" />
##Strategies

<a name="process" />
**process**

Checks to see if a process is running via pidfile:

  * pidfile: file with the pid written in it

Example:
    
    services:
      my-process:
        - pidfile: /tmp/my.pid
          strategy: process

<a name="http" />
**http**

The http strategy will send a request to the server. Fields:

  * url: The url of the request to use
  * post or put: hash of key/value pairs to use as the data of the request
  * get: hash of key/value parise to use as the query string
  * timeout: defaults to 10000
  * interval: defaults to 10000
  * matches: (array or string) regular expression to test against the returned http payload. 
  * lambda: (array or string) a function that should return a boolean (if its matches is not enough)
  * headers: Hash of headers to be used

Example:

    services:
      http-actions:
        - url: http://www.google.com
          strategy: http
          matches: html
          lambda: "function (data) { return data.match(/html/); }"

        - name: test-google
          url: http://www.google.com
          strategy: http
          headers:
            Host: www.google.info

        - name: test-search
          url: http://www.google.com
          strategy: http
          get:
            q: upbeat

        - name: test-google
          strategy: http
          url: http://www.google.com
          rise: 3
          fall: 1

<a name="upbeat" />
**upbeat**

Yes, upbeat can monitor other upbeat servers. Fields:

  * port: port of upbeat server to monitor
  * host: host of upbeat server to monitor
  * timeout: defaults to 5000
  * interval: defaults to 5000

Example:

    port: 2467
    services:
      upbeat:
        - strategy: upbeat

<a name="tcp" />
**tcp**

Strategy to check if a connection to a port can be established. Fields:
 
  * port: port of service
  * host: host of service
  * timeout: defaults to 2000
  * interval: defaults to 3000

<a name="mysql" />
**mysql**

The mysql strategy will connect to a mysql server and perform a query. Fields:

  * sql: sql to send - defaults to "SHOW DATABASES LIMIT 1"
  * database: selects database to use - defaults to "MYSQL"

connecting - either use the socket field or:

  * host: defaults to '127.0.0.1'
  * port: defaults to 3306
  * user
  * password
  * timeout: defaults to 5000
  * interval: defaults to 10000
 
Example:
  
    services:
      mysql:
        - strategy: mysql
          socket: /tmp/mysql.sock

<a name="redis" />
**redis**

The redis strategy will connect to a redis server and issue an "ECHO hello" command. Fields:

  * host: host of redis server
  * port: port of redis server
  * timeout: defaults to 2000
  * interval: defaults to 10000
 
Example:
  
    services:
      redis:
        - host: 127.0.0.1
          port: 6537
          strategy: redis

<a name="oauth" />
**oauth**

Upbeat supports basic OAuth get requests. Fields:

  * url
  * key: oauth key
  * secret: oauth secret

Example:

    services:
      oauth:
        - strategy: oauth
          url: http://api.v3.factual.com/t/places
          key: "My Key"
          secret: "My Secret"
            

Custom Strategies
-----------------

Its pretty simple to register a custom strategy.  There are 3 things the object needs to have:

  1. an instantiator where the only paramater is a config hash (action)
  1. check(callback): the callback is function that expects a boolean
  1. clear(): a function that should halt any asynchronus activity

Example:   

    var AlwaysPass = function (config) { this.config };
    AlwaysPass.prototype.check = function (callback) {
      callback(true);
    };

    AlwaysPass.prototype.clear = function () { 
      // no op
    };

    require('./upbeat').registerCallback('always-pass', AlwaysPass);

Config file

    services:
      myservice:
        - strategy: "/home/me/my-strategy.js"
          key0: val0
          key1: val1

# Logging

All logging is optional, but here are some parameters you can use:

    logging:
      console: false # defaults to true
      files:
        - /var/log/upbeat.log
        - file: /var/log/upbeat.errors.log
          level: error

If you want to build your own listeners to upbeat, please follow lib/upbeat/logger.ms for an example.
You can also look at bin/upbeat for an example of how to instantiate an upbeat server via config file.

    var c = new upbeat.Configurer(<config object>);
    c.server.on('change', function (service) { console.log('something changed') });
    c.start();

# API

Using configurer to instantiate your server.

    var config = ... json config ...;
    var configurer = new upbeat.Configurer(config);
    configurer.start();

## Configurer

The configurer has 3 main members:

  1. server
  1. logger
  1. webapp

### Server

The upbeat server is the object that does all the health checking and process management.

#### Events

*up* 

Every time a service comes up.

*down*

Every time a service goes down.

*change*

Every time a services changes status.

*snapshot*

Every time a service gets snapshotted

### Logger

A container for a winston object and is a proxy for a lot of the server events.

### WebApp

A container for an express application.
