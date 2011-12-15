require('js-yaml');

var express = require('express');
var Service = require('./service');
var http    = require('http');
var Status  = require('./status');

export class Server {
  function initialize(file) {
    var config = (typeof file == 'object') ? file : require(file).shift();

    this.port  = config.port || '2468';
    this.host  = config.host || '127.0.0.1';

    this.services = {};
    this.servicesArray = [];

    for (var name in config.services) {
      this.handleServiceConfig(name, config.services[name]); 
    }

    this._status = new Status();
  }

  function handleServiceConfig(name, config) {
    var services = [];

    if (config.actions && config.hosts) {
      foreach (var host in config.hosts) {
        var actions = [];
        foreach (var a in config.actions) {
          var newAction = {};  
          for (var k in a) newAction[k] = a[k];
          var conf = host.split(':');

          if (conf.length == 2) {
            newAction['host'] = conf[0];
            newAction['port'] = conf[1];
          } else {
            newAction['host'] = conf[0];
          }

          actions.push(newAction);
        }

        var newName = name + ':' + host;
        var service = new Service(newName, actions);
        this.addService(newName, service);
      }
    }

    else {
      var service = new Service(name, config);
      this.addService(name, service);
    }
  }

  function addService(name, service) {
    console.log("Adding service: " + name);
    this.services[name] = service;
    service.name = name;
    this.servicesArray.push(service);
  }

  function getActions() {
    var ret = [];
    foreach (var s in this.servicesArray) {
      foreach (var a in s.actions) {
        ret.push(a);
      }
    }

    return ret;
  }

  function start() {
    if (this.app) this.app.close();

    for (var name in this.services) {
      this.services[name].start();
    }

    var $this = this;

    var app = express.createServer();
    app.configure(#{
      app.set("views", __dirname + "/views");
      app.use(express.static(__dirname + "/static"));
    });

    app.get("/", #(req, res) {
      res.render('status.jade', { services: $this.servicesArray });
    });


    app.get("/health", #(req, res) {
      res.writeHead(200, {"Content-type": "text/plain"});
      res.end("OK");
    });

    app.get("/health.strict", #(req, res) {
      var passed = true;
      foreach (var a in $this.getActions()) {
        if (! a.meta.up) {
          passed = false;
          break;
        }
      }

      res.writeHead(passed ? 200 : 400, {"Content-type": "application/json"});
      res.end($this._status.json($this.serviceArray));
    });

    app.get("/benchmark/:service/:action_idx", #(req, res) {
      var params = req.params;
      var action = $this.services[params.service].actions[parseInt(params.action_idx)];

      var url = require('url').parse(req.url, true);
      var count   = parseInt(url.query.count || 1);
      var clients = parseInt(url.query.clients || 1);

      var finished = 0;

      var done = function () {
        res.writeHead(200, {"Content-type": "application/json"});
        res.end("{}");
      };

      for (var i=0; i<clients; i++) {
        action.benchmark(parseInt(url.query.count), #{ 
          finished += 1; 
          if (finished == clients) done();
        });
      }
    });

    app.get("/status.:format?", #(req, res) {
      if (req.params.format == 'json') {
        res.end($this._status.json($this.services));
      } else {
        res.render('status.jade', { services: $this.servicesArray });
      }
    });

    app.get("/:service", #(req, res) {
      var service = $this.services[req.params.service];
      if (! service) {
        res.send(404);
      } else {
        service.respond(res);
      }
    });
    
    console.log('Starting upbeat app: http://' + this.host + ':' + this.port);

    app.listen(this.port);
    this.app = app;
  }

  function stop() {
    if (this.app) this.app.close();
  }
}
