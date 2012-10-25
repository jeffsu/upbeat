var utils = require('./utils');

exports['test sensor'] = function (test, assert) {
  utils.healthySensor(function (count, sensor) {
    var stats = sensor.stats;

    assert.equal(stats.min.getCount('total'), 4);
    assert.equal(stats.min.getCount('total'), 4);

    var data = stats.sensor(stats.min);
    console.log(data);

    test.finish();
  });

}


