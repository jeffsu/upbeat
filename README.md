Upbeat
-------

Useful for health and performance checking and then distributing the data in a quick manner. 

Installation
------------

    npm-g install upbeat
    upbeat ./my/upbeat-config.yml

Examples:
---------

    port: 2468
    host: 127.0.0.1
    services:
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

Status Pages:
-------------

  * http://localhost:2468/status - status page
  * http://localhost:2468/status.json - status in json format
  * http://localhost:2468/factual-api
  * http://localhost:2468/google.com
  * http://localhost:2468/redis
