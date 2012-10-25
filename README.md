# Upbeat

Upbeat is a suite of tools aimed to handle performance health checks.
If there are N servers that need to know the health of one service, you can respond in O(1).

# 4 Components

1. upbeat: everything (including executable) you need to launch a full on dashboard
1. upbeat-dashboard: the ui behind upbeat-server
1. upbeat-server: a server that can run if you want to programmatically handle health checking 
1. upbeat-health: the suite of strategies and an interval checker for health checking. Useful
   if you want to be able to use it outside of upbeat-server.
