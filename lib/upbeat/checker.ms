var http = require('http');
var qs   = require('querystring');

export class Checker {
  function initialize(config, listener) {
    this.redis    = config.redis;
    this.listener = listener;

    this.interval = config.interval || 5000;
    this.url      = config.url      || 'http://localhost:3000/';
    this.method   = config.method   || 'GET';
    this.timeout  = config.timeout  || 1000;

    this.alive = true;
    this.meta = { count: 0 };
  }

  function check(callback) {
    var $this = this;
    var start = parseInt(new Date());


    var req = http.request($this.url, #(resp) { 
      if (resp.headers.code != '200') {
        console.log($this.url + ' failed');
        $this.listener.setStatus(false);
      } else {
        console.log($this.url + ' passed');
        $this.listener.setStatus(true);
        $this.updateResponse(start, parseInt(new Date()));
      }

      if (callback) callback();
    });

    req.setTimeout(this.timeout);

    req.on('error', #{ 
      console.log($this.url + ' failed');
      $this.listener.setStatus(false) 
      if (callback) callback();
    });

    req.end();
  }

  function run(notFirst) {
    var $this = this;
    if (! $this.alive) return;

    // first time so just run it
    if (notFirst) {
      $this.timeoutId = setTimeout(#{ $this.check(#{ $this.run(true) }) }, $this.interval);
    } else {
      $this.check(#{ $this.run(true) });
    }
  }

  function stop() {
    clearTimeout($this.timeoutId);
    this.alive = false;
  }

  function updateResponse(start, end) {
    var time = end - start;
    this.meta.lastResponse = time;

    var avg   = this.meta.avgResponse;
    var count = this.meta.count;

    if (avg) {
      this.meta.avgResponse = ((avg * count) + time) / (count + 1);
    } else {
      this.meta.avgResponse = time;
    }

    this.meta.count = count + 1;
  }

  function flush() {
    this.meta = { count: 0 };
  }
}
