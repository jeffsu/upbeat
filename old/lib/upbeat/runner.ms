
export class Runner {
  function initialize(server, webApp) {
    this.server = server;
    this.webApp = webApp;
  }

  function start() {
    this.server.start();
  }
}
