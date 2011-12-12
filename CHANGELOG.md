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
