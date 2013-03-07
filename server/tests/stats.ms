var utils = require('./utils');

exports['test sensor'] = function (test) {
  utils.healthySensor(function (count, sensor) {
    var stats = sensor.stats;

    test.equal(stats.min.getCount('total'), 4);
    test.equal(stats.min.getCount('total'), 4);

    var data = stats.sensor(stats.min);
    console.log(data);

    test.done();
  });

}
