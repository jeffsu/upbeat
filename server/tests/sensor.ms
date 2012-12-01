var utils = require('./utils');

exports['test sensor'] = function (test) {
  utils.healthySensor(function (count) {
    test.equal(count.check, 4);
    test.equal(count.up, 1);
    test.equal(count.pass, 4);
    test.equal(count.fail, 0);
    test.equal(count.down, 0);
    test.done();
  });
}

exports['test sensor unhealthy'] = function (test) {
  utils.unhealthySensor(function (count) {
    test.equal(count.check, 4);
    test.equal(count.up, 1);
    test.equal(count.pass, 2);
    test.equal(count.fail, 2);
    test.equal(count.down, 1);
    test.done();
  });
}

