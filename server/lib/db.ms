export class DB {
  function initialize(server, options) {
    options = options || {};
    this.server = server;
    this.setEvents(server);
  }

  function setEvents(server) {
    server.eachService(#(serviceName, service) {
      service.eachSensor(#(sensorName, sensor) {
        sensor.on('check', #{ self.check(serviceName, sensorName, $1, $2); });
      });
    });
  }

  function handleCheck(service, sensor, err, time) {

  }
}
