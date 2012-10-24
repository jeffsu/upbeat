var utils = require('./utils');

exports['test sensor'] = function (test, assert) {
  utils.healthySensor(function (count) {
    assert.equal(count.beat, 4);
    assert.equal(count.up, 1);
    assert.equal(count.pass, 4);
    assert.equal(count.fail, 0);
    assert.equal(count.down, 0);
    test.finish();
  });
}

exports['test sensor unhealthy'] = function (test, assert) {
  utils.unhealthySensor(function (count) {
    assert.equal(count.beat, 4);
    assert.equal(count.up, 1);
    assert.equal(count.pass, 2);
    assert.equal(count.fail, 2);
    assert.equal(count.down, 1);
    test.finish();
  });
}

