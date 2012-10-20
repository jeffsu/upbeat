require('mochiscript');

var tests = [ 'server', 'sensor' ];

function test() {
  if (tests.length) {
    var file = tests.shift();
    console.log('testing: ' + file);
    require("./" + file);
  } else {
    process.exit(0);
  }
}

test();
setInterval(test, 2000);
