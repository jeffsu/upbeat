export class Base {
  include $m.EventEmitter;

  function eachChild(cb) {
    for (var name in this.children) 
      cb(name, this.children[name]);
  }

  function start() {
    if (this.isRunning) return;
    this.isRunning = true;
    this.run();
    this.eachChild(#(name, child) { child.start(); });
  }

  function pause() {
    this.stop();
  }

  function resume() {
    this.start();
  }

  function run() {
    /* stub */
  }

  function stopRun() {
    /* stub */
  }

  function stop() {
    if (!this.isRunning) return;
    this.isRunning = false;
    this.stopRun();
    this.eachChild(#(name, child) { child.stop(); });
  }

  function isHealthy() {
    for (var name in this.children) 
      if (!this.children[name].isHealthy()) return false;
    return true;
  }

  function addChild(klass, name, options) {
    if (!this.childList) this.childList = []
    var child = this.children[name] = new klass(options);
    this.childList.push(child);
    return child;
  }

}
