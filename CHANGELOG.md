** 0.2.0-pre1 **

  * refactored server
    * added graphs
    * global health checks
  * refactored configuration
  * added forever integration

** 0.1.16 **

  * refactored routes
  * fixed recursive timeout bug
  * charting added

** 0.1.14 **
 
  * adding service level config for all actions
  * adding oauth strategy
  * changing tempo syntax
  * adding json to tempo
  * adding matches and lambda to http
  * fixed host parsing bug
  * making first check happen immediately followed by proper interval

** 0.1.13 **
 
  * downgraded required version of node

** 0.1.12 **
  
  * benchmarking on webserver - http://localhost:2468/benchmark/<service>/<action idx>?count=5&clients=2
  * benchmarking on commandline - tempo <clients> <count> <service> <action idx> <yaml file>
  
** 0.1.11 **

  * Adding performance testing

** 0.1.10 **

  * fixed timing bug
  * added lastFailure time

** 0.1.9 **

  * fixed passed percentage on status page

** 0.1.8 **

  * fixing various bugs in http options
  * allow for multiple hosts per service
    
    services:
      myserver:
        hosts: 
          - 127.0.0.1
          - 192.168.1.2
        actions:
          - strategy: http

** 0.1.7 **
  
  * adding historical response times
  * adding max-response-time option
  * default banner for executable

** 0.1.6 **

  * tcp connection strategy
  * added specific interval/timeouts for different strategies

** 0.1.5 **

  * registerStrategy
  * upbeat self monitoring

** 0.1.4 **

  * Preliminary support for mysql
 
** 0.1.3 **

  * Added process checking
  * Added better views and middleware for server
